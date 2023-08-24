require_relative '../feminines'
class MailBox

  def initialize(filebox)
    @filebox = filebox
  end

  def throw_box(err_mess)
    raise VPLError.new(err_mess, @boxes || :mail_box)
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
    # Le destinataire doit connaitre toutes les variables qui sont
    # utilisées dans le texte.
    # (sinon une erreur fatale sera produite)
    # 
    @boxes = [:mail_box, :receivers] # pour l'erreur
    variables.each do |variable|
      receiver.data_template.key?(variable.to_sym) || throw_box(ERRORS[:receiver][:requires_variable] % {var:variable, mail:receiver.mail})
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
    body_html = body_html_template % receiver.data_template
    body_text = body_text_template % receiver.data_template
    if false
      SUPERVISOR << "body_html = #{body_html}"
      SUPERVISOR << "body_text = #{body_text}"
    end

    #
    # Produire le mail final, qui sera un code découpé en lignes
    # de 70 signes et codé pour le mail
    # 
    mail_final = Mail::assemble(receiver, body_html, body_text, @filebox.metadata)

    if false
      SUPERVISOR << ["mail_final pour #{receiver.mail}", mail_final]
    end

    return mail_final

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
