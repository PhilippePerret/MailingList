# Pour tester le filtrage
# 
# 
require_relative '../test_helper'
require_relative '../required'

class FiltreDestinatairesTest < Minitest::Test

  def setup
    super
    @filebox_path
    @filebox_name
    @filebox
    reset_supervisor_log
  end
  def teardown
    
  end

  def filebox
    @filebox ||= FileBox.new(filebox_path)
  end
  def filebox_path
    @filebox_path ||= File.join(APP_FOLDER,'assets','tests','files', filebox_name).freeze
  end
  def filebox_name; @filebox_name end


  def test_on_peut_filtrer_par_filtre_simple
    @filebox_name = 'mailing_filtrage_femme.md'
    # --- Test ---
    filebox.send({delay: false, simulation: true})
    # --- Vérification des adresses touchées ---
    # (on lit le fichier log qui a été détruit au début de l'opération)
    log = File.read(supervisor_log_path)
    # puts "log = \n#{log}"
    assert_match('Mail sent to marion.michel@free.fr', log)
    assert_match('Mail sent to autre.femme@gmail.com', log)
    refute_match('Mail sent to invited@gmail.com', log)
    refute_match('Mail sent to philper@yahooo.fr', log)
  end

  def test_filtre_avec_fichier_inconnu
    @filebox_name = "mailing_filtre_inconnu.md"
    e = assert_raises { filebox.send({ delay:false, simulation:true}) }
    e.display
    assert_equal (ERRORS[:filter][:file_unfound] % {path:File.join(files_folder,'filtres/manquant.rb')}), e.message
  end

  # # On ne peut pas le tester, car si un autre test charge avant la
  # # class Mailing, elle existera pour le programme
  # def test_filtre_qui_ne_definit_pas_la_classe_Mailing
  #   @filebox_name = "mailing_filtre_sans_classe_mailing.md"
  #   e = assert_raises { filebox.send({ delay:false, simulation:true}) }
  #   e.display
  #   assert_equal (ERRORS[:filter][:undefined_class_mailing] % {
  #     path:File.join(files_folder,'filtres/filtre_sans_class_mailing.rb')
  #   }), e.message
  # end

  def test_filtre_qui_ne_definit_pas_la_methode_de_filtre
    @filebox_name = "mailing_filtre_sans_methode.md"
    e = assert_raises { filebox.send({ delay:false, simulation:true}) }
    e.display
    assert_equal (ERRORS[:filter][:undefined_method_filter] % {
      path:File.join(files_folder,'filtres/filtre_sans_methode.rb'),
      name: 'filtre_sans_methode'
    }), e.message
  end

  def test_methode_de_filtre_qui_ne_recoit_pas_le_bon_nombre_d_arguments
    @filebox_name = "mailing_filtre_avec_bad_arity.md"
    e = assert_raises { filebox.send({ delay:false, simulation:true}) }
    e.display
    assert_equal (ERRORS[:filter][:bad_arguments_count] % {
      path:File.join(files_folder,'filtres/filtre_bad_arity.rb'),
      name: 'filtre_bad_arity',
      nb_args_method: 5, 
      nb_args_sent: 1
    }), e.message
  end

end
