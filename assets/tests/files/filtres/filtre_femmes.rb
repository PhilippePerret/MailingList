class Mailing
  def self.filtre_femmes(recipients)
    recipients.reject do |recipient|
      recipient.sexe == 'H'
    end
  end
end
