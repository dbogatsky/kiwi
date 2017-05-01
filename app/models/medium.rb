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

  def doc_word?
    payload_content_type.include?('msword') || payload_content_type.include?('wordprocessingml')
  end

  def doc_excel?
    payload_content_type.include?('spreadsheetml')
  end

  def doc_ppt?
    payload_content_type.include?('presentationml')
  end

  def doc_pdf?
    payload_content_type.include?('pdf')
  end

end