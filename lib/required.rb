#
# Pour requérir tout ce qui est utile au programme (sauf les boites)
# 
# 
require 'clir'
require 'csv'
require 'yaml'
require 'base64'
require 'kramdown'

require_relative 'Supervisor'
SUPERVISOR << "Lancement programme mailing..."

LANG = 'fr'
APP_FOLDER = File.dirname(__dir__)

require_relative 'constants'
require_relative 'utils'

Dir["#{__dir__}/VPL/**/*.rb"].each{|m|require m}
require_app_folder('lib/FILE-BOX')

# Pour définir le moteur
MOTOR = Motor.instance

MOTOR << MotorBox.new(title: "FILE BOX", name: :file_box, top: 2, left: 2)
MOTOR << MotorBox.new(title: nil, name: :file_box_to_receivers, top:3, height:1, width:7, left: 16)
MOTOR << MotorBox.new(title: "RECEIVERS", name: :receivers, top: 2, left: 23)
MOTOR << MotorBox.new(title: nil, name: :filebox_to_msg_type, top:5, height:3, width:1, left: 8)
MOTOR << MotorBox.new(title: "MSG TYPE BOX", name: :msgtype_box, top: 8, left: 2)
MOTOR << MotorBox.new(title: nil, name: :msgtype_to_mailbox, top:9, height:1, width:4, left: 20)
MOTOR << MotorBox.new(title: nil, name: :receivers_to_mailbox, top:5, height:3, width:1, left: 30)
MOTOR << MotorBox.new(title: "MAIL BOX", name: :mail_box, top: 8, left: 24)
MOTOR << MotorBox.new(title: nil, name: :mail_box_to_sender_box, top:11, height:2, width:1, left: 30)
MOTOR << MotorBox.new(title: nil, name: :loop_receivers_1, top:6, height:1, width:14, left: 32)
MOTOR << MotorBox.new(title: nil, name: :loop_receivers_2, top:7, height:8, width:1, left: 44)
MOTOR << MotorBox.new(title: nil, name: :loop_receivers_3, top:14, height:1, width:12, left: 33)
MOTOR << MotorBox.new(title: "SENDER BOX", name: :sender_box, top: 13, left: 23)
