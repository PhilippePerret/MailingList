require_relative '../test_helper'
require_relative '../required'
require_folder(File.join(APP_FOLDER,'lib','FILE-BOX'))

class MailingReportTest < Minitest::Test

  def setup
    super
    @report = nil
  end

  def report
    @report ||= begin
      filebox = FileBox.new(filebox_path)
      MailingReport.new(filebox)
    end
  end

  def filebox_path
    @filebox_path ||= File.join(APP_FOLDER,'assets','tests','files', filebox_name).freeze
  end
  def filebox_name;@filebox_name || 'bon_mailing_for_mailbox.md' end

  def test_respond_to_methods
    assert_respond_to( report, :display_report)
    assert_respond_to( report, :add)
    assert_respond_to( report, :<<)
    assert_respond_to( report, :start)
    assert_respond_to( report, :stop)
    assert_respond_to( report, :set_ok)
  end

  def test_add_ligne_de_rapport
    line = "Une ligne simple de rapport"
    report << line
    assert_includes report.lines, line
  end

  def test_display_report
    debut = Time.now.freeze
    report.start
    report << "Une première ligne"
    sleep 2
    fin = Time.now.freeze
    report.stop
    # --- Test ---
    out, err = capture_io do 
      report.display_report
    end
    assert_match("Une première ligne", out)
    assert_match("Début : #{debut.strftime('%H:%M:%S')}", out)
    assert_match("Fin : #{fin.strftime('%H:%M:%S')}", out)
    refute_match(ERRORS[:report][:mailing_succeeded], out)
    assert_match(ERRORS[:report][:mailing_failed], out)

    STDOUT.write(out + "\n")
  end

  def test_bon_message_si_succes
    report.start
    report.set_ok
    report.stop
    # --- Test ---
    out, err = capture_io { report.display_report } 
    # --- Vérification ---
    assert_match(ERRORS[:report][:mailing_succeeded], out)
    refute_match(ERRORS[:report][:mailing_failed], out)
  end

end #/class Minitest
