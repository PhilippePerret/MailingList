#
# Interpréteur simplifié de Markdown vers HTML
# 
class MessageTypeBox
class MarkdownString

  # Instanciation du paragraphe markdown
  # 
  # @param raw_markdown [String]
  # 
  #   Le code markdown à interprété. C'est un "paragraphe" au sens
  #   markdown du terme, c'est-à-dire qu'il peut contenir des 
  #   retour chariot, mais seulement un seul à la fois (les paragraphes
  #   markdown sont justement séparés par des doubles retour chariot)
  # 
  # @param messagebox [MessageTypeBox]
  # 
  #   L'instance propriétaire du texte contenant le message complet
  #   et donc le paragraphe.
  #   Elle définit notamment @selectors qui contient la définition
  #   des sélectors CSS, avec en clé leur nom utilisés dans les
  #   'class="<selector>"'.
  # 
  def initialize(messagebox, raw_markdown)
    @messagebox   = messagebox
    @raw_markdown = raw_markdown.freeze
  end

  # Transforme le code markdown en code HTML
  def to_html
    
    c = @raw_markdown.dup

    # Liste
    c = traite_liste_in(c) if c.match?(/^([\*\-]|1\.) /)

    # Gras
    c = c.gsub(/\*\*(.*?)\*\*/m, '<b>\1</b>')

    # Italic
    c = c.gsub(/\*(.*?)\*/m, '<em>\1</em>')

    # Souligné
    c = c.gsub(/_(.*?)_/m, '<u>\1</u>')

    # aLink
    c = c.gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')

    # Code ruby
    c = c.gsub(/#\{(.+?)\}/) { eval($1) }

    # Le signe %
    c = c.gsub(/(\A|[^%{])\%([^%{]|\Z)/, '\1%%\2')

    # les classes CSS
    c = c.gsub(/ class=\"(.+?)\"/) { " style=\"#{get_code_css_of_selector($1)}\""}

    # Les retours chariot
    c = c.gsub(/\r?\n/, '<br />')

    return c
  end

  # Traitement de la liste que contient le paragraphe
  # 
  # @param md [String]
  # 
  #   Le code du paragraphe actuellement
  # 
  # @return [String] La code HTML de la liste mise en forme au niveau
  # de la liste
  def traite_liste_in(md)
    selector = md.start_with?('1.') ? 'ol' : 'ul'
    md = md.gsub(/^([\*\-]|1\.) (.*)$/, '<li>\2</li>')
    return "<#{selector}>" + md.gsub(/\r?\n/,'') + "</#{selector}>"
  end

  def get_code_css_of_selector(selector)
    @messagebox.selectors[selector]
  end

end #/class MarkdownString
end #/class MessageTypeBox
