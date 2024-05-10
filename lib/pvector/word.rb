
module WORD
  def self.[] k
    a = []
    lemmas = WordNet::Lemma.find_all(k)
    synsets = lemmas.map { |lemma| lemma.synsets }
    words = synsets.flatten
    words.each { |word|
      if k.length > 2 && word.pos == 'n'
        a << word.gloss
      end
     }
    return a
  end
end

