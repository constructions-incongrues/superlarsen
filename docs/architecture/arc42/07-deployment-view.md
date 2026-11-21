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

## Stacks déployées

| Stack     | Adresse                                                              | Cartons                                                              |
| --------- | -------------------------------------------------------------------- | -------------------------------------------------------------------- |
| bookstack | <https://wiki.superlarsen.fr>                                        | <https://cartons.pastis-hosting.net/stacks/68e7e547a8d8ffe5d97c1bd2> |
| castopod  | <https://castopod.superlarsen.fr>                                    | <https://cartons.pastis-hosting.net/stacks/68961ec43f85f8cb80eccfa8> |
| libretime | <https://libretime.superlarsen.fr>, <https://icecast.superlarsen.fr> | <https://cartons.pastis-hosting.net/stacks/6895ceb9dffe250360ab3f2e> |
| sftp      | `sftp://sftp.superlarsen.fr:2222`                                    | <https://cartons.pastis-hosting.net/stacks/690f80656eba66e67ff936e7> |
| wordpress | <https://www.superlarsen.fr>                                         | <https://cartons.pastis-hosting.net/stacks/689624b63f85f8cb80ecd01a> |

L'état des services est sur <https://status.superlarsen.fr>.
