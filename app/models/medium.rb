class Medium < OrchardApiModel
  def image?
    type.eql?('image')
  end

  def document?
    type.eql?('document')
  end

  def audio?
    type.eql?('audio')
  end

  def video?
    type.eql?('video')
  end
end