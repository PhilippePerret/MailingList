---
Subject = Mailing avec filtre sans classe Mailing
From = me@chez.lui
To = "Elle,F,elle@chez.elle"
Excludes = ./filtres/filtre_sans_methode.rb
---
Bonjour,

Ce mailing est défectueux, il fait appel à un filtre ruby qui ne définit pas la méthode attendu (`filtre_sans_methode`). 

Il produit donc une erreur.
