#
# Test de la boite de message type, qui gère le message en
# tant que message type
# 
# 
require_relative '../test_helper'
require_relative '../required'
require_folder(File.join(APP_FOLDER,'lib','FILE-BOX'))
require_folder(__dir__)

BON_MAILING_PATH = File.join(APP_FOLDER,'assets','tests','files','bon_file_mailing.md')

class MessageTypeBoxTest < Minitest::Test

  def setup
    super
  end
  def teardown
    
  end


  # L'instance testée
  def msgtype
    @msgtype ||= begin
      filebox = FileBox.new(BON_MAILING_PATH)
      MessageTypeBox.new(filebox)
    end
  end


  def test_classe_exist
    assert defined?(MessageTypeBox)
  end

  def test_la_boite_repond_a_raw_code
    allcode = File.read(BON_MAILING_PATH)[10..-1]
    dec = allcode.index('---')
    rawcode_real = allcode[dec+3..-1].strip
    STDOUT.write "rawcode_real:#{rawcode_real.inspect}".orange
    # --- Test ---
    assert_respond_to msgtype, :raw_code
    rawcode = msgtype.raw_code
    # --- Vérification ---
    assert_equal rawcode_real, rawcode
  end

  def test_la_boite_doit_definir_les_variables
    assert_respond_to msgtype, :variables
    vars = msgtype.variables
    assert_includes vars, 'Patronyme'
    assert_includes vars, 'Var1'
  end

  def test_la_boite_doit_definir_les_images
    assert_respond_to msgtype, :images
    imgs = msgtype.images
    assert_includes imgs, 'IMGlogo'
    assert_includes imgs, 'IMGlivre'
  end

  def test_doit_repondre_a_check_pour_verifier_la_validite
    assert_respond_to msgtype, :check
  end

  def test_les_images_doivent_etre_definies
    filebox = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_manque_une_image.md'))
    msgbox = MessageTypeBox.new(filebox)
    e = assert_raises { msgbox.check }
    e.display
    assert_equal(ERRORS[:messageType][:unknown_image] % {key: 'IMGLogo'}, e.message)
  end

  def test_les_images_doivent_exister
    filebox = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','file_image_introuvable.md'))
    unfound_path = File.join(APP_FOLDER,'assets','tests','files','images','bad_path_livre.jpg')
    msgbox = MessageTypeBox.new(filebox)
    e = assert_raises { msgbox.check }
    e.display
    err = ERRORS[:messageType][:unfound_image] % {path: unfound_path, key: 'IMGlivre'}
    assert_equal(err, e.message)
  end



end #/Minitest::Test
