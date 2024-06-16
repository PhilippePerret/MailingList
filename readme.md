# MailingList

Pour envoyer des mailings-lists.

> Le fichier appelé par la commande alias `send-mails` est `bin/send-mails`

Le programme est testé comme un moteur, en VPL.

## Mise en forme du message

C'est du faux markdown. Sont gérés :

* les styles de base, \*\* pour gras, \* pour italique, \_ pour souligné,
* les titres par `# titre`, `## titre`, etc. — noter qu'ils seront stylés en utilisant les définitions `.h1`, `.h2` etc. (les points avant les "hX" sont impératif, contrairement au CSS pur),
* les codes ruby (#\{...\}),
* les '%' isolés sont remplacés par des '%%' pour respecter le template,
* les variables sont exprimées en `%{nom-variable}`, elles sont remplacées par les données des destinataires,
* les images sont définies (path) dans les métadonnées, par "IMGvar = path/to/image" et `IMGvar` est utilisé dans le texte à l'endroit où l'image doit être mise,
* tous les `class="<selector>"` sont remplacés par `style="<valeur css du selector>"` (ces sélectors doivent être définis en haut de texte, par des `.<selector> {...}` — c'est le point qui indique qu'il ne s'agit pas d'un texte.),
* les listes par `* item`. Une liste numérotée doit obligatoirement commencer par `1.` et les items suivants doivent être obligatoirement des `*` ou des `-`,

## Todo

Le fin du fin serait de pouvoir choisir des adresses par rapport à une liste d'adresse et une liste de suivis. Par exemple, on a les clients de Icare éditions, on a le fichier de suivi des achats, on a le fichier de données des livres, et on crée un mailing à partir d'une condition sur un type de suivi (par exemple 'ACHAT') et une date, pour produire une demande d'impression.

En fait, ça devrait être un patch qu'on doit pouvoir "coller" au mailing pour lui injecter des adresses (définition de "To =").
