# frozen_string_literal: true

require "pstore"
require "rwordnet"
require "rackup"
require "sinatra/base"

require_relative "pvector/version"

require_relative "pvector/book"
require_relative "pvector/title"
require_relative "pvector/author"
require_relative "pvector/word"
require_relative "pvector/input"
require_relative "pvector/app"

module Pvector
  class Error < StandardError; end
end
module MIND
  def self.learn!
    Dir['books/*'].each { |book| MIND << book }
  end
  def self.<< book
    _a, _t = book.gsub("books/","").gsub(".txt","").split("-")
    TITLE[_t][:author] = _a
    AUTHOR[_a][:books] ||= []
    AUTHOR[_a][:books] << _t
    AUTHOR[_a][:books].uniq!
    File.read(book).gsub(/\n\n+/,"\n\n").split("\n\n").each do |paragraph|
      input = paragraph.gsub(/\n/, " ")
      puts %[BOOK[#{_t}][#{BOOK[_t].length}]: #{input}]
      BOOK[_t] << input
      INPUT[input].each_pair { |k,v| TITLE[_t][k] = v }
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
  def self.about k
    BOOK.find(k)
  end
  def self.idea k
    h = {}
    MIND.about(k).each_pair { |k,v| h[k] = BOOK[k][v.sample] }
    return h
  end
  def self.keywords k
    h = {}
    INPUT[k].keys.each { |e| h[e] = MIND.idea(e) }
    return h
  end
  def self.[] k
    a = []
    MIND.keywords(k).each_pair { |kk,v|
      x = v.keys.sample;
      if rand(0..3) == 0
        a << %[What is #{kk}?];
      end
      a << v[x];
      if rand(0..2) == 0
        if rand() == 0
          a << %[#{kk} is #{WORD[kk][0]}]
        else
          a << WORD[kk][0];
        end
      end
    }
    return a.uniq
  end
end

Dir['books/*'].each { |e|
  _a, _t = e.gsub("books/","").gsub(".txt","").split("-")
  BOOK[_t]
  TITLE[_t]
  AUTHOR[_a]
}

Process.detach(fork { App.run! })

#ARGF.argv.each { |e| puts %[READING: #{e}]; MIND << e }
