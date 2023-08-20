#
# La classe qui gère l'affichage des erreurs (sous forme de "moteur")
# 
require 'tty-box'

ERRORS = YAML.load_file(File.join(APP_FOLDER,'lib','locales',LANG.to_s,'errors.yaml'), symbolize_names: true)

class VPLError < StandardError 
  # @param msg [String] Le message d'erreur
  # 
  # @param box [Symbol|Arrau] 
  # 
  #   C'est la partie du moteur où s'est produit l'erreur. Ça peut 
  #   être une liste de Symbol si plusieurs boites ont été touchés.
  #      
  #   Ça doit être une partie connue, que l'erreur sait afficher (comme
  #   un moteur)
  # 
  # @param options [Hash] Les options d'affichage
  # 
  #   Pour définir par exemple s'il faut donner l'intégralité des 
  #   données, c'est-à-dire le moteur dessiné avec l'endroit où
  #   s'est produit l'erreur ainsi que le backtrace pour retrouver
  #   le lieu exact.
  # 
  def initialize(msg, box, options = nil)
    super(msg)
    @box     = box
    case box
    when Symbol
      MOTOR[box].state = :ko
    when Array
      box.each {|b| MOTOR[b].state = :ko }
    end
    @options = defaultize_options(options)
  end


  # Méthode qui construit le dessin du moteur et le renvoie
  # Elle se sert de la définition du moteur (son plan)
  def draw_motor
    clear
    MOTOR.draw
    puts "\n\n"
    puts message.red
  end
  alias :display :draw_motor


  private

    def defaultize_options(opts)
      opts ||= {}
      opts.key?(:boxes) || opts.merge!(boxes: true)
      opts.key?(:backtrace) || opts.merge!(backtrace: true)
      return opts
    end
end
