require_relative '../test_helper'
require_relative '../required'
require_folder(__dir__)

# # Doit pouvoir recevoir un fichier (path) qui contient les informations nécessaires et suffisantes pour envoyer un mailing-list.
# 

class FileBoxTests < Minitest::Test

  def setup
    super
  end

  def teardown
    
  end

  def test_classe_filebox_existe
    assert defined?(FileBox)
  end

  def test_classe_filebox_respond_to_send
    assert_respond_to FileBox.new, :send
  end

  def test_send_fichier_doit_etre_defini
    msg = assert_raises { FileBox.new.send() }
    assert_equal ERRORS[:file_box][:requires_path], msg.message
  end

  def test_send_fichier_doit_exister
    msg = assert_raises { FileBox.new.send(file: '/bad/path/file.md') }
    assert_equal (ERRORS[:file_box][:file_should_exist] % {path:'/bad/path/file.md'}), msg.message
  end

  def test_fichier_doit_contenir_metadata
    pth = File.join(APP_FOLDER,'assets','tests','files','file_without_metadata.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:requires_metadata] % {path: pth}), msg.message    
  end

  def test_fichier_doit_definir_le_sujet
    pth = File.join(APP_FOLDER,'assets','tests','files','file_without_subject.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:requires_subject] % {path: pth}), msg.message    
  end
  def test_fichier_doit_definir_les_destinataires
    pth = File.join(APP_FOLDER,'assets','tests','files','file_without_receivers.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:requires_receivers] % {path: pth}), msg.message    
  end

  def test_fichier_doit_definir_le_sender
    pth = File.join(APP_FOLDER,'assets','tests','files','file_without_sender.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:requires_sender] % {path: pth}), msg.message
  end

  def test_fichier_doit_bien_definir_les_destinataires
    pth = File.join(APP_FOLDER,'assets','tests','files','file_with_bad_receiver.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:bad_receiver] % {path: pth, receiver:'path/to/bad.file'}), msg.message
  end

  def test_fichier_doit_bien_definir_l_expediteur
    pth = File.join(APP_FOLDER,'assets','tests','files','file_with_bad_sender.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:bad_sender] % {path: pth, sender:'mauvais@expediteur'}), msg.message
  end

  def test_fichier_avec_bon_expediteur
    pth = File.join(APP_FOLDER,'assets','tests','files','file_with_good_sender_only_mail.md')
    msg = assert_silent { FileBox.new.send(file: pth, options: {simulation:true}) }
    pth = File.join(APP_FOLDER,'assets','tests','files','file_with_good_sender.md')
    msg = assert_silent { FileBox.new.send(file: pth, options: {simulation:true}) }
  end

  def test_fichier_doit_avoir_message
    pth = File.join(APP_FOLDER,'assets','tests','files','file_without_message.md')
    msg = assert_raises { FileBox.new.send(file: pth) }
    assert_equal (ERRORS[:file_box][:requires_message] % {path: pth}), msg.message
  end
end
