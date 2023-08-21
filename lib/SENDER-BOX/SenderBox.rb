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
  #   à envoyer, s'il existe.
  # 
  def send_to(receiver)
    receiver.message || raise(ERRORS[:sender][:receiver_without_message] % {mail: receiver.mail})

    if proceed_sending(receiver.message, @filebox.metadata.sender, receiver.mail)
      # 
      # OK
      # 
      # raise "J'ai réussi"
      return true
    else
      # 
      # BAD
      # 
      # raise "J'ai raté"
      return false
    end
  rescue Exception => e
    raise VPLError.new(e.message, :sender_box)
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



end #/class SenderBox
