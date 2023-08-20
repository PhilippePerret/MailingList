=begin

  Module pour gérer les images dans un mail

  On utilise la méthode img#to_html pour l'insérer dans le message

=end
class MessageTypeBox
class Image
  
  attr_reader :key, :path

  def initialize(img_key, img_path)
    @key  = img_key
    @path = img_path
  end

  def to_html
    CODE_IMAGE_TEMPLATE % data_template
  end

  def data_template
    {
      alt:    File.basename(path),
      format: format, # 'png', 'jpg', etc.
      code64: code64,
      style:  style,
      width:  width,
      link:   link,
    }
  end

  def format; File.extname(path)[1..-1] end
  def code64
    File.open(path,'rb'){|img| Base64.strict_encode64(img.read)}
  end

end #/class Image
end #/class MessageTypeBox
