class String
  def undent
    gsub(/^[ \t]{,#{slice(/^ +/).length}}/, '')
  end
end
