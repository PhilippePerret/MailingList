# Todo list

## Fonctionnalité à implémenter

### Évaluation des '%'

On doit pouvoir utiliser les '%' pour les données définies dans le csv (ou une table) comme pour des méthodes personnalisées
Pour ce faire, il ne faut donc plus utiliser '"<message>" % data_template' mais évaluer le sujet et le message comme du code ruby en cherchant les code '%{...}'

L'avantage sera de ne plus avoir à doubler les '%' (supprimer ce traitement fait dans markdown pour ne pas avoir de problème).

### Système d'erreur pour l'utilisateur

Pour les erreurs, utiliser le même truc visuel à base de TTY-Box pour montrer où l'erreur se trouve dans le fichier mailing, mais aussi dans un cadre relié à l'information si ça se trouve dans un fichier externe. Par exemple une ligne rouge qui part de la donnée "To" en rouge dans les métadonnées et rejoint un cadres décrit comme le fichier CSV contenant les destinataires.

Pouvoir décider, par exemple avec l'option `-dev`, d'afficher un moteur plutôt qu'un autre.

## Tests à faire

### Test du sujet dynamique
On doit tester d'un sujet contenant du code ruby sera traité
