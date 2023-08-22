class MessageTypeBox

  def initialize(filebox)
    @filebox = filebox
  end

  # @return [String] Le message où ne reste plus qu'à mettre les
  # variables propres aux destinataires
  def msgtype_html
    @msgtype_html ||= build_and_return_msgtype_html
  end

  # @return [String] Le message text où ne reste plus qu'à mettre
  # les variables propres aux destinataires
  def msgtype_text
    @msgtype_text ||= build_and_return_msgtype_text
  end

  # @return [String] le message brut tel qu'il se trouve dans le
  # fichier de mailing
  def raw_code
    @raw_code ||= @filebox.raw_message.freeze
  end

  # @return [String] Le message brut mais où les variables images
  # ont été remplacées par leur code
  def raw_code_with_images
    @raw_code_with_images ||= begin
      rc = raw_code.dup
      images.each do |image|
        rc = rc.gsub(/#{image.key}/, image.to_html)
      end
      rc
    end
  end

  # Check la validité du message et de ses informations
  # Pour le moment :
  #   - les images sont checkées à leur instanciation
  def check

  rescue Exception => e
    throw(e.message)
  end


  # @return [Array<Markdown String>] la liste des paragraphes, mais
  # seulement ceux contenant du texte à écrire, donc en excluant les
  # lignes vides et les définitions de style.
  def paragraphes
    @paragraphes ||= begin
      @selectors = {}
      raw_code_with_images.split("\n\n").collect do |parag|
        if parag.strip.empty?
          nil
        elsif parag.match?(REG_DEFINITION_CLASS_CSS)
          parag.scan(REG_DEFINITION_CLASS_CSS).to_a.each do |selector, definition|
            @selectors.merge!(selector => definition)
          end
          nil
        else
          parag
        end
      end.compact + ['']
      # Le dernier paragraphe vide ajouté ci-dessus permet d'afficher
      # l'image qui se trouverait tout à la fin du message, et qui 
      # n'apparait pas dans Mail.app de MacOS. Si ça ne fonctionne
      # pas à tous les coups, on pourra essayer de mettre le code
      # ci-dessous
      # end.compact + ['<div style="color:transparent;">- - -</div>']
    end
  end

  # Table [Hash] définissant les sélecteurs CSS (class).
  def selectors
    @selectors # définis dans #paragraphes
  end

  # @return Liste des variables utiles pour le texte
  # (tous les destinataires doivent les connaitre)
  def variables
    @variables ||= begin
      raw_code.scan(/\%\{(.+?)\}/).to_a.collect do |var|
        var[0]
      end.uniq #.tap { |liste| debug "variables : #{liste.inspect}" }
    end
  end

  # @return Liste des images [MessageTypeBox::Image] utilisées dans
  # le texte (chacune doit être définie dans les métadonnées)
  def images
    @images ||= begin
      images_keys = []
      raw_code.scan(/(IMG(?:.+?))\b/).to_a.collect do |key_scan|
        key_img = key_scan[0]
        next if images_keys.include?(key_img)
        MessageTypeBox::Image.new(@filebox, key_img)
      end.compact
    end
  end


  def throw(msg)
    raise VPLError.new(msg, :msgtype_box)
  end


  private

    # Fabrication du message type final, avec tout transformé en HTML
    # et les images remplacées par leur code brut
    # 
    # @return [String] le code final (qui sera consigné dans 
    # @msgtype_html)
    # 
    def build_and_return_msgtype_html
      BuilderHTML.new(self).build
    end

    # Fabrication du message type final au format text simple, pour
    # la première partie du mail.
    # 
    # @return [String] Le code text final qui sera consigné dans
    # la variable @msgtype_text.
    # 
    def build_and_return_msgtype_text
      paragraphes.collect do |paragraphe|
        MarkdownString.new(self,paragraphe).to_text
      end.join("\n\n")
    end


REG_DEFINITION_CLASS_CSS = /\.([a-zA-Z0-9_\-]+) \{(.*)\}$/

end #/class MessageTypeBox
