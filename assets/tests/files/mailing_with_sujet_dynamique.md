---
Subject = Bonjour %{Prenom}, nous sommes un #{Time.now.strftime('%A')}, #{nom}
From = philper@yahooo.fr
To = "phil@atelier-icare.net,H,Phil Ackerman"
---
Bonjour %{madame} %{Patronyme},

Permet un test d'un sujet dynamique qui utilise un code ruby et une propriété (calculée) du destinataire.

À bientôt,

Phil
