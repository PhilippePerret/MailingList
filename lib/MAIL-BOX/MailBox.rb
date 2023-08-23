require_relative '../feminines'
class MailBox

  def initialize(filebox)
    @filebox = filebox
  end

  # = main =
  # 
  # Construit le message final (à envoyer) pour le destinataire
  # +receiver+
  # 
  # @param receiver [Receiver]
  # 
  #   Le destinataire du message final.
  # 
  def build_for_receiver(receiver)
    #
    # Pour mettre toutes les variables 
    # (propres au message et féminines)
    # 
    table_valeurs = {}

    #
    # On ajoute les féminines
    # 
    table_valeurs.merge!(FEMININES[receiver.sexe])

    #
    # Le destinataire doit répondre à toutes les variables
    # (sinon une erreur fatale est produite)
    # 
    @boxes = [:mail_box, :receivers] # pour l'erreur
    variables.each do |variable|
      next if table_valeurs.key?(variable.to_sym) # Une féminine
      receiver.data.key?(variable) || raise(ERRORS[:receiver][:requires_variable] % {var:variable, mail:receiver.mail})
      table_valeurs.merge!(variable.to_sym => receiver.data[variable])
    end

    #
    # On peut remplacer les variables pour finaliser le message
    # et le retourner
    # 
    # @noter
    #   Qu'il faut que dans table_valeurs les clés soient des
    #   Symbols, pas des strings.
    # 
    @boxes = :mail_box # pour l'erreur
    body_html = body_html_template % table_valeurs
    body_text = body_text_template % table_valeurs
    if false
      SUPERVISOR << "body_html = #{body_html}"
      SUPERVISOR << "body_text = #{body_text}"
    end

    mail_final = Mail::assemble(receiver, body_html, body_text, @filebox.metadata)

    if false
      SUPERVISOR << ["mail_final pour #{receiver.mail}", mail_final]
    end

    return mail_final

  rescue Exception => e
    SUPERVISOR.fatal_error(e)
    raise VPLError.new(e.message, @boxes)
  end

  # @return [HTMLString] Le code initial, template
  # 
  def body_html_template
    @body_html_template ||= @filebox.messagetype_box.msgtype_html.freeze
  end
  def body_text_template
    @body_text_template ||= @filebox.messagetype_box.msgtype_text.freeze
  end

  # @return [Array] Liste des variables (raccourci)
  def variables
    @filebox.messagetype_box.variables
  end

end
