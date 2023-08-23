require 'clir'

require 'minitest'
if defined?(NO_AUTORUN) && NO_AUTORUN
  # Les tests seront lancés plus tard
else
  require "minitest/autorun"
end
require 'minitest/color'
require 'minitest/reporters'
reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

require 'spy'

# Détruire le fichier log
def reset_supervisor_log
  File.delete(supervisor_log_path) if File.exist?(supervisor_log_path)
end
def supervisor_log_path; @supervisor_log_path ||= File.join(__dir__,'supervisor.log') end

def path_results(filename)
  return File.join(results_folder, filename)
end
def path_expecteds(filename)
  return File.join(expecteds_folder,filename)
end
def remove_results_folder
  Dir["#{results_folder}/**/*"].each{|fpath| File.delete(fpath) unless File.directory?(fpath)}
end
def files_folder
  @files_folder ||= File.join(APP_FOLDER,'assets','tests','files').freeze
end
def results_folder
  @results_folder ||= File.join(APP_FOLDER,'assets','tests','results').freeze
end
def expecteds_folder
  @expecteds_folder ||= File.join(APP_FOLDER,'assets','tests','expecteds')
end
