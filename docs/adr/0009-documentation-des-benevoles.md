# 9. La documentation des bénévoles vit dans un wiki BookStack

Date : 2025-10

Les mots techniques sont expliqués dans le [sommaire](README.md#mots-techniques).

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

Dans une radio de bénévoles, le savoir tourne avec les personnes : comment se
brancher en studio, déposer une émission, passer en direct, qui appeler quand
le flux coupe. Sans endroit commun, ce savoir vit dans des mails et dans la
tête de deux ou trois personnes.

Les options courantes : un dossier de documents partagés, un pad, un wiki
hébergé (par exemple un espace Notion), ou un wiki libre sur son serveur.

## Décision

Notre documentation est dans un wiki [BookStack](https://www.bookstackapp.com),
sur `https://wiki.superlarsen.fr`.

- La stack est dans
  [`stacks/bookstack/compose.yaml`](../../stacks/bookstack/compose.yaml) :
  BookStack 25.7.3 et une base MySQL 9.2.
- Les images et pièces jointes sont sur le volume du serveur, sauvegardées
  comme le reste (voir l'[ADR-0011](0011-sauvegardes.md)).

Pourquoi BookStack _(à confirmer)_ : il range les pages en étagères, livres et
chapitres, ce qui se lit sans formation, et son éditeur ne demande pas de
connaître une syntaxe.

## Ce que nous ne savons pas

- Ce que le wiki contient aujourd'hui, et s'il est lu par les animateurs.
- Qui le tient à jour.

## Conséquences

### Ce que nous gagnons

- Un seul endroit pour la documentation, à nous, sans abonnement.
- Des comptes par personne, avec des droits de lecture et d'écriture.

### Ce que nous devons tenir

- Un service de plus à mettre à jour et à surveiller.
- Si le serveur tombe, la doc qui explique quoi faire tombe avec lui. La
  procédure de secours doit aussi exister ailleurs (voir
  l'[ADR-0010](0010-comptes-et-acces.md)).

### Pour une autre radio

Un dossier partagé bien rangé, ou un pad, suffit tant que vous êtes peu
nombreux. Le wiki devient utile quand la même question revient chaque mois.
Dans tous les cas, gardez hors du serveur la page « quoi faire quand tout est
en panne ».
