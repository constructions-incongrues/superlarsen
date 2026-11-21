---
title: Vue de déploiement
---

> Ces vues viennent du modèle LikeC4 (`docs/architecture/model/superlarsen.c4`). Le modèle complet se parcourt sur [/superlarsen/model/](/superlarsen/model/) ; les tableaux ci-dessous détaillent les vues.

<script type="module" src="/superlarsen/model/likec4-views.js"></script>

<likec4-view view-id="production"></likec4-view>

| Nœud                                        | Ce qui y tourne                                                                                                                 |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Serveur Hetzner `cartons`                   | Docker, Caddy, l'agent Cartons, toutes les stacks                                                                               |
| Volume Hetzner `superlarsen` (200 Go, ext4) | les données persistantes, sous `/mnt/superlarsen/<stack>/`                                                                      |
| Cloudflare                                  | la zone `superlarsen.fr` ; chaque sous-domaine est un CNAME vers `cartons.pastis-hosting.net`, sauf `status`, vers GitHub Pages |
| Cloudflare R2 (WEUR)                        | les buckets `superlarsen` et `superlarsen-backups`                                                                              |

Un seul environnement, la production. `www` est le seul enregistrement proxifié par Cloudflare ; l'origine WordPress n'accepte `www` que depuis les plages Cloudflare. Les autres sous-domaines arrivent directement sur Caddy.
