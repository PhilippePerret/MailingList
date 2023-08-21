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

    # Titre
    c = traite_as_titre(c) if c.match?(/^\#{1,7} /)

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

    # On termine en remplaçant tous les sélecteurs qui peuvent
    # rester
    c = remplace_all_selectors(c)

    return c
  end

  # Remplacement des sélecteurs personnalités
  # 
  # @rappel
  #   Dans le fichier mailing, ils sont définis dans le texte, par
  #   des noms de sélecteurs précédés par des '.'
  #   Par exemple '.monselecteur'
  #   Dans le texte, on peut utiliser 
  #     soit : '<span class="monselecteur">Le texte</span>'
  #     soit : '<monselecteur>Le texte</monselecteur>'
  #   C'est le deuxième qu'on doit remplacer ici
  # 
  # 
  def remplace_all_selectors(md)
    @messagebox.selectors.each do |selector, definition|
      md = md.gsub(/<#{selector}>(.+?)<\/#{selector}>/) {
        "<span style=\"#{definition}\">#{$1}</span>"
      }
    end
    return md
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

  def traite_as_titre(md)
    md = md.gsub(/^(\#{1,7}) (.*?)$/) {
      mark  = $1.freeze
      titre = $2.strip.freeze
      tag   = "h#{mark.length}"
      style = @messagebox.selectors[tag]
      if style.nil?
        "<#{tag}>#{titre}</#{tag}>"
      else
        "<#{tag} style=\"#{style}\">#{titre}</#{tag}>"
      end
    }
    return md
  end

  def get_code_css_of_selector(selector)
    @messagebox.selectors[selector]
  end

end #/class MarkdownString
end #/class MessageTypeBox
