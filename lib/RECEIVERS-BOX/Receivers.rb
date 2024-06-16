#
# Les destinataires en tant qu'ensemble des destintaires qui doivent
# recevoir le message du mailing.
# 
# Il est défini avec le "file-box", le fichier définissant le mailing
# 
class ReceiversBox

  def throw_box(err_msg)
    raise VPLError.new(err_msg, :receivers)
  end

  # Instanciation d'une boite de destinataires avec une boite de
  # fichier mailing.
  # 
  def initialize(filebox)
    @filebox    = filebox
    @receivers  = nil
  end

  # La liste finale des destinataires (toutes exclusions effectuées)
  def receivers
    @receivers || begin
      to_data = @filebox.metadata['To']
      # STDOUT.write "to_data : #{to_data.inspect}::#{to_data.class}\n".orange 
      # Pour n'utiliser que la fonction get_from_list
      to_data = [to_data] if to_data.is_a?(String)
      #
      # On récupère tous les destinataires
      # 
      get_from_list(to_data)
      ex_data = @filebox.metadata['Exclude']||@filebox.metadata['Excludes']
      # STDOUT.write "ex_data : #{ex_data.inspect}::#{ex_data.class}\n".orange
      # Pour n'utiliser que la fonction exclude_from_list
      ex_data = [ex_data] if ex_data.is_a?(String)
      #
      # On retire tous les destinataires à exclure
      # 
      exclude_from_list(ex_data)
    end
    @receivers
  end

  # Ajoute un destinataire avec les données +data+ en vérifiant 
  # qu'il soit valide. S'il ne l'est pas, une erreur fatale est
  # produite (on n'admet aucune erreur)
  # 
  # L'instance Receiver est ajoutée à @receivers
  # 
  # @param data [Hash]
  # 
  #   Les données du destinataire, à commencer par son mail
  # 
  # @param path [String]
  # 
  #   Lorsque la donnée vient d'un fichier, on le précise pour le
  #   message d'erreur
  # 
  def add_receiver(data, path = nil)
    receiver = Receiver.new(data)
    #
    # Si le destinataire est valide (de façon générale), on le 
    # met dans la liste des destinataires.
    # Sinon, on produit une erreur fatale (tout doit être OK dans
    # un listing pour l'envoyer)
    # 
    if receiver.valid?
      @receivers << receiver
    else
      if path.nil?
        raise ERRORS[:receivers][:bad_receiver] % {receiver:data.inspect, error: receiver.error}
      else  
        raise ERRORS[:receivers][:bad_receiver_in_file] % {path:path, receiver:data.inspect, error: receiver.error}
      end
    end    
  end

  # Exclus un destinataire
  def remove_receiver(foo)
    mail = nil
    case foo
    when Receiver
      mail = foo.mail
    when String
      mail = foo
    when Hash
      mail = foo['Mail']
    else
      raise ERRORS[:receivers][:bad_exclusion] % {exclus: foo.inspect, class: foo.class}
    end
    # 
    # On supprime ce destinataire si on trouve son mail
    # (note : si on ne le trouve pas, on ne fait rien, ça peut tout 
    #  à fait arriver dans un cas normal, par exemple avec des .csv)
    # 
    @receivers.delete_if {|receiver| receiver.mail == mail }
  end


  # Méthode qui récupère les données des destintaires depuis une 
  # liste fournie par le fichier mailing
  # 
  # Met les données (instances Receiver) dans la donnée @receivers
  # 
  def get_from_list(list)
    @receivers = []
    list.each do |item_list|
      case item_list
      when Hash
        add_receiver(item_list)
      when /\.csv$/ 
        #
        # => un fichier CSV
        # 
        item_list = File.expand_path(File.join(@filebox.folder, item_list)) unless File.exist?(item_list)
        get_from_csv(item_list)
      when /,/      
        # 
        # => une donnée comme une rangée CSV
        # 
        add_receiver(Receiver.get_data_from(item_list))
      when REG_MAIL_PATRO
        #
        # => Un mail avec patronyme
        # 
        add_receiver(Receiver.get_data_from(item_list))
      when REG_SIMPLE_MAIL
        #
        # => Un simple mail
        # 
        add_receiver({'Mail' => item_list})
      else
        raise ERRORS[:receivers][:bad_list_item] % {item: item_list.inspect}
      end
    end
  rescue Exception => e
    raise VPLError.new(e.message, :receivers)
  rescue VPLError => e
    raise e
  end

  def exclude_from_list(list)
    return if list.nil? || list.empty?
    list.each do |item_list|
      # STDOUT.write "item_list = #{item_list.inspect}\n".orange
      case item_list
      when /\.csv$/ # => exclusion par fichier CSV
        item_list = File.expand_path(File.join(@filebox.folder, item_list)) if item_list.start_with?('.')
        exclude_from_csv(item_list)
      when /,/      # => une donnée comme une rangée CSV
        receiver_data = Receiver.get_data_from(item_list)
        remove_receiver(receiver_data)
      when REG_MAIL_PATRO
        receiver_data = Receiver.get_data_from(item_list)
        remove_receiver(receiver_data)
      when REG_SIMPLE_MAIL
        remove_receiver({'Mail' => item_list})
      when /\.rb\b/
        #
        # => Un filtre ruby
        # 
        filtre_ruby_destinataires(item_list)
      else
        raise ERRORS[:receivers][:bad_list_item_for_exclusion] % {item: item_list.inspect}
      end
    end
  rescue Exception => e
    raise VPLError.new(e.message, :receivers)
  rescue VPLError => e
    raise e
  end

  # Méthode qui récupère les données des destinataires depuis un
  # fichier CSV.
  # 
  # @param path [String]
  # 
  #   Chemin d'accès au fichier CSV contenant les destinataires
  # 
  # Met les données (instances Receiver) dans la donnée @receivers
  # 
  def get_from_csv(path)
    @receivers ||= []
    csv = Receivers::CSV.new(self, path)
    error_key = csv.check_if_valid_receivers_file
    unless error_key.nil?
      raise(ERRORS[:receivers][error_key])
    end
    #
    # Définition de l'entête
    # 
    @headers = csv.headers 
    #
    # On parse le fichier avec la class CSV en mettant les
    # destinataires dans la liste @receivers
    # 
    csv.foreach do |data_receiver|
      add_receiver(data_receiver, path)
    end
  rescue Exception => e
   raise VPLError.new(e.message % {path:path}, :receivers)
  end

  # Exclus des destinataires à partir du fichier CSV de chemin
  # +path+
  # 
  def exclude_from_csv(path)
    csv = Receivers::CSV.new(self, path)
    error_key = csv.check_if_valid_receivers_file
    unless error_key.nil?
      raise(ERRORS[:receivers][error_key])
    end
    #
    # On parse le fichier avec la class CSV en retirant les
    # destinataires de la liste @receivers
    # 
    csv.foreach do |data_receiver|
      remove_receiver(data_receiver)
    end
  rescue Exception => e
   raise VPLError.new(e.message % {path:path}, :receivers)
  end

  # L'entête, seulement défini si les destinataires viennent d'un
  # fichier csv.
  def headers
    @headers
  end

end
