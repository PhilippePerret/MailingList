class ReceiversBox

  # Appel d'un filtre ruby 
  # 
  # @param item_list [String]
  # 
  #   La donnée de filtre telle qu'elle est définie dans le fichier
  #   de mailing. Dans l'utilisation la plus simple, c'est juste
  #   un chemin d'accès à un fichier définissant la méthode (qui
  #   porte son nom) qui reçoit la liste actuelle et retourne la
  #   liste filtrée.
  #   Dans son utilisation plus complexe, elle contient des arguments
  #   après le chemin d'accès au fichier.
  # 
  def filtre_ruby_destinataires(item_list)
    decomposee = item_list.split(' ')
    filter_path = decomposee.shift
    filter_path = File.expand_path(File.join(@filebox.folder, filter_path)) unless File.exist?(filter_path)
    # 
    # Le fichier doit exister
    # 
    File.exists?(filter_path) || raise(ERRORS[:filter][:file_unfound] % {path:filter_path})
    #
    # On déduit du nom du fichier le nom de la méthode
    # 
    method_name = File.basename(filter_path, File.extname(filter_path)).to_sym
    #
    # On détermine les arguments
    # 
    args = eval("[#{decomposee.join(', ')}]")
    args.unshift(@receivers)
    #
    # On requiert le fichier
    # 
    require filter_path
    #
    # Vérification des données
    # 
    defined?(Mailing) || raise(ERRORS[:filter][:undefined_class_mailing] % {path: filter_path})
    Mailing.respond_to?(method_name) || raise(ERRORS[:filter][:undefined_method_filter] % {path: filter_path, name: method_name})
    nombre_arguments_methode = Mailing.method(method_name).arity
    Mailing.method(method_name).arity == args.count || raise(ERRORS[:filter][:bad_arguments_count] % {name: method_name, path: filter_path, exp: nombre_arguments_methode, args: args.count})
    #
    # Sinon, on peut filtrer la liste avec la méthode et la
    # mettre dans la variable qui contient la liste des adresses
    # finales
    # 
    @receivers = Mailing.send(method_name, *args)

    return true
  end
end
