class NonMailing
  def self.filtre_sans_classe_mailing(recipients)
    recipients.reject do |recipient|
      recipient.sexe == 'H'
    end
  end
end
