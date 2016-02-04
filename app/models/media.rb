class Media < OrchardApiModel
  def image?
    type == 'image'
  end

  def document?
    type == 'document'
  end
end
