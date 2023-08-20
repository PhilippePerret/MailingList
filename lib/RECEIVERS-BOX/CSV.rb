#
# Class Receivers::CSV
# --------------------
# Permet de gérer les fichiers CSV contenant des destinataires, que
# ce soit pour les inclusions ou pour les exclusions
# 
class Receivers
class CSV

  attr_reader :path

  def initialize(receivers, path)
    @receivers = receivers
    @path      = path
  end

  def foreach(&block)
    options = {headers: true, skip_blanks:true, col_sep: ',', row_sep: :auto}
    ::CSV.foreach(path, **options) do |row|
      hdata = row.to_hash
      yield hdata
    end
  end

  def check_if_valid_receivers_file
    #
    # Le fichier doit exister et être valide
    # (certaines vérifications ont déjà été faites avant)
    # 
    exist?                || raise('unknown_file')
    extension_csv?        || raise('bad_extension')
    defines_header?       || raise('file_requires_header')
    use_comma_separator?  || raise('requires_comma_separator')
    defines_mail_data?    || raise('data_mail_requires')

    return nil # ok

  rescue Exception => e

    return e.message.to_sym

  end

  def headers
    @headers ||= begin
      raw_headers.split(',')
    end
  end

  private

    # 
    # === Méthodes pour l'entête ===
    # 

    # @return [String] l'entête (première ligne) du fichier +path+
    def raw_headers
      @raw_headers ||= get_headers
    end

    def get_headers
      File.readlines(path).each do |line|
        return line.strip
      end
    end


    #
    # === Méthodes de vérifications ===
    # 

    # @return true si le fichier existe
    def exist?
      File.exist?(path)
    end

    # @return true si le fichier possède la bonne extension
    def extension_csv?
      File.extname(path).downcase == '.csv'
    end

    # @return true si le fichier définit bien une entête
    def defines_header?
      headers.include?('Mail')
    end

    # @return true si le fichier définir un séparateur virgule
    def use_comma_separator?
      raw_headers.match?(/,/) && not(raw_headers.match?(/;/))
    end

    # @return true si le fichier définit la donnée 'Mail'
    def defines_mail_data?
      headers.include?('Mail')
    end

end #/CSV
end #/Receivers
