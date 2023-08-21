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

Bonjour %{madame} %{Patronyme},

<vignette>IMGLivre</vignette><vignette>IMGLivre</vignette>

Vous habitez **%{Lieu}**, %{Patronyme} et il y a certainement *une librairie* _là-bas_.

Voici les choses *que vous pouvez y trouver* :

* des livres,
* des conseils,
* des nouveautés.

Il vous reste aujourd'hui #{4 + 4} jours pour les commander.

IMGLivre

À bientôt,

Les éditions Icare
<logo>IMGlogo</logo>
