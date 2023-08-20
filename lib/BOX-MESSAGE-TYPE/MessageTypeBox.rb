class MessageTypeBox

  def initialize(filebox)
    @filebox = filebox
  end

  # @return [String] Le message où ne reste plus qu'à mettre les
  # variables propres aux destinataires
  def message_type
    @message_type ||= build_and_return_message_type
  end

  # @return [String] le message brut tel qu'il se trouve dans le
  # fichier de mailing
  def raw_code
    @raw_code ||= @filebox.raw_message
  end

  # Check la validité du message et de ses informations
  # Entre autres choses, vérifie que les images soient bien définies
  # 
  def check
    images.each do |img|
      err = image_ok?(img)
      err.nil? || raise(err)
    end
  rescue Exception => e
    throw(e.message)
  end

  # @return Liste des variables utiles pour le texte
  # (tous les destinataires doivent les connaitre)
  def variables
    @variables ||= begin
      liste = []
      raw_code.scan(/\%\{(.+?)\}/).to_a.each do |var|
        liste << var[0]
      end
      debug "variables : #{liste.inspect}"
      liste
    end
  end

  # @return Liste des images utilisées dans le texte
  # (chacune doit être définie dans les métadonnées)
  def images
    @images ||= begin
      liste = []
      raw_code.scan(/(IMG(?:.+?))\b/).to_a.each do |key_img|
        liste << key_img[0]
      end
      debug "Images: #{liste.inspect}"
      liste
    end
  end


  def throw(msg)
    raise VPLError.new(msg, :msgtype_box)
  end


  private

    # Fabrication du message final, avec tout transformé en HTML et
    # les images remplacées par leur code brut
    # 
    # @return [String] le code final (qui sera consigné dans 
    # @message_type)
    # 
    def build_and_return_message_type
      
    end

    # Vérifie que l'image définie par la clé +key_img+ soit valide
    # c'est-à-dire :
    #   - qu'elle soit définie dans les métadonnées du fichier
    #   - qu'elle corresponde à un fichier image existant
    def image_ok?(key_img)
      image_path = @filebox.metadata[key_img]
      image_path = File.expand_path(File.join(@filebox.folder,image_path)) if image_path && image_path.start_with?('.')
      debug("image_path = #{image_path.inspect}")
      image_path              || raise(ERRORS[:messageType][:unknown_image] % {key: key_img})
      File.exist?(image_path) || raise(ERRORS[:messageType][:unfound_image] % {path: image_path, key: key_img})
      return nil
    rescue Exception => e
      return e.message
    end
end #/class MessageTypeBox
