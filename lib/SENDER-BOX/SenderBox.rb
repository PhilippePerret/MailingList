class SenderBox

  def initialize(filebox, options = nil)
    @filebox = filebox
    @options = options || {}
  end

  # = main =
  # 
  # Méthode principale qui envoie le message au destinataire +receiver+
  # 
  # @note
  #   C'est la propriété @message du receiver qui contient le message
  #   à envoyer, au format de mail (qui doit exister.
  # 
  # @param receiver [Receiver]
  # 
  #   Le destinataire du mail
  # 
  # @param options [Hash]
  # 
  #   Les options. Notamment :
  #     - :simulation [Boolean] pour savoir si c'est une simulation
  #     - :delay      [Boolean] pour savoir s'il faut laisser un délai
  # 
  def send_to(receiver, options)
    receiver.message || raise(ERRORS[:sender][:receiver_without_message] % {mail: receiver.mail})

    #
    # S'il faut laisser du temps avant d'envoyer le message
    # 
    if options[:delay]
      temporize(receiver, options) 
    else
      STDOUT.write "#{'[SIM]' if options[:simulation]} Envoi du message à #{receiver.mail}\n".bleu
      sleep 1
    end

    ok = 
      if options[:simulation]
        proceed_simulation(receiver.message, @filebox.metadata.sender, receiver.mail)
      else
        proceed_sending(receiver.message, @filebox.metadata.sender, receiver.mail)
      end

    return ok

  rescue Exception => e
    SUPERVISOR << [e.message] + e.backtrace
    raise VPLError.new(e.message, :sender_box)
  end

  # Procède à la simulation de l'envoi
  # 
  # On ne fait qu'enregistrer le message dans un dossier temporaire
  # 
  # @param message [String]
  # 
  #   Le message mail complet
  # 
  # @param sender [String]
  # 
  #   Adresse mail de l'expéditeur
  # 
  # @param recipient [String]
  # 
  #   Adresse mail du destinataire
  # 
  def proceed_simulation(message, sender, recipient)
    mkdir_p(File.join(APP_FOLDER,'tmp','mails'))
    path = File.join(APP_FOLDER,'tmp','mails',"#{sender}->#{recipient}.eml")
    File.open(path,'wb') { |f| f.write message }
  end

  # Procède véritablement à l'envoi
  #
  # @param message [StringHTML] Message au format HTML
  # @param sender [String] Mail de l'expéditeur
  # @param recipient [String] Mail du destinataire
  # 
  # @return true en cas de succès, false dans le cas contraire
  # 
  def proceed_sending(message, sender, recipient)
    if false # true
      SUPERVISOR << "Message reçu par Sender#proceed_sending :\n#{message}"
    end
    Net::SMTP.start(*SERVER_DATA) do |smtp|
      begin
        smtp.send_message(message,sender,recipient)
        return true
      rescue Exception => e
        puts e.message.rouge
        return false
      end
    end    
  end

  # Pour temporiser l'envoi du message
  def temporize(receiver, options)
    secondes = delai_incompressible(options[:simulation]) + rand(delai_compressible(options[:simulation]))
    msg = "#{"[SIM]" if options[:simulation]} Envoi du message à #{receiver.as_to} dans %i secondes…#{' '*10}".vert.freeze
    while secondes > 0
      STDOUT.write "\r#{msg % secondes}"
      sleep 1
      secondes -= 1
    end
  end

  def delai_incompressible(simulation)
    @delai_incompressible ||= simulation ? 2 : 4
  end
  def delai_compressible(simulation)
    @delai_compressible ||= simulation ? 10 : 26
  end

end #/class SenderBox
