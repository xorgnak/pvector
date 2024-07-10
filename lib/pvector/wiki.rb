
module WIKI
  @@WIKI = Hash.new { |h,k| h[k] = Wiki.new(k) }
  class Wiki
    def initialize k
      @id = k
      @db = PStore.new("db/wiki-#{@id}.pstore");
    end
    def id
      @id
    end
    def wiki!
      @db.transaction { |db| if db[:title] == nil; WIKI.wiki(@id).each_pair { |k,v| db[k] = v }; end }
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def keys
      @db.transaction { |db| db.keys }
    end
    def transaction &b
      @db.transaction { |db| b.call(db) }
    end
  end
  def self.wiki k
    hh = {}
    w = Wikipedia.find(k)
    if w.text.class != NilClass
      hh[:title] = w.title
      hh[:text] = [w.text.split("\n")].flatten.compact.map { |e| if %[#{e}].length > 0; e; end }.compact
      hh[:summary] = [w.summary.split("\n")].flatten.compact.map { |e| if %[#{e}].length > 0; e; end }.compact
      hh[:coordinates] = w.coordinates
      hh[:links] = w.extlinks
      hh[:images] = w.image_url
    else
      hh[:title] = k
      [:text,:summary,:coordinates,:links,:images].each { |e| hh[e] = [] }
    end
    return hh
  end
  def self.[] k
    @@WIKI[k]
  end
  def self.keys
    @@WIKI.keys
  end
end
