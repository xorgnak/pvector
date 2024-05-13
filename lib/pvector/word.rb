
module WORD
  def self.define k
    a = []
    lemmas = WordNet::Lemma.find_all(k)
    synsets = lemmas.map { |lemma| lemma.synsets }
    words = synsets.flatten
    words.each { |word|
#      if k.length > 2 && word.pos == 'n'
        a << word.gloss
#      end
     }
    return a
  end
  def self.sanitize w
    return w.gsub("(", "").gsub(")", "").gsub("<","").gsub(">","").gsub("[","").gsub("]","").gsub("{","").gsub("}","").gsub('?',"").gsub('$',"").gsub("^","").gsub("*","").gsub(".","").gsub("/","").gsub("\\","")
  end
  
  def self.context k, i
    s = 0
    de = ""
    WORD.define(k).each do |e|
      a = []
      [i].flatten.each do |ee|
          if /\s#{WORD.sanitize(ee)}\s/.match(e)
            a << ee
          end
      end
      if a.length > s || rand(0..3) == 0
        s = a.length
        de = e
      end
    end
    return de
  end
end

