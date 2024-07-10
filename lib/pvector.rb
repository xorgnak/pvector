# frozen_string_literal: true

require "pstore"
require "rwordnet"
require "llamafile"
require "sinatra/base"
require "wikipedia"
require 'serialport'

require_relative "pvector/version"

require_relative "pvector/book"
require_relative "pvector/title"
require_relative "pvector/author"
require_relative "pvector/word"
require_relative "pvector/wiki"
require_relative "pvector/input"
require_relative "pvector/app"
require_relative "pvector/z4"

module Pvector
  class Error < StandardError; end
end
module MIND
  @@CONF = {
    wonder: 3,
    min: 4,
    max: 32
  }
  def self.conf
    @@CONF
  end
  
  def self.learn!
    Dir['books/*'].each { |book| MIND << book }
  end

  def self.normalize i
    return i.downcase.gsub(", ", " ").gsub(". ","").gsub("! ","").gsub("; ","").gsub(": "," ").gsub("?","").gsub("'","").gsub('"',"").gsub("(","").gsub(")","").strip
  end

  def self.sanitize w
    return w.gsub("(", "").gsub(")", "").gsub("<","").gsub(">","").gsub("[","").gsub("]","").gsub("{","").gsub("}","").gsub('?',"").gsub('$',"").gsub("^","").gsub(".","").gsub("*","")
  end
  
  def self.<< book
    _a, _t = book.gsub("books/","").gsub(".txt","").split("-")
    _aa = _a.gsub("_"," ")
    _tt = _t.gsub("_"," ")
    TITLE[_tt][:author] = _a
    AUTHOR[_aa][:books] ||= []
    AUTHOR[_aa][:books] << _t
    AUTHOR[_aa][:books].uniq!
    File.read(book).gsub(/\n\n+/,"\n\n").split("\n\n").each do |paragraph|
      input = paragraph.gsub(/\n/, " ")
      inp_s = MIND.normalize(input)
      inp_a = inp_s.split(" ")
      if inp_a.length >= @@CONF[:min] && inp_a.length <= @@CONF[:max]
        puts %[BOOK[#{_tt}][#{BOOK[_tt].length}]: #{inp_a.length} tokens]
        BOOK[_tt] << input
        INPUT[input].each_pair { |k,v| TITLE[_tt][k] = v }
      end
    end
  end
  
  def self.author
    AUTHOR
  end

  def self.book
    BOOK
  end

  def self.title
    TITLE
  end

  def self.context i
    ii, h = MIND.normalize(i).split(" "), {}
    ii.map { |e| c = WORD.context(MIND.sanitize(e), ii); if %[#{c}].length > 0; h[e] = c; end }
    return h
  end
  
  def self.match *k
    BOOK.match([k].flatten)
  end
  
  def self.score *kk
    h = Hash.new { |hh,hk| hh[hk] = {} }
    MIND.match([kk].flatten).each_pair do |title,v|
      if v.keys.length > 0
        h[title][:title] = title
        h[title][:author] = TITLE[title][:author]
        v.each_pair do |section,keywords|
          h[title][:keywords] ||= {}
          keywords.each_with_index do |keyword, i|
            entry = BOOK[title][section]
            h[title][:keywords][keyword] ||= {} 
            h[title][:keywords][keyword][i] = { section: section, entry: entry, context: WORD.context(keyword, entry) }
          end
        end
      end
    end
    return h
  end
  
  def self.thought i
    a = []; MIND.score(MIND.normalize(i).split(" ")).each_pair { |k,v|
      v[:keywords].each_pair { |kk,vv|
        vv.each_pair { |kkk,vvv|         
          a << vvv[:entry]
        }
      }
    }
    return a.shuffle.uniq.sample
  end

  def self.summary i
    return WIKI[i][:summary]
  end

  def self.lookup i
    return WIKI[i][:text]
  end

  def self.define i
    return [ MIND.context(MIND.normalize(i)).map { |k,v| %[#{k} is #{v}] } ].flatten
  end

  def self.think *i
    return [ MIND.thought(MIND.normalize(i.join(" "))) ].flatten
  end
  
  def self.respond *i
    return [ Llamafile.llama(MIND.normalize(i.join(" ")))[:output] ].flatten
  end
end

Dir['books/*'].each { |e|
  _a, _t = e.gsub("books/","").gsub(".txt","").split("-")
  _aa = _a.gsub("_"," ")
  _tt = _t.gsub("_"," ")
  BOOK[_tt]
  TITLE[_tt]
  AUTHOR[_aa]
}

Process.detach(fork { App.run! })

