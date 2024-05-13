
module WIKI
  @@WIKI = Hash.new { |h,k| h[k] = Wiki.new(k) }
  class Wiki
    def initialize k
      @id = k
      @db = PStore.new("db/wiki-#{@id}.pstore");
      wiki!
    end
    def id
      @id
    end
    def wiki!
      w = Wikipedia.find(@id)
      @db.transaction { |db|
        if %[#{db[:title]}].length == 0
          db[:title] = w.title
          db[:text] = [w.text.split("\n")].flatten.compact.map { |e| if %[#{e}].length > 0; e; end }.compact
          db[:summary] = [w.summary.split("\n")].flatten.compact.map { |e| if %[#{e}].length > 0; e; end }.compact
          db[:coordinates] = w.coordinates
          db[:links] = w.extlinks
          db[:images] = w.image_urls
        end
      }
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def []= k,v
      @db.transaction { |db| db[k] = v }
    end
  end
  def self.[] k
    @@WIKI[k]
  end
  def self.keys
    @@WIKI.keys
  end
end
