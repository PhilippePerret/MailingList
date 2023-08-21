class FileBox
class Metadata
  def initialize(filebox)
    @filebox = filebox
    parse
  end

  # Parsing du code des métadonnées
  def parse
    @data = {}
    raw_metadata.split("\n").each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      sp  = line.split('=')
      key   = sp.shift.strip
      value = sp.join('=').strip
      #
      # Si la valeur commence par "[" et finit par "]", on l'évalue
      # pour obtenir une liste
      # 
      if value.start_with?('[') && value.end_with?(']')
        value = eval(value)
      elsif value.start_with?('"') && value.end_with?('"')
        value = eval(value)
      end
      @data.merge!(key => value)
    end
  end

  # Pour pouvoir utiliser @filebox.metadata['To']
  def [](key)
    @data[key]
  end

  #
  # === Données qu'on doit pouvoir obtenir facilement ===
  # 
  def sender
    @sender ||= @data['From']
  end

  def subject
    @subject ||= @data['Subject']
  end

  #
  # === Méthodes de check ===
  # 

  def contains_subject?
    @data.key?('Subject')
  end
  def contains_sender?
    @data.key?('From')
  end
  def contains_receivers?
    @data.key?('To')
  end

  # @return true si les destinataires sont correctement définis, de
  # façon générale
  def precheck_receivers
    receivers = @data['To']
    case receivers
    when String
      receiver_pre_ok?(receivers)      
    when Array
      receivers.each {|receiver| receiver_pre_ok?(receiver)}
    end
  end

  def receiver_pre_ok?(receiver)
    if receiver.match('@')
      true
    elsif receiver.end_with?('.csv')
      File.exist?(receiver)
    else
      raise ERRORS[:file_box][:bad_receiver] % {path: @filebox.path, receiver: receiver}
    end
  end

  def sender_ok?
    sender.match?(REG_SIMPLE_MAIL) || sender.match?(REG_MAIL_PATRO)
  end


  private

  # Méthode qui extrait du fichier le code brut des métadonnées
  # 
  # @note
  #   Il a déjà été vérifié que le fichier commençait par "---" et
  #   qu'il avait un deuxième "---" donc il suffit de prendre le
  #   deuxième élément résultant du split
  # 
  def raw_metadata
    @raw_metadata ||= @filebox.raw_code.split('---')[1]
  end



end #/Metadata
end #/FileBox
