#
# Test de la boite Receivers qui gère tous les destinataires
# 
require_relative '../test_helper'
require_relative '../required'
require_folder(File.join(APP_FOLDER,'lib','FILE-BOX'))
require_folder(__dir__)


class ReceiversBoxTest < Minitest::Test

  def setup
    super
  end

  def teardown
    
  end

  def receivers
    @receivers ||= begin
      filebox = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','bon_file_mailing.md'))
      receivers = ReceiversBox.new(filebox)
    end
  end

  #
  # === TESTS AVEC UN FICHIER CSV ===
  # 


  def test_doit_definir_la_classe_receiver
    assert defined?(Receiver)
  end
  def test_doit_definir_la_classe_receivers
    assert defined?(ReceiversBox)
  end

  #
  # === Quand les destinataires sont définis dans un fichier CSV ===
  # 

  def test_doit_recevoir_un_csv_existant
    pth = '/bad/file/path.csv'
    e = assert_raises { receivers.get_from_csv(pth) }
    e.display
    assert_equal (ERRORS[:receivers][:unknown_file] % {path:pth}), e.message
  end

  def test_doit_recevoir_un_csv
    pth = File.join(APP_FOLDER,'assets','tests','files','bon_file_mailing.md')
    e = assert_raises { receivers.get_from_csv(pth) }
    e.display
    assert_equal (ERRORS[:receivers][:bad_extension] % {path:pth}), e.message
  end

  def test_on_doit_pouvoir_obtenir_la_liste_dun_fichier
    pth = File.join(APP_FOLDER,'assets','tests','files','bons.csv')
    assert_silent { receivers.get_from_csv(pth) }
  end

  def test_un_fichier_csv_doit_definir_la_donnee_mail
    pth = File.join(APP_FOLDER,'assets','tests','files','bad_no_data_mail.csv')
    e = assert_raises { receivers.get_from_csv(pth) }
    e.display
    assert_equal ERRORS[:receivers][:file_requires_header] % {path:pth}, e.message
  end

  def test_un__csv_avec_bad_mail_produit_une_erreur
    pth = File.join(APP_FOLDER,'assets','tests','files','receiver_with_bad_mail.csv')
    e = assert_raises { receivers.get_from_csv(pth) }
    e.display
    data_receiver = "{\"Patronyme\"=>\"Mauvais DESTINATAIRE\", \"Mail\"=>\"bad@mail\", \"Sexe\"=>\"H\", \"Fonction\"=>nil, \"Ville\"=>\"Nancy\"}"
    err = ERRORS[:receivers][:bad_receiver_in_file] % {path:pth, receiver:data_receiver, error:(ERRORS[:receiver][:bad_mail] % {mail: 'bad@mail', path:pth})}
    assert_equal err, e.message
  end
  def test_un__csv_avec_bad_sexe_produit_une_erreur
    pth = File.join(APP_FOLDER,'assets','tests','files','receiver_with_bad_sexe.csv')
    e = assert_raises { receivers.get_from_csv(pth) }
    e.display
    data_receiver = "{\"Patronyme\"=>\"Mauvais DESTINATAIRE\", \"Mail\"=>\"goodmail@chez.lui\", \"Sexe\"=>\"X\", \"Fonction\"=>nil, \"Ville\"=>\"Nancy\"}"
    err = ERRORS[:receivers][:bad_receiver_in_file] % {path:pth, receiver:data_receiver, error:(ERRORS[:receiver][:bad_sexe] % {sexe: 'X', path:pth})}
    assert_equal err, e.message
  end

  # 
  # === DESTINATAIRES DÉFINIS DANS UNE LISTE ===
  #
  
  def test_definit_bien_les_destinataires_quand_tout_est_ok
    pth = File.join(APP_FOLDER,'assets','tests','files','bons.csv')
    # On vérifie en même temps tous les destinataires possibles
    liste = "[{mail:'sonmail@chez.lui',patronyme:'Sony PATRY'},'monmail@chez.lui', '#{pth}', 'Avec PATRO <autremail@chez.lui>', 'Patro,F,unefemme@chez.elle','autreordre@mail.com,H,Bruno']"
    assert_silent { receivers.get_from_list(eval(liste)) }
    rs = receivers.receivers
    assert_equal 7, rs.count
    mails = rs.collect { |r| r.mail }
    assert_includes mails, 'sonmail@chez.lui'
    assert_includes mails, 'monmail@chez.lui'
    assert_includes mails, 'philper@yaho.fr'
    assert_includes mails, 'marion.michel33@free.fr'
    assert_includes mails, 'autremail@chez.lui'
    assert_includes mails, 'unefemme@chez.elle'
    assert_includes mails, 'autreordre@mail.com'
  end

  #
  # === TRAITEMENT DES EXCLUSIONS ===
  # 

  def test_on_peut_exclure_des_destinataires_avec_exclude
    # filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_avec_exclusions.md'))
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_par_csv_avec_exclusions.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(1, receivers.receivers.count)
    assert_equal('marion.michel33@free.fr', receivers.receivers.first.mail)
    assert_equal('Marion MICHEL', receivers.receivers.first.patronyme)
  end

  def test_liste_explicite_avec_exclusion_explicite
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_avec_exclusion.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(3, receivers.receivers.count)
    mails = receivers.receivers.collect{|r| r.mail}
    assert_includes(mails, 'un@chez.lui')
    assert_includes(mails, 'deux@chez.lui')
    assert_includes(mails, 'quatre@chez.lui')
  end
  def test_liste_explicite_avec_exclusions_explicites
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_avec_exclusions.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(2, receivers.receivers.count)
    mails = receivers.receivers.collect{|r| r.mail}
    assert_includes(mails, 'deux@chez.lui')
    assert_includes(mails, 'un@chez.lui')
  end
  def test_liste_explicite_avec_exclusions_par_csv
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_avec_out_par_csv.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(1, receivers.receivers.count)
    assert_equal('marion.michel@free.fr', receivers.receivers.first.mail)
    assert_equal('Marion MICHEL', receivers.receivers.first.patronyme)
  end

  def test_par_csv_avec_exclusion_explicite
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_par_csv_avec_exclusion.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(1, receivers.receivers.count)
    assert_equal('marion.michel33@free.fr', receivers.receivers.first.mail)
    assert_equal('Marion MICHEL', receivers.receivers.first.patronyme)
  end

  def test_par_csv_avec_exclusions_explicites
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_par_csv_avec_exclusions.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(1, receivers.receivers.count)
    assert_equal('marion.michel33@free.fr', receivers.receivers.first.mail)
    assert_equal('Marion MICHEL', receivers.receivers.first.patronyme)
  end

  def test_par_csv_avec_out_par_csv
    filebox   = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_par_csv_avec_out_par_csv.md'))
    receivers = ReceiversBox.new(filebox)
    assert_equal(2, receivers.receivers.count)
    assert_equal('marion.michel33@free.fr', receivers.receivers.first.mail)
    assert_equal('Marion MICHEL', receivers.receivers.first.patronyme)
    assert_equal('ajouted@chez.lui', receivers.receivers[1].mail)
    assert_equal('Ajouté', receivers.receivers[1].patronyme)
  end

end #/Minitest::Test
