module INPUT
  def self.[] i
    h = {}
    i.split(" ").each { |e| x = WORD[e]; if x.length > 0; h[e] = x[0]; end }
    return h
  end
end
