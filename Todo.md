# Todo list

## Fonctionnalité à implémenter

### Filtrage par ruby
On peut définir la propriété `Excludes` avec un fichier ruby qui devra définir la méthode de classe `Mailing.filter` qui recevra en premier argument la liste des destinataires retenus et retournera la liste filtrée.
Note : il faut voir comment transmettre d'autres informations, par exemple un fichier de suivi :
`Excludes = "/path/to/filtre_ruby.rb fichier_suivi.csv"`

## Tests à faire

### Test du sujet dynamique
On doit tester d'un sujet contenant du code ruby sera traité
