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
    message_final = message_template % table_valeurs
    if false
      debug "message_template = #{message_template.inspect}"
      debug "\n\nTable valeurs : #{table_valeurs.inspect}"
      debug "\n\nMESSAGE_FINAL\n#{message_final.inspect}"
    end

    return message_final

  rescue Exception => e
    if false # pour voir précisément le backtrace
      STDOUT.write e.backtrace.join("\n").orange
      exit 1
    end
    raise VPLError.new(e.message, @boxes)
  end

  # @return [HTMLString] Le code initial, template
  # 
  def message_template
    @message_template ||= @filebox.messagetype_box.message_type.freeze
  end

  # @return [Array] Liste des variables (raccourci)
  def variables
    @filebox.messagetype_box.variables
  end

end
