require_relative '../test_helper'
require_relative '../required'
require_relative 'Markdown'
require_folder(File.join(APP_FOLDER,'lib','FILE-BOX'))
require_folder(__dir__)

class MarkdownStringTest < Minitest::Test

  def setup
    super
  end
  def teardown
  end

  #
  # Pour générer une instance de paragraphe
  # 
  def newpar(str)
    MessageTypeBox::MarkdownString.new(msgtype, str)
  end

  def msgtype
    @msgtype ||= begin
      filebox = FileBox.new(File.join(APP_FOLDER,'assets','tests','files','bon_file_mailing.md'))
      MessageTypeBox.new(filebox).tap do |mtb|
        mtb.paragraphes
      end
    end
  end

  def test_retour_chariot
    par = newpar("Un\nretour\r\nchariot.")
    expected = "Un<br />retour<br />chariot."
    assert_equal(expected, par.to_html)
  end

  def test_liste_simple
    par = newpar("* item un\n* item deux\n* item trois")
    expected = "<ul><li>item un</li><li>item deux</li><li>item trois</li></ul>"
    assert_equal(expected, par.to_html)
  end

  def test_liste_numerotee
    par = newpar("1. item un\n* item deux\n* item trois")
    expected = "<ol><li>item un</li><li>item deux</li><li>item trois</li></ol>"
    assert_equal(expected, par.to_html)
  end

  def test_gras
    par = newpar("**Pour voir** et **un autre***.")
    assert_equal('<b>Pour voir</b> et <b>un autre</b>*.', par.to_html)
  end

  def test_gras_multilignes
    par = newpar("Je vais **voir du gras.\nSur plusieurs lignes** et **un autre**.")
    assert_equal("Je vais <b>voir du gras.<br />Sur plusieurs lignes</b> et <b>un autre</b>.", par.to_html)
  end

  def test_italic
    par = newpar("*Pour voir* et *un autre**.")
    assert_equal('<em>Pour voir</em> et <em>un autre</em>*.', par.to_html)
  end

  def test_italic_multilignes
    par = newpar("Je vais *voir du gras.\nSur plusieurs lignes* et *un autre*.")
    assert_equal("Je vais <em>voir du gras.<br />Sur plusieurs lignes</em> et <em>un autre</em>.", par.to_html)
  end

  def test_underline
    par = newpar("_Pour voir_ et _un autre_*.")
    assert_equal('<u>Pour voir</u> et <u>un autre</u>*.', par.to_html)
  end

  def test_underline_multilignes
    par = newpar("Je vais _voir du gras.\nSur plusieurs lignes_ et _un autre_.")
    assert_equal("Je vais <u>voir du gras.<br />Sur plusieurs lignes</u> et <u>un autre</u>.", par.to_html)
  end

  def test_alink
    par = newpar("Un [lien vers url](https://www.atelier-icare.net) et un [autre lien](https://google.com) pour voir.")
    expected = "Un <a href=\"https://www.atelier-icare.net\">lien vers url</a> et un <a href=\"https://google.com\">autre lien</a> pour voir."
    assert_equal(expected, par.to_html)
  end

  def test_variable_et_pourcentage
    par = newpar("%. Un %, un %% et une %{variable}.%")
    expected = "%%. Un %%, un %% et une %{variable}.%%"
    assert_equal(expected, par.to_html)
  end

  def test_code_ruby
    par = newpar("\#{'pour'.upcase} voir que 2 + 2 = \#{2+2}.")
    expected = "POUR voir que 2 + 2 = 4."
    assert_equal(expected, par.to_html)
  end

  def test_class_css
    par = newpar("un <span class=\"red\">texte rouge</span> et <span class=\"green\">vert</span>.")
    expected = "un <span style=\"color:red;font-weight:bold;\">texte rouge</span> et <span style=\"color:green;font-weight:bold;\">vert</span>."
    assert_equal(expected, par.to_html)
  end

  def test_par_selector_customised
    roug = "color:red;font-weight:bold;"
    vert = "color:green;font-weight:bold;"
    par = newpar("<red>En rouge</red> et <green>en vert</green> et <red>autre rouge</red>.")
    expected = "<span style=\"#{roug}\">En rouge</span> et <span style=\"#{vert}\">en vert</span> et <span style=\"#{roug}\">autre rouge</span>."
    assert_equal expected, par.to_html
  end

  def test_titres
    par = newpar("# Un titre simple")
    expected = "<h1>Un titre simple</h1>"
    assert_equal(expected, par.to_html)
  end

  def test_titre_avec_style_propre
    par = newpar("## Titre trop stylé")
    expected = "<h2 style=\"color:ocre;\">Titre trop stylé</h2>"
    assert_equal(expected, par.to_html)
  end
end
