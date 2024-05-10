
module TITLE
  @@TITLES = Hash.new { |h,k| h[k] = Title.new(k) }
  
  class Title
    def initialize k
      @id = k
      @db = PStore.new("db/title-#{@id}.pstore")
    end
    def id
      @id
    end
    def keys
      @db.transaction { |db| db.keys }
    end    
    def [] k
      @db.transaction { |db| db[k] }
    end
    def []= k,v
      @db.transaction { |db| db[k] = v }
    end
  end
  def self.[] k
    @@TITLES[k]
  end
  def self.keys
    @@TITLES.keys
  end
end
