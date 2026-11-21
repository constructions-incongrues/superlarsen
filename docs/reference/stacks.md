---
title: Stacks
description: Chaque stack, son adresse, ses services, ses images et ses données.
---

Les stacks déployées par Cartons sur le serveur `cartons`. Les données persistantes sont sous `/mnt/superlarsen/<stack>/`. La source de vérité est `stacks/<stack>/compose.yaml` ; cette page la résume.

## bookstack

|            |                                                                             |
| ---------- | --------------------------------------------------------------------------- |
| Adresse    | <https://wiki.superlarsen.fr>                                               |
| Cartons    | <https://cartons.pastis-hosting.net/stacks/68e7e547a8d8ffe5d97c1bd2>        |
| Services   | `bookstack` (`solidnerd/bookstack:26.9.2`), `mysql` (`mysql:9.2`), `backup` |
| Sauvegarde | dump MySQL et volumes, chaque nuit                                          |

## castopod

|            |                                                                                                                  |
| ---------- | ---------------------------------------------------------------------------------------------------------------- |
| Adresse    | <https://castopod.superlarsen.fr>                                                                                |
| Cartons    | <https://cartons.pastis-hosting.net/stacks/68961ec43f85f8cb80eccfa8>                                             |
| Services   | `app` (`castopod/castopod:1.15.7`), `mariadb` (`mariadb:10.5`), `redis` (`redis:7.2.17-alpine`, cache), `backup` |
| Sauvegarde | dump MariaDB et volumes, chaque nuit                                                                             |

## libretime

|               |                                                                                                                                                                                                                                              |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Adresses      | <https://libretime.superlarsen.fr> (programmation), <https://icecast.superlarsen.fr> (flux)                                                                                                                                                  |
| Cartons       | <https://cartons.pastis-hosting.net/stacks/6895ceb9dffe250360ab3f2e>                                                                                                                                                                         |
| Services      | `api`, `legacy`, `nginx`, `playout`, `liquidsoap`, `analyzer`, `worker` (`ghcr.io/libretime/*:4.5.0`), `icecast` (`ghcr.io/libretime/icecast:2.4.4`), `postgres` (`postgres:15`), `rabbitmq` (`rabbitmq:3.13-alpine`, sans volume), `backup` |
| Sauvegarde    | dump PostgreSQL et médiathèque, chaque nuit                                                                                                                                                                                                  |
| Particularité | avant chaque déploiement, Cartons produit `config.yml` depuis `config.template.yml` et migre la base                                                                                                                                         |

## sftp

|            |                                                                               |
| ---------- | ----------------------------------------------------------------------------- |
| Adresse    | `sftp://sftp.superlarsen.fr:2222`                                             |
| Cartons    | <https://cartons.pastis-hosting.net/stacks/690f80656eba66e67ff936e7>          |
| Services   | `sftp` (`atmoz/sftp:alpine`, épinglée par digest), sur le volume de WordPress |
| Sauvegarde | aucune propre : les fichiers sont ceux de WordPress                           |

## wordpress

|               |                                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| Adresse       | <https://www.superlarsen.fr>, derrière le proxy Cloudflare                                             |
| Cartons       | <https://cartons.pastis-hosting.net/stacks/689624b63f85f8cb80ecd01a>                                   |
| Services      | `wordpress` (`wordpress:7.1.5-php8.3-apache`), `db` (`mysql:8.4.13`), `backup`                         |
| Sauvegarde    | dump MySQL et fichiers du site, chaque nuit                                                            |
| Particularité | l'origine n'accepte `www` que depuis les plages Cloudflare ; un défi Cloudflare protège `wp-login.php` |

## Communs à toutes les stacks

|                   |                                                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| Sauvegardes       | `ghcr.io/lawndoc/stack-back:v1.4.5`, chaque jour à 01:00 UTC, vers R2 ; rétention 7 jours, 4 semaines, 12 mois, 3 ans |
| Réseaux           | `caddy` (exposition web), `smtp` (envoi d'e-mails)                                                                    |
| État des services | <https://status.superlarsen.fr>                                                                                       |
