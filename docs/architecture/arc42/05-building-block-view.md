---
title: Vue en briques
---

> Ces vues viennent du modèle LikeC4 (`docs/architecture/model/superlarsen.c4`). Le modèle complet se parcourt sur [/superlarsen/model/](/superlarsen/model/) ; les tableaux ci-dessous détaillent les vues.

<script type="module" src="/superlarsen/model/likec4-views.js"></script>

<likec4-view view-id="stacks"></likec4-view>
<likec4-view view-id="wordpressStack"></likec4-view>
<likec4-view view-id="bookstackStack"></likec4-view>
<likec4-view view-id="castopodStack"></likec4-view>
<likec4-view view-id="libretimeStack"></likec4-view>

## Niveau 1 : le dépôt

| Brique                | Emplacement                     | Responsabilité                                                                                                |
| --------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Configuration Cartons | `infrastructure/resources.toml` | déclare chaque stack, son environnement et ses secrets (`[[VARIABLE]]`), le dépôt suivi et la synchronisation |
| Stacks                | `stacks/<nom>/compose.yaml`     | définissent les services de chaque application                                                                |
| Infrastructure        | `infrastructure/terraform/`     | volume Hetzner, DNS, WAF et buckets R2 Cloudflare                                                             |

## Niveau 2 : les stacks

| Stack       | Services                                                                                               | Exposition                                           |
| ----------- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| `wordpress` | WordPress, MySQL 8.0, `stack-back` ; un mu-plugin d'anonymat des comptes                               | `www.superlarsen.fr`, derrière le proxy Cloudflare   |
| `bookstack` | BookStack, MySQL 9.2, `stack-back`                                                                     | `wiki.superlarsen.fr`                                |
| `castopod`  | Castopod, MariaDB, Redis, `stack-back`                                                                 | `castopod.superlarsen.fr`                            |
| `libretime` | API, legacy, nginx, playout, liquidsoap, analyzer, worker, PostgreSQL, RabbitMQ, Icecast, `stack-back` | `libretime.superlarsen.fr`, `icecast.superlarsen.fr` |
| `sftp`      | atmoz/sftp, sur le volume WordPress                                                                    | `sftp.superlarsen.fr:2222`                           |
