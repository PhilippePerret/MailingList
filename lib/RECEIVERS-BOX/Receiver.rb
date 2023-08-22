class Receiver

  class << self

    # Parse la donnée +datastr+ pour en tirer les données pour le
    # destinataire quand ces données ont été fournies sous forme
    # de ligne CSV (mais pas provenant d'un fichier csv) ou sous 
    # forme de "patronyme <mail valide>"
    # 
    # @return un Hash des données pouvant contenir jusqu'à :
    # {'Mail', 'Patronyme', 'Sexe'}
    # 
    # @param datastr [String]
    # 
    #   Donnée string sous la forme "rangée CSV" avec patronyme,
    #   sexe et mail, ou sous la forme "Patronyme <mail>"
    def get_data_from(datastr)
      if datastr.match?(/,/)
        #
        # Comme une ligne de fichier CSV
        # 
        @datar = {'Mail' => nil, 'Patronyme' => nil, 'Sexe' => nil}
        datastr.split(',').each do |sb|
          if sb.match?(REG_SIMPLE_MAIL)
            @datar['Mail'] = sb
          elsif sb.match?(/^[HF]$/)
            @datar['Sexe'] = sb
          elsif @datar['Patronyme'].nil?
            @datar['Patronyme'] = sb.strip
          else
            raise ERRORS[:receiver][:invalid_string_data_as_csv] % {data: datastr, substr:sb, patro: @datar['Patronyme']}
          end
        end
        return @datar
      elsif datastr.match?(REG_MAIL_PATRO)
        #
        # Comme "Patronyme <mail>"
        # 
        res = datastr.match(REG_MAIL_PATRO)
        return {'Mail' => res[2], 'Patronyme' => res[1].strip}
      elsif datastr.match?(REG_SIMPLE_MAIL)
        #
        # Comme simple mail
        #
        return {'Mail' => datastr}
      else
        raise ERRORS[:receiver][:invalid_string_data] % {data: datastr}
      end
    end

  end #/<< self

  #
  # Le message final pour le destinataire
  # 
  attr_accessor :message
  
  attr_reader :data
  attr_reader :error

  def initialize(data_init)
    @data = {}
    data_init.each{|k,v| @data.merge!(k.to_s.capitalize => v)}
  end


  # Méthode qui retourne true si les données sont valides
  # Cette méthode ne teste que la validité "générale", en dehors de
  # tout message. Sinon, c'est la méthode valid_for_message? qui 
  # s'occupe du message
  # 
  # Cette méthode renseigne la donnée générale @error avec l'erreur
  # rencontrée
  # 
  def valid?
    @error = nil
    not(mail.nil?)               || raise(ERRORS[:receiver][:requires_mail] % {mail: mail})
    mail.match?(REG_SIMPLE_MAIL) || raise(ERRORS[:receiver][:bad_mail] % {mail: mail})
    unless sexe.nil?
      sexe.match?(/^[HF]$/)      || raise(ERRORS[:receiver][:bad_sexe] % {sexe: sexe})
    end
    return true
  rescue Exception => e
    @error = e.message
    return false
  end


  #
  # === Données accessibles directement ===
  # 

  def mail
    @mail ||= data['Mail']
  end

  def patronyme
    @patronyme ||= begin
      data['Patronyme'] || "#{prenom} #{nom}".strip
    end
  end

  def sexe
    @sexe ||= data['Sexe']||'H'
  end

  # @return "Patronyme <mail>" si possible
  def as_to
    if patronyme
      "#{patronyme} <#{mail}>"
    elsif prenom || nom
      "#{"#{prenom} #{nom}".strip} <#{mail}>"
    else
      mail.dup
    end
  end

  def nom
    @nom ||= (data['Nom'] || data['Lastname'] || (get_nom_from_patronyme if data['Patronyme'])).capitalize
  end
  def prenom
    @prenom ||= data['Prenom'] || data['Firstname'] || (get_prenom_from_patronyme if data['Patronyme'])
  end

private

  #
  # === Méthodes de validité du destinataire
  # 



  #
  # Méthodes pour le patronyme
  # 


  def get_nom_from_patronyme
    return nil if data['Patronyme'].nil?
    decompose_patronyme
    @nom
  end
  def get_prenom_from_patronyme
    return nil if data['Patronyme'].nil?
    decompose_patronyme
    @prenom
  end
  def decompose_patronyme
    segs = data['Patronyme'].split(' ')
    if segs.count == 2
      @prenom, @nom = segs
    else
      sprenom = []
      snom    = []
      segs.each do |seg|
        if seg.match?(/[^A-ZÀÄÂÉÈÊÎÏÔÇÙ\-]/)
          sprenom << seg
        else
          snom << seg
        end
      end
      @prenom = sprenom.join(' ')
      @nom    = snom.join(' ')
    end
  end


end
