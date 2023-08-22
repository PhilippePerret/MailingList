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
    # La boite de mail
    # (partie du moteur qui construit le message final)
    # 
    require_app_folder('lib/MAIL-BOX')
    mailbox = MailBox.new(self)
    #
    # La boite d'envoi du message
    # (c'est la partie du moteur qui transmet le message)
    # 
    require_app_folder('lib/SENDER-BOX')
    sender = SenderBox.new(self, options)
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
    
  rescue VPLError => e
    e.draw_motor
    raise e.message # pour utiliser assert_raises dans les tests
  rescue Exception => e
    SUPERVISOR.fatal_error(e) # exit
  ensure
    #
    # Arrêt du rapport
    # 
    report.stop
    #
    # Affichage du rapport final
    # 
    report.display_report
  end

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
    @raw_message || begin
      sp = raw_code.split('---')
      sp.shift # pour enlever la première (vide)
      sp.shift # pour enlever les métadonnées
      sp.join('---').strip # s'il y a un '---' dans le message
    end
  end

  # 
  # === Données fixes ===
  # 

  def folder
    @folder ||= File.dirname(path)
  end


  private

    # Vérifie que le fichier mailing soit conforme
    # Dans le cas contraire, produit une erreur fatale.
    def check_file_param(file)
      file || raise(ERRORS[:file_box][:requires_path])
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
      options.key?(:simulation) || options.merge!(simulation: CLI.option(:s))
      options.key?(:delay)      || options.merge!(no_delay: CLI.option(:d))

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
end
