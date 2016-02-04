class Media < OrchardApiModel
  def image?
    type.eql?('image')
  end

  def document?
    type.eql?('document')
  end
end
