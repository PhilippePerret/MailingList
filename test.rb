#
# Pour lancer tous les tests
# 
# Ouvrir une console Terminal au dossier et jouer :
#   ruby ./test.rb
# 
require 'clir'
require_relative './lib/required'
NO_AUTORUN = true
require_relative './lib/test_helper'

tests = Dir["#{APP_FOLDER}/lib/**/test*.rb"].collect do |t|
  relpath = t.sub(/^#{APP_FOLDER}/,'')
  STDOUT.write "🔬 Test #{relpath}\n".gris
  require t
  relpath
end.compact

Minitest.run
# 
# 
STDOUT.write <<-TXT.gris
----------------------------------------
Fichiers Test joués (#{tests.count}) :
- #{tests.join("\n- ")}
TXT
