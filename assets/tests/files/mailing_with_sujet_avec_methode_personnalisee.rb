class Receiver
  
  # Cette méthode va retourner l'indice du groupe
  def indice_groupe
    premiere_lettre = nom[0]
    if premiere_lettre.match?(/[A-L]/)
      "1er"
    elsif premiere_lettre.match?(/[M-T]/)
      "2e"
    else
      "3e"
    end
  end
  
end
