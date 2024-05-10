
module AUTHOR
  @@AUTHORS = Hash.new { |h,k| h[k] = Author.new(k) }
  
  class Author
    def initialize k
      @id = k
      @db = PStore.new("db/author-#{@id}.pstore")
    end
    def id
      @id
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def []= k,v
      @db.transaction { |db| db[k] = v }
    end
  end
  def self.[] k
    @@AUTHORS[k]
  end
  def self.keys
    @@AUTHORS.keys
  end
end
