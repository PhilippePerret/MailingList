# require 'singleton'
class FileBox

  attr_reader :path

  def initialize(path = nil)
    @path = path
  end

  # = main =
  # 
  # Point d'entrée principal, appelé avec le chemin d'accès au
  # fichier contenant les données mails.
  # C'est la méthode qui réagit à "send-mails path/to/file" dans le
  # Terminal (en fait, c'est le runner.rb qui l'appelle)
  # 
  # @param file [String] 
  # 
  #   Chemin d'accès au fichier définissant le mailing-list
  # 
  # @param options [Hash]
  # 
  #   Options pour l'envoi. Inutilisé pour le moment.
  # 
  def send(file: nil, options: nil)
    check_file_param(file || path)
    check_options_param(options)
  rescue VPLError => e
    e.draw_motor
    raise e.message # pour utiliser assert_raises dans les tests
  rescue Exception => e
    puts "ERREUR FATALE : #{e.message}".red
    puts e.backtrace.join("\n").red
  end


  # @return Le code brut du fichier
  def raw_code
    @raw_code ||= File.read(@path)
  end

  # @return les métadonnées
  def metadata
    @metadata ||= FileBox::Metadata.new(self)
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
