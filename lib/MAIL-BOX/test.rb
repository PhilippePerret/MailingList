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
    @mailbox = nil
    @filebox_name = nil
  end
  
  def teardown
    
  end

  # @instance MailBox pour gérer le mail (sauf l'envoi)
  def mailbox
    @mailbox ||= begin
      filebox = FileBox.new(filebox_path)
      MailBox.new(filebox)
    end
  end

  def filebox_path
    @filebox_path ||= File.join(APP_FOLDER,'assets','tests','files', filebox_name).freeze
  end

  def filebox_name
    @filebox_name || 'bon_mailing_for_mailbox.md'
  end

  def test_existence_class
    assert defined?(MailBox)
  end

  def test_existence_methods
    assert_respond_to( mailbox, :build_for_receiver)
  end

  def test_mailbox_raise_si_manque_variable
    @filebox_name = 'mailing_for_mailbox_lake_variable.md'
    receiver = Receiver.new({'Mail' => "mon@mail.com", 'Patronyme' => "Prénom ET NOM"})
    e = assert_raises { mailbox.build_for_receiver(receiver) }
    e.display
  end

  def test_mailbox_produit_un_mail_final_avec_un_destinataire
    @filebox_name = 'bon_mailing_for_mailbox.md'
    receiver = Receiver.new({'Mail' => "mon@mail.com", 'Patronyme' => "Prénom ET NOM", 'Fonction' => "Directeur"})
    mail = nil
    assert_silent { mail = mailbox.build_for_receiver(receiver) }
    refute_nil(mail)
    assert_match(/^<\!DOCTYPE html>/, mail)
    assert_match(/<html>$/, mail)
    assert_match(/Bonjour Monsieur Prénom ET NOM,/, mail)
    assert_match(/la fonction de Directeur/, mail)
    # Les images doivent avoir été remplacées
    refute_match(/IMGlogo/, mail)
    refute_match(/IMGlivre/, mail)
  end




end #/Minitest::Test
