---
Subject = Mailing avec méthode de filtre sans la bonne arité (nombre d'arguments)
From = me@chez.lui
To = "Elle,F,elle@chez.elle"
Excludes = ./filtres/filtre_bad_arity.rb
---
Bonjour,

Ce mailing est défectueux, il fait appel à un filtre ruby qui ne définit pas les bons arguments pour la méthode (`filtre_bad_arity`). 

Il produit donc une erreur.
