=begin
# Une class de superviseur qui permet de surveiller tout le 
# programme. À la base, il a été fait pour enregistrer les backtraces
# des messages d'erreur.
# 
# ON se sert de :
# 
#   SUPERVISOR
# 
#     SUPERVISOR.fatal_error
#     SUPERVISOR.minor_error
# 
=end
require 'singleton'
class Supervisor
  include Singleton
  def fatal_error(err, err_num = 1)
    add("FATAL ERROR : #{e.message}\n#{TAB}" + e.backtrace.join("\n#{TAB}"))
    STDOUT.write "Une erreur fatale est survenue. Consulter le fichier #{path}.".rouge
    exit err_num
  end
  def add(msg) # alias :<<
    msg = msg.join("\n#{TAB}") if msg.is_a?(Array)
    cmd = <<~CODE.strip
    cat <<EOT >> #{path}
    #{now_formated} -- #{msg}
    EOT
    CODE
    `#{cmd}`
  end
  alias :<< :add


  def open_manuel(mode_edition)
    if mode_edition
      `open -a Typora "#{manual_path_md}"`
    else
      `open "#{manual_path_pdf}"`
    end
  end
  def manual_path_md; File.join(APP_FOLDER,'Manuel','Manuel.md') end
  def manual_path_pdf; File.join(APP_FOLDER,'Manuel','Manuel.pdf') end

  def open_mailing_file(mail_file_path)
    mail_file_path = File.expand_path(mail_file_path)
    if File.exist?(mail_file_path)
      `open -a Typora "#{mail_file_path}"`
    else
      puts "Le fichier #{mail_file_path.inspect} est introuvable…".rouge
    end
    
  end



  def now_formated
    Time.now.strftime(TIME_FMT)
  end
  def path
    @path ||= File.join(__dir__,'supervisor.log').freeze
  end
  TIME_FMT = '%d %m %Y %H:%M:%S'
  TAB = ' ' * (Time.now.strftime(TIME_FMT).length + 4)
end

SUPERVISOR = Supervisor.instance
