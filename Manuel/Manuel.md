# Mailing

Permet d'envoyer le mailing d'un mail complexe à partir d'un simple fichier markdown (avec métadonnée).

## En ligne de commande

~~~
send-mails <fichier md>[ <options>]
~~~

### Options de la commande CLI

| Description                                    |  Options   | Notes                                                        |
| ---------------------------------------------- | :--------: | ------------------------------------------------------------ |
| Faire une simple simulation de l’envoi         |  **`-s`**  | « s » pour « simulation ». En mode simulation, les délais entre les envois seront raccourcis et les mails seront enregistrés dans le dossier `tmp/mails` de l’application. |
| Ne pas laisser de délai entre les messages     |  **`-d`**  | « d » pour « délai ». Sinon, un temps aléatoire sera laissé entre chaque message envoyé, pour donner l’impression d’envois réels. |
| Pour afficher l’aide                           |  **`-h`**  | « h » comme « help », aide en anglais                        |
| Affichage des erreurs dans le moteur programme | **`-dev`** | En mode normal, l’erreur est affiché graphiquement par rapport au fichier mailing. En mode développement, ce sont les « boxes » qui sont utilisées, qui permettent de mieux localiser les erreurs. |
| Ouvrir la version éditable du manuel           | **`-dev`** | S’emploie donc avec `send-mail manuel -dev`                  |

---

<a name="mailing-file"></a>


## Fichiers markdown mailing

Ce fichier constitue l’élément principal de l’application ***Mailing***. C’est un fichier markdown (donc d’extension `.md`) qui définit précisément le mailing. Il est constitué de deux parties :

* les [métadonnées](#metadata),
* le [message à transmettre](#message).

<a name="metadata"></a>

### Contenu des métadonnées

Les *métadonnées* sont consignées dans le fichier markdown du mailing, en haut, entre deux `---` :

~~~
---
<métadonnée>
---
~~~

Elles sont constituées de paires **`Clé = Valeur`** ou la clé commence toujours par une capitale suivie de minuscules.

#### Définitions obligatoires

~~~
---
Subject = Le sujet du message
From = <mail de l'expéditeur>
To = <définition des destinataires>
---
<le message du mail>
~~~

Détail des éléments :

~~~
Subject = Le sujet que prendront tous les mails
~~~

> Noter que les guillemets, quand c’est une simple valeur `String` qui est donnée, ne sont pas obligatoires.

Ce sujet peut contenir du code ruby dans `#{code}` qui sera évalué dans le contexte du destinataire ainsi que des variables destinataires `%{variable}` (par exemple `%{Patronyme}`. Voir [Sujet dynamique](#sujet-dynamique).

~~~
From = <mail> # adresse mail de l'expéditeur
~~~

Cette donnée peut avoir la forme `Patronyme <mail valide>`.

~~~
To = <définition des destinataires>
~~~

On peut définir les destinataires de plusieurs façons. Voir la [Définition des destinataires](#define-destinataires).

#### Définitions optionnelles

On peut donner au mailing un nom qui sera utile pour d’autres programmes :

~~~
Name = Le nom du mailing, juste pour information
~~~

On peut définir des exclusions avec la propriété `Excludes` :

~~~
Excludes = <définition des exclusions>
~~~

On peut définir ces exclusions de plusieurs manières, [de la même façon que les destinataires](#define-destinataires). Voir aussi [Définition des exclusions](#define-exclusions).

Dans les métadonnées, on peut aussi définir **les images** qui seront utilisées dans le texte. Une image utilisée dans le texte possède toujours un identifiant de la forme `IMG<id>`. Par exemple `IMGlogo`. Dans l’entête, on doit absolument définir son chemin d’accès relatif ou absolu. Voir le [détail des images](#images).

~~~
IMG<id image> = <path absolu ou relatif à l'image>
~~~

Par exemple, pour le logo qui se trouverait dans un dossier `images` au même niveau que le fichier mailing, on pourrait avoir :

~~~
---
...
IMGlogo = ./images/logo.jpg
---
Bonjour,

Voici mon logo : 

IMGlogo
~~~

---

<a name="message"></a>

### Contenu du message

Le contenu du message est la seconde partie du fichier mailing.

Il définit principalement le message qui sera envoyé au destinataire après sa mise en forme et le renseignement des variables ou des textes dynamiques.

~~~
---
<métadonnées>
---
<définition des styles>

<message>

~~~

Vous trouverez toutes les informations sur la rédaction du message dans la partie [Définition du message à envoyer](#define-message).


---

## Définitions

<a name="define-destinataires"></a>

### DESTINATAIRES

Les destinataires se définissent dans les [métadonnées][] à l’aide des propriétés `To` et `Excludes`. La propriété `To` permet de définir la liste de référence et la propriété `Excludes` permet de retirer des adresses ou de les filtrer.

<a name="types-data-destinataires"></a>

#### Manière de définir destinataires

La propriété `To` (comme la propriété `Excludes` qu’on verra plus tard) peut définir les destinataires (la liste de référence, de départ) de ces différentes manières : 

1. Une simple adresse avec patronyme : `Patronyme <mail valide>` (dans [une liste](#define-par-liste) s’il y en a plusieurs).
2. Une définition minimale d’un destinataire sous forme de rangée CSV : `"<Patronyme>,<sexe>,<mail>"` (l’ordre n’importe pas). Voir la [Définition sous forme rangée CSV](#define-dest-as-csv-row).
3. Un chemin d’accès relatif ou absolu à [un fichier CSV valide](#format-destinataires-csv)  définissant les adresses et les propriétés des destinataires. C’est la forme qui permet le plus simplement de définir de nombreuses propriétés. Voir [Définition par fichier CSV](#define-desti-with-csv).
4. Une table de type ruby contenant toutes les données à commencer par `{'Mail' => "<mail>", 'Patronyme' => "<patronyme>", 'Sexe' => "<H/F>"}`. Voir [Définition par table ruby](#define-desti-with-hash).
4. Une liste contenant un ou plusieurs éléments précédents. Voir [Définition dans une liste](#define-par-liste).

Noter que quelle que soit la manière adoptée, il ne s’agit peut-être là que de la liste de départ, qui pourra ensuite être filtrée grâce à la propriété `Excludes`.

Voyons dans le détail chacune des formes de définition.

<a name="define-dest-as-csv-row"></a>

#### Définition des destinataires par rangée CSV

La façon la plus simple, qui ne correspond qu’à un seul destinataire est la suivante :

~~~
To = "Prénom NOM,H,mail@valide.com"
~~~

*(noter que les guillemets sont optionnels)*

<a name="define-desti-with-csv"></a>

#### Définition des destinataires par fichier CSV

Mais l’utilisation d’un mailing requiert plusieurs destinataires. Le plus simple est de les définir dans [un fichier CSV bien formaté](#format-destinataires-csv) :

~~~
To = destinataires.csv
~~~

Avec cette formulation, le fichier `destinataires.csv` doit obligatoirement se situer au même niveau que le fichier mailing. Sinon, on peut indiquer le chemin relatif :

~~~
To = ../utils/destinataires.csv
~~~

… ou absolu :

~~~
To = /Users/phil/mails/destinataires.csv
~~~

On pourra trouver [ci-dessous le formatage de ce fichier CSV](#format-destinataires-csv).

<a name="define-desti-with-hash"></a>

#### Définition des destinataires par table ruby

On peut définir les destinataires par : 

~~~
To = {'Mail' => "<mail>", 'Patronyme' => "<patronyme>", 'Sexe' => "<H/F>", 'Var1' => "...", 'Var2' => "...", etc. }
~~~

> Les clés doivent être obligatoirement des strings qui commencent par des capitales.

Pour avoir plusieurs destinataires, il suffit de mettre ces tables dans une liste :

~~~
To = [{'Mail' => "<mail>", 'Patronyme' => "<patronyme>", 'Sexe' => "<H/F>"}, {'Mail' => "<mail2>", 'Patronyme' => "<patronyme2>", 'Sexe' => "<H/F>"}, etc., ./fichier.csv]
~~~

> Noter, comme cela est précisé plus haut, qu'il est possible de mettre n'importe quelle donnée dans cette liste.

---

<a name="define-exclusions"></a>

### EXCLUSIONS

Les exclusions consistent principalement en une liste d’adresses mail qui seront retirées de la liste des destinataires. 

Elles peuvent être définies de la [même manière que les destinataires](#types-data-destinataires).

#### Exclusions par liste de mails

Le fichier possède le même formatage [que le fichier CSV des destinataires](#format-destinataires-csv).

La seule différence, pour les exclusions, est qu’**on n’a besoin que de l’adresse mail**. La définition des exclusions peut donc ressembler simplement à :

~~~
Excludes = ["<mail 1>", "<mail 2>", etc.]
~~~

<a name="excludes-per-filter"></a>

#### Exclusions par filtrage [Expert]

[Expert] Une manière puissante d’exclure des destinataires (ou de les choisir précisément) consiste à utiliser un filtre en ruby (donc il est impératif de connaitre le langage ruby). On définit le fichier filtre dans la donnée `Excludes`, seul ou dans une liste :

~~~
---
...
Excludes = /path/to/filtre.rb
---
...
~~~

Ou simplement le nom de la méthode si le filtre est défini dans le [module ruby propre au mailing](#mailing-own-module) :

~~~
---
...
Excludes = filtre
---
~~~

Ou par l’un ou l’autre mais dans une liste : 

~~~
---
...
Excludes = ["/path/to/exclusions.csv", "/path/to/filtre.rb", "autre_filtre"]
~~~

> Noter que ci-dessus, on procèdera d’abord à l’exclusions des mails contenus dans `exclusions.csv` et ensuite on enverra la liste restante à `filtre.rb` et enfin la méthode `autre_filtre`, dans le [module ruby propre au mailing](#mailing-own-module) sera invoquée avec la liste des adresses restantes. L’ordre, dans `Excludes`, est capital, même si elle produit la plupart du temps le même résultat.

> Comme on le voit, avec une liste, on peut enchainer plusieurs filtres [comme dans l’exemple en annexe](#exemple-chaine-filtres).

Pour un filtre ruby, dans le fichier ruby, on définira une **méthode de classe qui portera le même nom que le fichier** et qui recevra en premier argument la liste actuelles des destinataires (déjà filtrés ou non).

Si on définit le mailing par :

~~~
---
To = desti.csv
Excludes = ./modules/filtre_femmes.rb
~~~

… alors on aura un fichier `filtre_femmes.rb` dans le dossier `modules` au même niveau que le fichier mailing qui contiendra le code :

~~~
# modules/filtre_femmes.rb
class Mailing

	def filtre_femmes(recipients)
		# Ici le traitement des recipients pour produire
		# la liste recipients_filtred qui sera retournée
		#
		return recipients_filtred
	end
end
~~~

##### Paramètres dynamiques

On peut transmettre à la méthode de filtrage d’autres arguments. Il suffit de les mettre à la suite du chemin d’accès au fichier, en indiquant leur type par leur forme (un nombre sera tel quel, une chaine sera mise entre guillemets, une table sera mise telle quelle, etc.).

~~~ 
---
...
Excludes = /path/to/mon_filtre.rb <arguments>
---
~~~

Ou dans une liste :

~~~
---
...
Excludes = ["out.csv", "filtre.rb <arguments>"]
---
~~~

On peut définir par exemple d’envoyer un nombre et une chaine avec :

~~~
---
...
Excludes = /path/to/mon_filtre.rb 25 "jeudi"
---
~~~

Ou dans une liste :

~~~
---
...
Excludes = ["out.csv", "/path/mon_filtre.rb 25 'jeudi'"]
---
~~~

> Noter les guillemets simples utilisés

On aura alors la définition de la méthode de filtre correspondante, en se rappelant que le premier paramètre est toujours la liste actuelle des destinataires :

~~~
# mon_filtre.rb
class Mailing

	def mon_filtre(recipients, age, jour)
		recipients.reject do |rec|
			if rec.age > age
				false
			else
				# On ajoute "(du <jour>)" au patronyme (c'est idiot, juste 
				# pour l'exemple)
				rec.data['Patronyme'] = rec.data['Patronyme'] + " (du #{jour})"
				true # le prendre
			end
		end
	end
	
end

# Ajout d'une méthode au destinataire
class Receiver
	def age
		Time.now.year - data['Naissance'].to_i
	end
end
~~~

> Noter comment nous ajoutons une méthode au destinataire (`class Receiver`) en bas de fichier

---

XXX

<a name="define-par-liste"></a>

### Définition dans une liste

Que ce soit les destinataires ou les exclusions, on peut toujours les définir dans une liste. Une liste est définie par des crochets qui doivent commencer et fermer la donnée complète :

~~~
To = [ <définition par liste> ]
Excludes = [ <définition par liste> ]
~~~

À l’intérieur de ces crochets, on peut trouver toutes les définitions possibles et mélangées, simples mails, table ruby, fichier CSV, rangée CSV, filtre ruby. 

**Le seul impératif est d’utiliser des guillemets sur toutes les chaines.** Alors qu’il est possible de définir un destinataire unique sans guillemets, de la façon suivante :

~~~
To = Patro NYME, H, patronyme@chez.lui
~~~

… dans une liste, il faudra obligatoirement mettre des guillemets :

~~~
To = ["Patro NYME, H, patronyme@chez.lui", ...]
~~~

> Noter que c’est la donnée complète qui est entre guillemets, pas ses éléments. Cela permet de distinguer les éléments, qui seront ensuite décomposés.

Idem pour les fichiers :

~~~
To = /path/to/file.csv
~~~

Mais dans une liste :

~~~
To = ["/path/to/file.csv", ...]
~~~

Mais il ne faut pas mettre de guillemets autour de la définition par table ruby :

~~~
To = {'Mail' => "<mail>", 'Patronyme' => "<patronyme>", 'Sexe' => "<H/F>"}
~~~

Idem dans une liste :

~~~
To = [{'Mail' => "<mail>", 'Patronyme' => "<patronyme>", 'Sexe' => "<H/F>"}, ...]
~~~

> Il suffit, en fait, de se souvenir qu’une liste sera évaluée en ruby. Donc tout élément doit être « compréhensible » pour ruby.

Noter que `Excludes` peut être défini aussi par une liste, et que **l’ordre est alors capital**.

---

<a name="define-message"></a>

### MESSAGE

<a name="define-styles"></a>

#### Les styles

Le message, deuxième partie du fichier mailing, peut commencer par une définition des styles qui seront utilisés ensuite. Ces styles sont définis en haut du fichier et doivent tous commencer par un point suivi du nom du sélecteur (attention de ne pas confondre avec l’utilisation pure en CSS où les points sont utilisé pour les `class`. Ici, le point définit un sélecteur. Par exemple, si on a cette définition :

~~~
---
# Métadonnées
---
.mabalise {color: red;}
~~~

… alors on utilisera dans le message :

~~~
---
# Métadonnées
---
.mabalise {color: red;}

Bonjour,

Ce texte sera en <mabalise>rouge</mabalise>.
~~~

… qui produira le message :

« 
Bonjour,

Ce texte sera en <span style="color:red">rouge</span>.
»


#### Le pseudo-format markdown

Ensuite, le message lui-même peut utiliser un marquage proche de markdown, mais simplifié. Il peut faire usage :

| <span style="display:inline-block;width:200px;">Description</span> | <span style="display:inline-block;width:200px;">Marquage</span> | Notes                                                        |
| ------------------------------------------------------------ | :----------------------------------------------------------: | ------------------------------------------------------------ |
| Italiques                                                    |                         **`*...*`**                          |                                                              |
| Gras                                                         |                        **`**...**`**                         |                                                              |
| Souligné                                                     |                         **`_..._`**                          |                                                              |
| Listes                                                       |          `* <item>`<br />`* <item>`<br />`* <item>`          |                                                              |
| Liste numérotée                                              |         `1. \<item>`<br />`* <item>`<br />`* <item>`         | Contrairement à markdown le premier item doit obligatoirement être `1.` et les autres items doivent être des astérisques. |
| Titres                                                       |                 `# titre`, `## titre`, etc.                  | Pour définir précisément leur style, définir `.h1`, `.h2`, `.h3` etc. en haut du fichier. Les points, avec les « h », sont obligatoires, contrairement à CSS. |

---

<a name="images"></a>

#### Les images

On peut ensuite utiliser des images, en les définissant dans l’entête.

> Noter dès à présent qu’on peut définir très précisément la position et la taille d’une image en utilisant les [styles](#define-styles) comme c’est montré [dans l’annexe](#define-image-with-styles).

<a name="variables-in-message"></a>

#### Les variables

Les variables dans le message à envoyer peuvent être de deux natures :

* [Expert] variables ruby évaluées comme telles, une fois pour toutes quel que soit le destinataire,
* variables destinataire évaluées à la construction du mail pour le destinataire.

[Expert] Les **variables ruby** s’inscrivent comme en ruby à l’aide de `#{code à évaluer}`.

Les **variables destinataires** s’inscrivent à l’aide de **`%{variable}`**. 

##### Variables communes

Parmi les variables générales, on trouve :

| Description                        | Variable           | Note                                    |
| ---------------------------------- | ------------------ | --------------------------------------- |
| Patronyme du destinataire          | **`%{Patronyme}`** | Noter la capitale, indispensable        |
| Mail du destinataire               | **`%{Mail}`**      |                                         |
| Prénom du destinataire             | **`%{Prenom}`**    | Si défini ou si le patronyme est défini |
| Nom du destinataire                | **`%{Nom}`**       | Si défini ou si le patronyme est défini |
| **Toutes les variables féminines** |                    |                                         |
| Madame/Monsieur                    | **`%{Madame}`**    |                                         |
| (rien)/e                           | **`%{e}`**         | fort/forte                              |
| a/on                               | **`%{a}`**         | mon / ma                                |
| elle/il                            | **`%{elle}`**      |                                         |
| et/ette                            | **`%{ette}`**      | sujet/sujette                           |
| er/ère                             | **`%{ere}`**       | première/première                       |
| ef/ève                             | **`%{eve}`**       | bref/brève                              |
| f/ve                               | **`%{ve}`**        | veuf/veuve                              |
| la/le                              | **`%{la}`**        |                                         |
| (rien)/ne                          | **`%{ne}`**        | bon/bonne                               |
| eur/rice                           | **`%{rice}`**      | correcteur/correctrice                  |
| x/se                               | **`%{se}`**        | heureux/heureuse                        |
| ec/èche                            | **`%{eche}`**      | sec/sèche                               |
| l/lle                              | **`%{lle`**        | bel/belle                               |
| (rien)/sse                         | **`%{sse}`**       | maitre/maitresse                        |

##### Variables par colonne CSV

On peut ensuite avoir n’importe quelle variable qui serait définie dans le fichier CSV des destinataires. **La variable correspond alors au nom de la colonne**. Par exemple, si le fichier CSV des destinataires contient l’entête :

~~~csv
Id,Mail,Patronyme,Fonction,Annee
~~~

… alors on pourra utiliser dans le message (et dans le sujet) les variables `%{Fonction}` et`%{Annee}`.

<a name="variable-per-custom-method"></a>

##### Variables par méthode personnalisées [Expert]

[Expert] On peut ensuite définir des variables ruby (qui sont en fait des méthodes) dans le [module propre au mailing](#mailing-own-module). Il suffit de les définir comme des méthodes d’instances de la classe `Receiver`. 

Par exemple :

~~~
class Receiver
	def ma_custom_variable
		# Retourne la valeur calculée pour le destinataire
	end
end
~~~

… permettra d’utiliser la variable **`%{ma_custom_variable}`** dans le message (ou le sujet).



---

<a name="format-destinataires-csv"></a>

## Fichier CSV des destinataires

Un fichier destinataires bien formaté doit obligatoirement posséder une entête définissant les champs et des virgules pour séparer les données.

Le nom des champs doit être capitalisé et comprendre au minimum `Patronyme` (avec le nom en capitales), `Mail` et `Sexe` (de valeur `H` ou `F`). **L’ordre des champs n’importe pas**.

Les autres champs seront des données qu’on pourra reprendre à l’aide de variables `%{Variable}` dans le texte du message.

Donc, un fichier minimum ressemblera à :

~~~
Patronyme,Mail,Sexe
Prénom NOM,sonmail@chez.lui,H
Prénome NOM,autremail@chez.elle,F
~~~

Ce format vaut aussi bien pour les fichiers de destinataires que les fichiers d’exclusion.

---

<a name="mailing-own-module"></a>

## Module propre au mailing [Expert]

[Expert] Les experts en ruby peuvent utiliser un module (donc ruby) pour gérer :

* les filtres,
* les variables personnalisées.

Le *module propre au mailing* est simplement un module ruby (donc un fichier `.rb`) qui porte le même nom (l’affixe, en fait) que le [fichier markdown du mailing](#mailing-file) et se trouve au même niveau. Par exemple :

~~~
mon_dossier/autre_dossier/fichier_mailing.md
mon_dossier/autre_dossier/fichier_mailing.rb   # son module propre
~~~

Dans ce fichier, on pourra définir les variables par :

~~~
# in fichier_mailing.rb
class Receiver

	def ma_variable
	end

end
~~~

Pour le détail, voir [Variables par méthode personnalisée](#variable-per-custom-method).

Et on pourra définir les filtres par :

~~~
# in fichier_mailing.rb
class Mailing
	def une_methode_de_filtre(recipients)
		# traitement de recipients
		# ....
		return recipients
	end
~~~

Pour le détail, voir [Exclusions par filtrage](#excludes-per-filter).

---

## Annexes

### Exemples de code

<a name="sujet-dynamique"></a>

#### Sujet dynamique

~~~
---
Subject = Le sujet du #{Time.now.wday}
...
---
...
~~~

Le sujet dynamique peut aussi faire appel au destinataire en invoquant une de ses variables :

~~~
---
Subject = Bonjour %{Prenom}, nous sommes un #{Time.now.wday}
...
---
...
~~~

Mais notez bien, ci-dessus, l’utilisation du `#` (dièse) pour le code ruby (commun à tous les messages) et l’utilisation du `%` (signe pourcentage) pour faire appel à une propriété du destinataire en particulier.

[Expert] On peut également faire un traitement très précis en utilisant du code ruby qui utilise les données du destinataire courant en utilisant le fait que le code est évalué dans le contexte de l’instance `Receiver` du destinataire.

Imaginons par exemple que nous voulions enregistrer un message différent en fonction de la première lettre du nom du destinataire (pour créer trois groupes différents, de A à L, de M à T et de U à Z).

Le sujet final devra ressembler à : « **John, chanceux, vous êtes dans le 2e groupe** »

Dans le fichier mailing, on aura :

~~~
---
Subject = %{Prenom}, chanceu%{se}, vous êtes dans le %{indice_groupe} groupe
To = bons.csv
From = phil@chez.lui
---
Bonjour %{Patronyme}

Le titre précise le groupe dans lequel vous vous trouverez.
~~~

Si l’on lance ce mailing, il produit une erreur en précisant que la méthode `indice_groupe` est inconnue de la classe `Receiver`. Il nous faut préciser cette méthode.

Le fichier mailing s’appelant `mon_mailing.md`, le programme recherche un fichier s’appelant `mon_mailing.rb` au même niveau que le fichier mailing. Ce fichier contient :

~~~
# mon_mailing.rb
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
~~~

Cette fois, le mailing pourra être envoyé, avec le bon titre.

---

<a name="define-image-with-styles"></a>

#### Images avec styles

Grâce aux [styles](#define-styles), on peut définir très précisément la taille et la position des images dans le fichier. Par exemple, ci-dessous, on crée une rangée de vignettes de livres :

~~~
---
...
IMGlivre1 = ./images/livre1.jpg
IMGlivre2 = ./images/livre2.jpg
IMGlivre3 = ./images/livre3.jpg
---
.vignette {display: inline-block; width:120px;margin:10px;}

Bonjour,

Voici nos derniers livres :

<vignette>IMGlivre1</vignette><vignette>IMGlivre2</vignette><vignette>IMGlivre3</vignette>

Bien à vous.

~~~

Cela produit le mail suivant, avec les trois images sur la même ligne, de taille 120 pixels en largeur et séparés de 20 pixels.

> Noter que les trois vignettes doivent s’inscrire impérativement sur la même ligne (sans retour chariot). Et si possible, sans espace entre les balises.

---

<a name="exemple-chaine-filtres"></a>

#### Chaine de filtres

Grâce aux listes, on peut enchainer plusieurs listes. Par exemple :

~~~
---
...
To = destinataires.csv
Excludes = ["filtre_hommes.rb", "filtre_age.rb 25"]
---
Bonjour %{Patronyme},

Vous êtes une femme âgée de plus de 25 ans.
~~~

Le mailing ci-dessus utilise la liste des destinataires `destinataires.csv` qui définit les propriétés normales ainsi que la propriété `Naissance` de l’année de naissance : 

~~~
Id,Patronyme,Mail,Sexe,Naissance
1,Lui NOM,sonmail@chez.lui,H,2000
2,Elle NOM,sonadresse@chez.elle,F,2003
etc.
~~~

Le premier filtre va exclure tous les hommes, il est défini ainsi :

~~~
# filtre_hommes.rb
class Mailing
	def	self.filtre_hommes(destinataires)
		destinataires.reject do |r|
			r.sexe == 'H'
		end
	end
end
~~~

Le second filtre va ne prendre que les destinataires restants de plus de 25 ans. Noter que cette méthode prend en second argument le nombre 25.

~~~
# filtre_age.rb
class Mailing
	def self.filtre_age(destinataires, age_minimum)
		# On définit l'année courante pour pouvoir calculer
		# l'âge
		current_year = Time.new.year
		# On boucle sur les destinataires pour les filtrer
		destinataires.reject do |r|
			# On calcule l'âge du destinataires
			age = current_year - r.data['Naissance'].to_i
			age < age_minimum
		end
	end
end
~~~

---

<a name="tutoriel-complet"></a>

### Tutoriel complet : Questionnaire de satisfaction

On va créer « from scratch » un mailing pour envoyer un questionnaire de satisfaction à des lecteurs d’une maison d’édition. Ce questionnaire doit être envoyé à tout lecteur ayant acheté un livre il y a plus de deux mois et n’ayant pas encore reçu ce questionnaire.

Nous créons un fichier `questionnaire_satisfaction.md` à l’endroit voulu.

Dedans, nous définissons le sujet et le message :

~~~
---
Subject = Icare éditions – Questionnaire de satisfaction
From = "Icare Éditions <infos@icare-editions.fr>"
To = 
Excludes =
IMGlogo = /Users/phil/icare/images/logo_mail.jpg
---
Bonjour %{Patronyme},

Vous avez acheté il y a quelques semaines %{les_livres} %{titres}. 

Nous vous remercions à nouveau de votre intérêt.

Nous aimerions aujourd'hui recueillir votre avis concernant %{ces_livres}. Pour ce faire, vous pouvez utiliser ce [questionnaire](https://path/to/googleform) qui ne vous prendra que quelques minutes et qui nous aidera beaucoup à améliorer notre collection et nos ouvrages. Répondre au [questionnaire](https://path/to/googleform).

D'avance, nous vous en remercions.

Bien à vous,

Les éditions Icare
IMGlogo
~~~

> Notes :
>
> • Nous utilisons un logo situé dans le dossier icare/images
>
> • Le questionnaire ne sera pas décrit ici, il s’agit par exemple d’un questionnaire GoogleForm.

#### Définir les destinataires

On définit d’abord dans `To` les listes des acheteurs/lecteurs potentiels. Ici, il s’agit de trois listes différentes :

* la liste des conservatoires
* la liste des inscrits à la classe d’analyse affiliée aux éditions (CAM)
* une liste de lecteurs/lectrices en provenance de diverses sources, par exemple le site des éditions.

On définit donc le paramètres à :

~~~
To = ["/path/to/destinataires/conservatoires.csv", "/path/to/destinataires/cami.csv", "/path/to/destinataires/site_icare.csv"]
~~~

À ce niveau-là, on pourrait déjà envoyer le mailing, avec la commande `send-mails questionnaire_satisfaction.md` mais il serait transmis à toutes les adresses. Il nous faut les filtrer grâce au paramètre `Excludes`.

Dans un premier temps, nous allons exclure les destinataires qui n’ont jamais fait d’achat de livre. Ce filtre s’appellera `filtre_avec_achat` :

```
Excludes = ["filtre_avec_achat"]
```

> Note : nous mettons une liste car nous allons enchainer plusieurs filtres.

Ce filtre n’ayant qu’un nom (pas de chemin d’accès), il doit être défini dans le [module ruby propre au mailing](#mailing-own-module), qui s’appellera donc `questionnaire_satisfaction.rb`. Il contiendra :

> Ce module considère que :
>
> 	- les destinataires sont identifiés par des identifiants numérique utilisés dans les fichiers de suivis
> 	- les fichiers de suivis contiennent les colonnes Id (identifiant du suivi), Cid (identifiant du client), Transaction (transaction, par exemple ‘ACHAT’ ou ‘AVIS’), Produits (liste des Identifiants de produits, séparés par des « + »)
> 	- le fichier CSV des suivis définit le chemin d’accès au fichier des Produits
> 	- le fichier CSV des produits contient Id (identifiant du produit), Titre (titre du livre), Auteur (auteur du livre)
> 	-   

~~~
# questionnaire_satisfaction.rb
require 'date'

class Mailing

	#
	# La date d'il y a deux mois
	#
	ILYA_2_MOIS = Time.now - 60
	
	def filtre_avec_achat(destinataires)
		#
		# Boucle sur tous les destinataires
		#
		destinataires.select do |dest|
			#
			# On garde le destinataires s'il a fait un achat dans les
			# 2 mois sans avoir eu de demande d'avis
			#
			dest.has_achat_sans_avis?
		end
	end
	
	# Correspondance entre le fichier CSV des destinataires et le fichier CSV des
	# suivis lorsqu'il ne correspond pas au fichier "naturel" qui est le même avec
	# "_suivi" ajouté au nom.
	DEST2SUIVI = {
		# Ce suivi est enregistré à un autre endroit que l'endroit "naturel"
		"/path/to/destinataires/conservatoires.csv" => "/path/to/suivi/cons_suivi.csv"
	}
end

# Si le gem 'Suivi' n'est pas utilisé, il faut implémenter les 
# méthodes nécessaires 

class Receiver
	
	# @return true si le destinataire a fait un achat sans demande
	# d'avis dans les 30 derniers jours.
	#
	
	def	has_achat_sans_avis?
	
		achats = has_suivi?('ACHAT', {after: ILYA_2_MOIS})
		avis   = has_suivi?('AVIS', {after: ILYA_2_MOIS})
		# On fait la liste des produits dont on a demandé l'avis
		avis = avis.collect { |a| a['Produits'].split('+') }
		# On garde seulement les produits sans avis
		# On fait la table des achats par produit
		table_achats_sans_avis = {}
		achats.each do |achat|
			produits = achat['Produits'].split('+')
			produits.each do |produit_id|
				next if avis.includes(produit_id)
				table_achats_sans_avis.merge!(produit_id => achat)
			end
			#
			# On retourne le résultat
			#
			return table_achats_sans_avis.count > 0
		end
		#
		# IMPORTANT : on met le résultat du filtre dans la propriété 
		# `@livres_sans_avis` pour pouvoir l'utiliser plus tard
		@livres_sans_avis = table_achats_sans_avis
		
	end
	
	#
	# @return true si le destinataire possède la transaction +transaction+
	# avec les paramètres +params+
	#
	
	def has_suivi?(transaction, params)
		
		suivis.key?(transaction) || return(false)
		bons_suivis = suivis[transaction].select do |suivi|
			date_suivi = Date.parse(suivi['Date'])
			if params[:after]
				date_suivi > params[:after] || next
			end
			if params[:before]
				date_suivi < params[:before || next
			end
			true
		end
	end
	
	#
  # @return les suivis du destinataires
	#
	
	def	suivis
	
  	@suivis ||= begin
			h = {}
			CSV.foreach(suivi_file, **{headers:true, col_sep:','}).each do |line|
				next if line['Id'].to_i != id # seulement les lignes de lecteur
				h.merge!( line['Transaction'] => []) unless h.key?(line['Transaction'])
				h[line['Transaction']] << line
			end
		end
	end
	
	# @return fichier suivi
	def suivi_file
	  @suivi_file ||= Mailing::DEST2SUIVI[file]
	end
end
~~~

Grâce au filtre, nous obtenons seulement la liste des adresses voulues. Il nous faut maintenant implémenter (programmer) les variables propres du message que sont `les_livres`, `livres` et `ces_livres`.

Nous le faisons aussi dans le module ci-dessus, toujours dans la classe `Receiver` du destinataire :

~~~
# Dans questionnaire_satisfaction.rb

# ... code précédent

class Receiver

	# ... code précédent
	
	# @return les titres des livres
	
	def livres
		@livres_sans_avis.collect do |produit_id, achat|
			get_produit(produit_id)['Titre']
		end.pretty_join # méthode du gem 'clir'
	end
	
	def les_livres
		plusieurs? ? 'les livres' : 'le livre'
	end
	
	def ces_livres
		plusieurs? ? 'ces livres' : 'ce livre'
	end
	
	def plusieurs?
		@livres_sans_avis.count > 1
   end
	
	# @return le produit d'identifiant produit_id
	def get_produit(produit_id)
		CSV.foreach(produits_path, **{headers:true, col_sep:','}).each do |row|
			return row if row['Id'] == produit_id
		end
	end
	
	def produits_path
	  @produits_path ||= '/path/to/produits.csv'
  end
end
~~~

