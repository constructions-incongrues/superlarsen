---
title: Introduction et objectifs
---

Superlarsen est la plateforme d'hébergement des services en ligne de Superlarsen : site principal, wiki, podcasts et radio. Ce dépôt la décrit entièrement en code : les stacks Docker Compose, leur configuration de déploiement et l'infrastructure qu'elles utilisent.

## Exigences

- Servir cinq applications tierces : WordPress, BookStack, Castopod, LibreTime (avec Icecast) et un accès SFTP au site.
- Déployer chaque changement poussé sur `main` sans étape manuelle.
- Sauvegarder chaque jour les données et les bases, hors du serveur.

## Objectifs de qualité

| Priorité | Objectif                        | Pourquoi                                                                |
| -------- | ------------------------------- | ----------------------------------------------------------------------- |
| 1        | Maintenabilité par une personne | une seule personne tient la plateforme ; tout est lisible dans ce dépôt |
| 2        | Récupérabilité                  | une perte du serveur ne doit pas perdre les données (sauvegardes R2)    |
| 3        | Sobriété                        | un seul serveur, des images amont, aucun code applicatif à maintenir    |

## Parties prenantes

| Qui                        | Attente                                                 |
| -------------------------- | ------------------------------------------------------- |
| Le mainteneur              | changer une stack par une PR, la voir déployée au merge |
| Les membres de Superlarsen | publier sur le site, le wiki, les podcasts et la radio  |
| Le public                  | lire le site, écouter les podcasts et le flux radio     |
