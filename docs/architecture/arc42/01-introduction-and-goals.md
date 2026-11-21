---
title: Introduction et objectifs
---

Superlarsen est la plateforme d'hébergement des services en ligne de Superlarsen : site principal, wiki, podcasts et radio. Ce dépôt la décrit entièrement en code : les stacks Docker Compose, leur configuration de déploiement et l'infrastructure qu'elles utilisent.

Cette documentation est tenue au niveau de détail le plus court d'arc42 (_lean_) : chaque section dit l'essentiel et renvoie au dépôt pour le reste.

## Exigences

- Servir cinq applications tierces : WordPress, BookStack, Castopod, LibreTime (avec Icecast) et un accès SFTP au site.
- Déployer chaque changement poussé sur `main` sans étape manuelle.
- Sauvegarder chaque jour les données et les bases, hors du serveur.

## Objectifs de qualité

| Priorité | Objectif                        | Propriété    | Mesure                                                                                                                         | Pourquoi                                                                |
| -------- | ------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| 1        | Maintenabilité par une personne | `#flexible`  | un changement de stack tient dans une PR et se déploie au merge, sans autre geste                                              | une seule personne tient la plateforme ; tout est lisible dans ce dépôt |
| 2        | Récupérabilité                  | `#reliable`  | au plus 24 heures de données perdues ; le délai de reconstruction n'est pas mesuré ([risques](11-risks-and-technical-debt.md)) | une perte du serveur ne doit pas perdre les données (sauvegardes R2)    |
| 3        | Sobriété                        | `#efficient` | un serveur, aucune image construite ici, aucun code applicatif hors du mu-plugin de WordPress                                  | un seul serveur, des images amont, aucun code applicatif à maintenir    |

Les propriétés sont celles de [quality.arc42.org](https://quality.arc42.org). Les scénarios correspondants sont en [section 10](10-quality-requirements.md).

## Parties prenantes

| Qui                                                | Attente                                                                   |
| -------------------------------------------------- | ------------------------------------------------------------------------- |
| Le mainteneur                                      | changer une stack par une PR, la voir déployée au merge                   |
| Les membres de Superlarsen                         | publier sur le site, le wiki, les podcasts et la radio                    |
| Le public                                          | lire le site, écouter les podcasts et le flux radio                       |
| pastis-hosting, qui exploite le serveur et Cartons | des stacks qui se déploient par Cartons seul, sans intervention à la main |
