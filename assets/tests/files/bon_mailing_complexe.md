---
Subject = Pour un envoi complexe
From = "Phil Ackerman <phil@atelier-icare.net>"
To = ./destinataires/complexes.csv
Exclude = ./destinataires/complexes_out.csv
IMGlogo = ./images/logo.jpg
IMGLivre = ./images/livre.jpg
---
.vignette {display:inline-block;width:100px;padding:20px 10px;}
.logo {display:inline-block;width:120px;}
.h3 {color:gold;}

Bonjour %{madame} %{Patronyme},

### Pour commencer

<vignette>IMGLivre</vignette><vignette>IMGLivre</vignette>

Vous habitez **%{Lieu}**, %{Patronyme} et il y a certainement *une librairie* _là-bas_.

### Le contenu

Voici les choses *que vous serez heureu%{se} de trouver* :

* des livres,
* des conseils,
* des nouveautés.

### Et pour finir

Il vous reste aujourd'hui #{4 + 4} jours pour les commander.

---

IMGLivre

À bientôt,

Les éditions Icare
<logo>IMGlogo</logo>
