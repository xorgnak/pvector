
module BOOK
  @@BOOKS = Hash.new { |h,k| h[k] = Book.new(k) }  
  class Book
    def initialize k
      @id = k
      @db = PStore.new("db/book-#{@id}.pstore")
    end
    def id
      @id
    end
    def << i
      @db.transaction { |db| db[db.keys.length] = i }
    end
    def length
      @db.transaction { |db| db.keys.length }
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def match k
      a = []
      r = /\s#{k}\s/
      @db.transaction { |db| db.keys.each { |e| if r.match(db[e]); a << e; end } }
      return a
    end
    def each_pair &b
      @db.transaction { |db| db.keys.each { |e| b.call(e, db[e]) } }
    end
  end
  def self.[] k
    @@BOOKS[k]
  end
  def self.find x
    h = {}
    @@BOOKS.each_pair { |k,v| h[k] = v.match(x) }
    return h
  end
end
