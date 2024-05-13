module INPUT
  def self.[] i
    h = {}
    ie = MIND.normalize(i).split(" ")
    ie.each { |e| h[e] = WORD.context(e,ie); }
    return h
  end
end
