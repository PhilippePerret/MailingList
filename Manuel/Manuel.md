# Mailing

Permet d'envoyer le mailing d'un mail complexe à partir d'un simple fichier markdown (avec métadonnée).

## En ligne de commande

~~~
send-mails <fichier md>[ <options>]
~~~

### Options



| Description                                |  Options   | Notes                                                        |
| ------------------------------------------ | :--------: | ------------------------------------------------------------ |
| Faire une simple simulation de l’envoi     |  **`-s`**  | « s » pour « simulation »                                    |
| Ne pas laisser de délai entre les messages |  **`-d`**  | « d » pour « délai ». Sinon, un temps aléatoire sera laissé entre chaque message envoyé. |
| Pour afficher l’aide                       |  **`-h`**  | « h » comme « help », aide en anglais                        |
| Ouvrir la version éditable du manuel       | **`-dev`** | S’emploie donc avec `send-mail manuel -dev`                  |




## Fichiers markdown mailing

### Contenu des métadonnées

#### Définitions obligatoires

~~~
Name = Le nom du mailing, juste pour information
~~~

~~~
Subject = Le sujet que prendront tous les mails
~~~

Ce sujet peut contenir du code ruby dans `#{code}`. Voir [Sujet dynamique](#sujet-dynamique).

~~~
From = <mail> # adresse mail de l'expéditeur
~~~

#### Définitions optionnelles

On peut aussi définir les images qui seront utilisées dans le texte. Une image utilisée dans le texte possède toujours un identifiant de la forme `IMG<id>`. Par exemple `IMGlogo`. Dans l’entête, on doit absolument définir son chemin d’accès relatif ou absolu.

~~~
IMG<id image> = <path absolu ou relatif à l'image>
~~~



### Contenu du message

#### Les images

## Annexes

### Exemples de code

<a name="sujet-dynamique"></a>

#### Sujet dynamique

~~~
Subject = Le sujet du #{Time.now.wday}
~~~

