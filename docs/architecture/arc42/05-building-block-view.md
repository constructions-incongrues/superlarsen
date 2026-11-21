---
title: Vue en briques
---

> La vue en briques sera générée depuis le modèle LikeC4 (issue #23). En attendant, les briques sont décrites en prose.

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

`stacks/restic/` est un reste de l'ancien système de sauvegarde, remplacé par `stack-back`.
