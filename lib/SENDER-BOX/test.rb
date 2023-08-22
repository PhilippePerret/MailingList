require_relative '../test_helper'
require_relative '../required'
require_box_folder('lib/FILE-BOX')
require_box_folder('lib/RECEIVERS-BOX')
require_box_folder('lib/BOX-MESSAGE-TYPE')
require_box_folder(__dir__)


class SenderBoxTest < Minitest::Test

  def self.set(what, mail)
    @@whats ||= {}
    @@whats.merge!(what => mail)
  end
  def self.get(what)
    return @@whats[what]
  end

  Spy.on_instance_method(SenderBox, :proceed_sending).and_return do |msg,sender,recipient|
    SenderBoxTest.set(:expediteur,  sender)
    SenderBoxTest.set(:recipient,   recipient)
    SenderBoxTest.set(:message,     msg)
    true
  end
  Spy.on_instance_method(SenderBox, :proceed_simulation).and_return do |msg,sender,recipient|
    SenderBoxTest.set(:expediteur,  sender)
    SenderBoxTest.set(:recipient,   recipient)
    SenderBoxTest.set(:message,     msg)
    true
  end

  def setup
    super
    @senderbox    = nil
    @filebox      = nil
    @filebox_name = nil
    @filebox_path = nil

    @expediteur = @destinataire = @message = nil

    remove_results_folder

  end
  def teardown
    
  end

  # @instance SenderBox pour gérer le mail (sauf l'envoi)
  def senderbox
    @senderbox ||= begin
      SenderBox.new(filebox)
    end
  end

  def filebox
    @filebox ||= FileBox.new(filebox_path)
  end

  def filebox_path
    @filebox_path ||= File.join(APP_FOLDER,'assets','tests','files', filebox_name).freeze
  end

  def filebox_name
    @filebox_name || 'bon_mailing_simple.md'
  end


  # def test_respond_to_methods
  #   assert_respond_to senderbox, :send_to
  #   assert_respond_to senderbox, :proceed_sending
  # end

  # def test_pas_denvoi_si_pas_de_message_pour_destinataire
  #   mail = "monmail@chez.lui"
  #   destinataire = Receiver.new({'Mail' => mail, 'Patronyme' => "Phil Ackerman"})
  #   e = assert_raises { senderbox.send_to(destinataire) }
  #   e.display
  #   assert_equal(ERRORS[:sender][:receiver_without_message] % {mail:mail}, e.message)
  # end

  # def test_method_send_to_envoie_le_message
  #   message_template = "<p>Bonjour %{Nom}, c'est un message tout simple</p>"
  #   destinataire = Receiver.new({'Mail' => "monmail@chez.lui", 'Nom' => "Phil Ackerman"})
  #   # Avant de pouvoir envoyer le message, il faut le fabriquer pour le destinataire
  #   destinataire.message = message_template % {Nom: destinataire.data['Nom']}
  #   # --- Test ---
  #   assert_silent{ senderbox.send_to(destinataire) }
  #   # --- Vérification ---
  #   assert_equal('philper@yahooo.fr', SenderBoxTest.get(:expediteur))
  #   assert_equal('monmail@chez.lui', SenderBoxTest.get(:recipient))
  #   assert_equal('<p>Bonjour Phil Ackerman, c\'est un message tout simple</p>', SenderBoxTest.get(:message))

  #   @expediteur = @destinataire = @message = nil
  #   destinataire = Receiver.new({'Mail' => "autremail@chez.lui", 'Nom' => "Ben Ackerman"})
  #   destinataire.message = message_template % {Nom: destinataire.data['Nom']}
  #   # --- Test ---
  #   assert_silent{ senderbox.send_to(destinataire) }
  #   # --- Vérification ---
  #   assert_equal('philper@yahooo.fr', SenderBoxTest.get(:expediteur))
  #   assert_equal('autremail@chez.lui', SenderBoxTest.get(:recipient))
  #   assert_equal('<p>Bonjour Ben Ackerman, c\'est un message tout simple</p>', SenderBoxTest.get(:message))
  # end

  # def test_envoi_reel
  #   # Un test pour envoyer vraiment à partir d'un fichier
  #   # 
  #   @filebox_name = 'bon_mailing_simple.md'
  #   # --- Test ---
  #   # assert_silent { filebox.send }
  #   out, err = capture_io { filebox.send }

  #   # STDOUT.write "out = #{out.inspect}\n"

  #   # --- Vérifications ---
  #   message = SenderBoxTest.get(:message)
  #   assert_equal('philper@yahooo.fr',       SenderBoxTest.get(:expediteur))
  #   assert_equal('phil@atelier-icare.net',  SenderBoxTest.get(:recipient))
  #   assert_match("Bonjour Monsieur Phil Ackerman,", message)
  #   assert_match("- Envoi du mail à phil@atelier-icare.net", out)
  #   assert_match("Mailing-list envoyé avec succès", out)

  #   # --- Pour le voir et le comparer ---
  #   # On enregistre le message dans un fichier
  #   fpath_actual = path_results("test_simple-#{Time.now.to_i}.html")
  #   File.open(fpath_actual,'wb'){|f|f.write(SenderBoxTest.get(:message))}
  #   fpath_expected = path_expecteds("test_simple.html")
  #   # Les deux fichiers doivent être identiques
  #   assert FileUtils.identical?(fpath_expected, fpath_actual)

  # end

  def test_envoi_complexe
    #
    # Cet envoi est dit "complexe" parce que :
    # - il est envoyé à plusieurs destinataires
    # - plusieurs destinataires sont exclus
    # - il y a tous les types de formatage markdown
    # - il y a des images
    # - il y a des variables définies dans le fichier .csv
    # - il y a du code ruby
    # - il y a des styles définis
    # - Des options sont définies
    # 
    @filebox_name = "bon_mailing_complexe.md"

    # --- Test ---
    options = {simulation: true, delay: false}
    out, err = capture_io { filebox.send(**options) }

    # --- Vérifications ---
    # On enregistre le message dans un fichier
    fname_actual = "test_complexe-#{Time.now.to_i}.eml"
    fpath_actual = path_results(fname_actual)
    File.open(fpath_actual,'wb'){|f|f.write(SenderBoxTest.get(:message))}
    fpath_expected = path_expecteds("test_complexe.eml")
    # Les deux fichiers doivent être identiques
    assert FileUtils.identical?(fpath_expected, fpath_actual), "Le message produit pour le message complexe (results/#{fname_actual})\ndevrait correspondre à celui attendu (test_complexe.html)"
    
  end


end #/class Minitest
