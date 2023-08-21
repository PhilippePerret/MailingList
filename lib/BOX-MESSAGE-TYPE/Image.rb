=begin

  Module pour gérer les images dans un mail

  On utilise la méthode img#to_html pour l'insérer dans le message

=end
class MessageTypeBox
class Image
  
  attr_reader :key, :path
  attr_reader :data

  # Instanciation de l'image
  # 
  # @param filebox [FileBox]
  # 
  #   La boite principale du mailing
  # 
  # @param img_key [String]
  # 
  #   La marque (clé) de l'image, dans le texte
  # 
  # @param data [Hash]
  # 
  #   Les données supplémentaires (n'est plus utilisé pour le
  #   moment; servait à définir :width, :style et :link)
  # 
  def initialize(filebox, img_key, data = nil)
    @filebox  = filebox
    @key      = img_key
    @path     = @filebox.metadata[key]
    @data     ||= {}
    #
    # On vérifie tout de suite la validité et on lève une erreur
    # VPLError si ce n'est pas le cas. De cette manière, @path 
    # contiendra la bonne valeur.
    # 
    valid?
  end

  def to_html
    CODE_IMAGE_TEMPLATE % data_template
  end

  # @return true si l'image est valide, sinon, définit l'erreur @error
  # qui sera utilisée par la méthode de test
  def valid?
    @path || raise(ERRORS[:messageType][:unknown_image] % {key: key})
    @path = File.expand_path(File.join(@filebox.folder,@path)) if @path.start_with?('.')
    # debug("@path = #{@path.inspect}")
    VALID_IMG_EXTNAMES.include?(File.extname(@path).downcase) || raise(ERRORS[:messageType][:image_bad_extname] % {key: key, name:File.basename(@path), exts:VALID_IMG_EXTNAMES.join(', ') })
    File.exist?(@path) || raise(ERRORS[:messageType][:unfound_image] % {path: @path, key: key})
    return true
  rescue Exception => e
    raise VPLError.new(e.message, :msgtype_box)
  end

  def data_template
    {
      alt:    File.basename(path),
      format: extension, # 'png', 'jpg', etc.
      code64: code64,
      style:  data[:style],
      width:  data[:width],
      link:   data[:link],
    }
  end

  def extension
    @extension ||= File.extname(path)[1..-1]
  end

  def code64
    File.open(path,'rb'){|img| Base64.strict_encode64(img.read)}
  end

end #/class Image
end #/class MessageTypeBox
