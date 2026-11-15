# 7. Afficher ce qui passe, et les titres des 7 derniers jours

Date : 2025-08

Les mots techniques sont expliqués dans le [sommaire](README.md#mots-techniques).

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

« C'était quoi, ce morceau ? » est la question que les auditeurs posent le
plus. Afficher le titre en cours et garder un historique des titres diffusés
répond à cette question, et met en valeur les artistes programmés.

## Décision

Le site affiche ce qui passe à l'antenne, et permet de chercher dans les
titres diffusés pendant les 7 derniers jours.

Ces informations viennent de LibreTime, qui sait ce qu'il diffuse (voir
l'[ADR-0005](0005-automatisation-d-antenne.md)). La lecture se fait par son
API _(à confirmer)_.

## Ce que nous ne savons pas

- Comment le site récupère ces informations : extension WordPress, code du
  thème ou autre.
- Pendant un direct, si le titre affiché est celui que l'animateur annonce, ou
  le dernier titre programmé.

## Conséquences

### Ce que nous gagnons

- Les auditeurs retrouvent les morceaux, sans écrire à la radio.
- L'historique de diffusion existe déjà : il pourra servir aux déclarations de
  droits (voir l'[ADR-0014](0014-droits-musicaux.md)).

### Ce que nous devons tenir

- Le lien entre le site et LibreTime : une mise à jour de l'un peut casser
  l'affichage.

### Pour une autre radio

Sans automatisation, Icecast affiche le titre que le logiciel d'envoi lui
transmet : la plupart des lecteurs web savent le lire. Pour l'historique, une
simple liste publiée après chaque émission suffit.
