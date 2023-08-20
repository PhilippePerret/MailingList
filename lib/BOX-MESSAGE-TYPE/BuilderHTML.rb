=begin

  Class BuilderHTML
  -----------------
  C'est la classe qui s'occupe de transformer le message type défini
  dans le fichier de mailing list en un code HTML qui produira le
  meilleur rendu dans les mails.

  Pour un affichage correct, chaque paragraphe est mis dans une
  rangée de table dont le style définit tout ce qu'il faut savoir
  sur la mise en forme

  NOTE
  ----
    On n'utilise plus kramdown pour traiter le code, c'est trop
    compliqué, ça donne un travail en plus.


  FONCTIONNEMENT
  --------------
    - on crée une instance de builder en envoyant l'instance du
      message type
    - on lance sa construction avec builder#build, qui retourne le
      code HTML final où seules sont conservées les variables propres
      aux expéditeurs

=end
class MessageTypeBox
class BuilderHTML

  def initialize(msgtypebox)
    @msgtype_box = msgtypebox
  end

  # Construction du code HTML final
  # @return [HTMLString] Le code complet du message, avec les 
  # variables non remplacées
  def build
    #
    # Entête
    # 
    HTML_HEAD +
    #
    # Ouverture de la table
    # 
    TABLE_OPEN +
    #
    # Traitement de tous les paragraphes
    # 
    paragraphes.collect do |paragraphe|
      "<tr><td style=\"#{td_style}\">" +
      paragraphe
      "</td></tr>"
    end.join("\n") +
    #
    # Fermeture de la table
    # 
    TABLE_CLOSE +
    #
    # Fermeture du code HTML
    # 
    HTML_FOOTER
  end

  def font_family
    @font_family ||= 'Times'
  end

  def font_size
    @font_size ||= '14pt'
  end

  private

    def paragraphes
      @paragraphes ||= begin
        @msgtype_box.raw_code.split("\n\n")
      end
    end

    def td_style
      @td_style ||= TD_STYLE % {
        font_family: font_family,
        font_size:   font_size
      }
    end


TABLE_STYLE = "max-width:840px;width;100%%;"
TABLE_OPEN  = "<table style=\"#{TABLE_STYLE}\">"
TABLE_CLOSE = "</table>"

TD_STYLE = <<-CSS.split("\n").join(';')
text-align:justify
caret-color:rgb(0,0,0)
color:rgb(0,0,0)
font-family:%{font_family},serif
font-size:%{font_size}
font-style:normal
font-variant-caps:normal
font-weight:400
letter-spacing:normal
text-indent:0px
text-transform:none
white-space:normal
orphans:auto
widows:auto
word-spacing:0px
-webkit-text-size-adjust:auto
-webkit-text-stroke-width:0px
text-decoration:none
float:none
CSS

# TR_IN est défini dynamiquement plus haut
TR_OUT  = "</td></tr>".freeze


#    body {max-width:840px;}
HTML_HEAD = <<~HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Contenu du mail</title>
</head>
<body>
HTML

HTML_FOOTER = <<~HTML
</body>
</html>
HTML

end #/class BuilderHTML
end #/MessageTypeBox
