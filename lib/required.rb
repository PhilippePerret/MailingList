#
# Pour requérir tout ce qui est utile au programme (sauf les boites)
# 
# 
require 'csv'
require 'yaml'
require 'base64'
require 'kramdown'

LANG = 'fr'
APP_FOLDER = File.dirname(__dir__)

require_relative 'constants'
require_relative 'utils'

Dir["#{__dir__}/VPL/**/*.rb"].each{|m|require m}


# Pour définir le moteur
MOTOR = Motor.instance

MOTOR << MotorBox.new(title: "FILE BOX", name: :file_box, top: 2, left: 2)
MOTOR << MotorBox.new(title: nil, name: :file_box_to_receivers, top:3, height:1, width:2, left: 16)
MOTOR << MotorBox.new(title: "RECEIVERS", name: :receivers, top: 2, left: 18)
MOTOR << MotorBox.new(title: nil, name: :filebox_to_msg_type, top:5, height:2, width:1, left: 8)
MOTOR << MotorBox.new(title: "MSG TYPE BOX", name: :msgtype_box, top: 7, left: 2)
