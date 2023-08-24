#
# Test de la boite de message type, qui gère le message en
# tant que message type
# 
# 
require_relative '../test_helper'
require_relative '../required'

class MailBoxTest < Minitest::Test

  def setup
    super
    @mailbox      = nil
    @filebox      = nil
    @filebox_path = nil
    @filebox_name = nil
  end
  
  def teardown
    
  end

  # @instance MailBox pour gérer le mail (sauf l'envoi)
  def mailbox
    @mailbox ||= begin
      MailBox.new(filebox)
    end
  end

  def filebox; @filebox ||= FileBox.new(filebox_path) end
  def filebox_path
    @filebox_path ||= File.join(APP_FOLDER,'assets','tests','files', filebox_name).freeze
  end

  def filebox_name
    @filebox_name || 'bon_mailing_for_mailbox.md'
  end

  # def test_existence_class
  #   assert defined?(MailBox)
  # end

  # def test_existence_methods
  #   assert_respond_to( mailbox, :build_for_receiver)
  # end

  # def test_mailbox_raise_si_manque_variable
  #   @filebox_name = 'mailing_for_mailbox_lake_variable.md'
  #   receiver = Receiver.new({'Mail' => "mon@mail.com", 'Patronyme' => "Prénom ET NOM"})
  #   e = assert_raises { mailbox.build_for_receiver(receiver) }
  #   e.display
  # end

  # def test_mailbox_produit_un_mail_final_avec_un_destinataire
  #   @filebox_name = 'bon_mailing_for_mailbox.md'
  #   receiver = Receiver.new({'Mail' => "mon@mail.com", 'Patronyme' => "Prénom ET NOM", 'Fonction' => "Directeur"})
  #   mail = nil
  #   assert_silent { mail = mailbox.build_for_receiver(receiver) }
  #   refute_nil(mail)
  #   assert_match(/^<\!DOCTYPE html>/, mail)
  #   assert_match(/<html>$/, mail)
  #   assert_match(/Bonjour Monsieur Pr=C3=A9nom ET NOM,/, mail)
  #   assert_match(/la fonction de Directeur/, mail)
  #   # Les images doivent avoir été remplacées
  #   refute_match(/IMGlogo/, mail)
  #   refute_match(/IMGlivre/, mail)
  # end

  # def test_on_peut_utiliser_variables_dans_sujet
  #   @filebox_name = 'mailing_with_sujet_dynamique.md'
  #   receiver = Receiver.new({'Mail' => "mon@mail.com", 'Patronyme' => "Marcel DUCHAMP", 'Fonction' => "Directeur"})
  #   mail = nil
  #   assert_silent { mail = mailbox.build_for_receiver(receiver) }
  #   refute_nil(mail)
  #   weekday = Time.now.strftime('%A')
  #   assert_match("Subject: Bonjour Marcel, nous sommes un #{weekday}, DUCHAMP", mail)
  # end

  def test_on_peut_utiliser_methode_personnalisee_du_destinataire
    #
    # Notez que puisque c'est la méthode @build_for_receiver qui est
    # appelée :
    #   - il faut charger de force le module ruby (qui est chargé
    #     normalement par la méthode FileBox#send)
    #   - le texte n'est pas encore converti en code ISO pour les
    #     mails (on peut donc tester avec les accents)
    # 
    @filebox_name = 'mailing_with_sujet_avec_methode_personnalisee.md'
    filebox.load_own_module
    mail = nil

    receiver = Receiver.new({'Mail' => "mon@mail.com", 'Patronyme' => "Marcel DUCHAMP", 'Fonction' => "Directeur"})
    assert_silent { mail = mailbox.build_for_receiver(receiver) }
    refute_nil(mail)
    assert_match("Subject: Marcel, chanceux, vous êtes dans le 1er groupe", mail)

    receiver = Receiver.new({'Mail' => "autre@mail.com", 'Patronyme' => "Henri PUFOUR", 'Fonction' => "Directeur", 'Sexe' => 'H'})
    assert_silent { mail = mailbox.build_for_receiver(receiver) }
    refute_nil(mail)
    assert_match("Subject: Henri, chanceux, vous êtes dans le 2e groupe", mail)

    receiver = Receiver.new({'Mail' => "henriette@mail.com", 'Patronyme' => "Henriette ZARA", 'Fonction' => "Directrice", 'Sexe' => 'F'})
    assert_silent { mail = mailbox.build_for_receiver(receiver) }
    refute_nil(mail)
    assert_match("Subject: Henriette, chanceuse, vous êtes dans le 3e groupe", mail)

  end


end #/Minitest::Test
