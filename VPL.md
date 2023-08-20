# Visual Programming Language

Ça donnerait quoi, ce programme, si c'était un moteur (de voiture) ?

- Il y aurait le réservoir d'essence, là où on met les adresses des destinataires (entrée fichier)
- Il y aurait un endroit où on entrerait le message-type à envoyer, avec tous ses paramètres (entrée fichier)

- Il y aurait un endroit qui traite le message type pour faire le message final, pour un destinataire en particulier
- Il y aurait un moteur qui enverrait simplement le message
- Il y aurait une boucle ici pour traiter tous les destinataires (ou alors, faut-il faire tous les messages et, une fois, faits, procéder à l'envoi ? ce qui permettrait de distinguer toutes les étapes, sans aucune boucle — donc pas comme dans un moteur)

- Il y aurait un superviseur général pour s'assurer que tout se passe bien et récolterait les erreurs.

BOITE FICHIER - BOX-FILE
C'est elle qui reçoit le fichier définissant le message à envoyer et tous ses paramètres (destinataires, variables, etc.)
Elle envoie à la boite destinataires toutes les informations sur les destinataires (adresses, listing d'adresses, exclusions).
Elle envoie à la boite de message-type tout ce qui concerne le message (le texte, le sujet, les variables utiles)
Elle produit une erreur quand le minimum n'est pas fourni.

BOITE DESTINATAIRES - BOX-RECEIVERS
C'est elle qui reçoit la liste des destinataires, soit par le biais d'un fichier (listing), soit de façon brute.
Elle les vérifie tous, pour voir s'ils sont conformes dans l'absolu à ce qu'on attend (sans s'occuper des demandes propres au message-type (c'est lui qui le traitera).
Elle produit des destinataires (instances Receiver), avec toutes leurs données utiles (se limitant pour le moment au mail, au patronyme et au sexe).

BOITE DU MESSAGE-TYPE - BOX-MESSAGE-TYPE
C'est elle qui reçoit le texte du mail à envoyer et ses paramètres, à commencer par son sujet.
Elle analyse les paramètres dont elle a besoin pour fonctionner (par exemple les variables destinataires — elle s'assure que la boite des destinataires les fournit bien pour chaque destinataire).

BOITE MAIL - BOX-MAIL
La boite du message fabrique le message final à envoyer, à partir du message type (demandé à la boite précédente) et un destinataire (fourni par la boite destinataires)

BOITE ENVOI — BOX-SENDER
C'est la boite qui se charge d'envoyer le message, dans le cas de ce mailing, avec un retard dynamique.
