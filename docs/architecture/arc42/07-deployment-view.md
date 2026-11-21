---
title: Vue de déploiement
---

> La vue de déploiement sera générée depuis le modèle LikeC4 (issue #23). En attendant, le déploiement est décrit en prose.

| Nœud                                        | Ce qui y tourne                                                                                                                 |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Serveur Hetzner `cartons`                   | Docker, Caddy, l'agent Cartons, toutes les stacks                                                                               |
| Volume Hetzner `superlarsen` (200 Go, ext4) | les données persistantes, sous `/mnt/superlarsen/<stack>/`                                                                      |
| Cloudflare                                  | la zone `superlarsen.fr` ; chaque sous-domaine est un CNAME vers `cartons.pastis-hosting.net`, sauf `status`, vers GitHub Pages |
| Cloudflare R2 (WEUR)                        | les buckets `superlarsen` et `superlarsen-backups`                                                                              |

Un seul environnement, la production. `www` est le seul enregistrement proxifié par Cloudflare ; l'origine WordPress n'accepte `www` que depuis les plages Cloudflare. Les autres sous-domaines arrivent directement sur Caddy.
