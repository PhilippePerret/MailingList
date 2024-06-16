# Todo list

## Fonctionnalité à implémenter

### Mémorisation du fichier

Quand le destinataire vient d'un fichier, on enregistre ce fichier (path) dans ses données (cela permettra ensuite de connaitre le fichier de suivi)

### Système d'erreur pour l'utilisateur

`VPF` (Visual Programming Feedback) Pour les erreurs, utiliser le même truc visuel à base de TTY-Box pour montrer où l'erreur se trouve dans le fichier mailing, mais aussi dans un cadre relié à l'information si ça se trouve dans un fichier externe. Par exemple une ligne rouge qui part de la donnée "To" en rouge dans les métadonnées et rejoint un cadres décrit comme le fichier CSV contenant les destinataires.

Pouvoir décider, par exemple avec l'option `-dev`, d'afficher un moteur plutôt qu'un autre.

## Tests à faire

### Test du sujet dynamique
On doit tester d'un sujet contenant du code ruby sera traité
