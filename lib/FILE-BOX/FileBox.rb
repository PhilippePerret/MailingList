class FileBox

  attr_reader :path

  def initialize(path = nil)
    @path = path
    check_file_param(path)
  end

  # = main =
  # 
  # Point d'entrée principal, appelé avec le chemin d'accès au
  # fichier contenant les données mails.
  # C'est la méthode qui réagit à "send-mails path/to/file" dans le
  # Terminal (en fait, c'est le runner.rb qui l'appelle)
  # 
  # @note
  # 
  #   C'est la méthode qu'on doit appeler pour les tests, car elle
  #   raise les erreurs.
  # 
  # @param options [Hash]
  # 
  #   Options pour l'envoi. Inutilisé pour le moment.
  #   Contiendra ensuite les options CLI
  # 
  def send(options = nil)
    SUPERVISOR << "-> FileBox.send"
    # 
    # On démarre le rapport
    # 
    report.start
    #
    # Premières vérifications du fichier mailing
    # 
    options = check_options_param(options||{})
    #
    # Si le mailing est accompagné d'un module (même affixe et .rb)
    # on le charge
    # 
    load_own_module if own_module?
    # 
    # Fabrication des messages pour chaque destinataire, formaté
    # spécialement pour eux
    # 
    destinataires.each do |destinataire|
      destinataire.message = mailbox.build_for_receiver(destinataire)
    end
    #
    # Envoi du message aux destinataires
    # 
    STDOUT.write "\n\n"
    destinataires.each do |destinataire|
      if sender.send_to(destinataire, options)
        report << "- Message envoyé avec succès à #{destinataire.mail}"
      else
        report << "- Échec de l'envoi à #{destinataire.mail}"
      end
    end
    #
    # Pour indiquer au rapport au que tout s'est bien passé
    # 
    report.set_ok
    
  end

  # Instance de la mail-box
  # (partie du moteur qui construit le message final)
  # 
  def mailbox
    @mailbox ||= MailBox.new(self)
  end

  # Instance de la boite d'envoi du message
  # (c'est la partie du moteur qui transmet concrètement le message)
  # 
  def sender
    @sender ||= SenderBox.new(self, options)    
  end

  # Instance du rapport
  # 
  def report
    @report ||= MailingReport.new(self)
  end

  # @return [Array<Receiver>] La liste des destinataires et seulement
  # les destinataires qui doivent recevoir le message.
  def destinataires
    @destinataires ||= ReceiversBox.new(self).receivers
  end

  # @return le MessageTypeBox (boite de message type) pour le
  # fichier mailing courant
  def messagetype_box
    @messagetype_box ||= MessageTypeBox.new(self)
  end

  # @return les métadonnées
  def metadata
    @metadata ||= FileBox::Metadata.new(self)
  end

  # @return Le code brut du fichier
  def raw_code
    @raw_code ||= File.read(@path)
  end


  # @return le message brut, tel qu'il est dans le fichier
  def raw_message
    @raw_message ||= begin
      sp = raw_code.split('---')
      sp.shift # pour enlever la première (vide)
      sp.shift # pour enlever les métadonnées
      sp.join('---').strip # s'il y a un '---' dans le message
    end
  end

  # Requérir le module personnel (s'il existe)
  def load_own_module
    SUPERVISOR << "Chargement du module #{affixe}.rb…"
    load own_module_path
  end

  # 
  # === Données fixes ===
  # 

  def folder
    @folder ||= File.dirname(path)
  end

  def affixe
    @affixe ||= File.basename(path, File.extname(path))
  end

  private

    # Vérifie que le fichier mailing soit conforme
    # Dans le cas contraire, produit une erreur fatale.
    def check_file_param(file)
      file || raise(ERRORS[:file_box][:requires_path])
      file = "#{file}.md" unless file.end_with?('.md')
      File.exist?(file) || raise(ERRORS[:file_box][:file_should_exist] % {path: file})
      @path = file
      file_contains_metadata?       || raise(ERRORS[:file_box][:requires_metadata] % {path: file})
      file_contains_message?        || raise(ERRORS[:file_box][:requires_message] % {path: file})
      metadata.contains_subject?    || raise(ERRORS[:file_box][:requires_subject] % {path: file})
      metadata.contains_sender?     || raise(ERRORS[:file_box][:requires_sender] % {path: file})
      metadata.contains_receivers?  || raise(ERRORS[:file_box][:requires_receivers] % {path: file})
      metadata.precheck_receivers # produit lui-même les erreurs
      metadata.sender_ok?           || raise(ERRORS[:file_box][:bad_sender] % {path: file, sender:metadata.sender})
    rescue Exception => e
      raise VPLError.new(e.message, :file_box)
    end

    def check_options_param(options)
      options ||= {}
      options.key?(:simulation) || options.merge!(simulation: CLI.option(:s)||false)
      options.key?(:delay)      || options.merge!(delay: !CLI.option(:d))

      return options
    end

    # @return true si le fichier définit un message (même court)
    def file_contains_message?
      not(raw_message.empty?)
    end

    # @return true Si le fichier définit des métadonnées
    def file_contains_metadata?
      raw_code.start_with?('---') && raw_code.split('---').count >= 3
    end



    # --- Méthodes concernant le module personnel ---

    # @return true si le fichier mailing possède son propre module
    # (même affixe et extension ruby)
    def own_module?
      File.exist?(own_module_path)
    end


    # Chemin d'accès au module ruby personnel (s'il existe)
    def own_module_path
      @own_module_path ||= File.join(folder, "#{affixe}.rb")
    end
end
