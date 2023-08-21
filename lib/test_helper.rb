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
