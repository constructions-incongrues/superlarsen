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

## Organisation du dépôt

Le dépôt range ce qui décrit les briques en trois endroits. Ce ne sont pas des briques : ce sont les fichiers qui les déclarent.

| Emplacement                     | Ce qu'il déclare                                                                               |
| ------------------------------- | ---------------------------------------------------------------------------------------------- |
| `stacks/<nom>/compose.yaml`     | les services de chaque stack                                                                   |
| `infrastructure/resources.toml` | pour Cartons : chaque stack, son environnement et ses secrets (`[[VARIABLE]]`), le dépôt suivi |
| `infrastructure/terraform/`     | le volume Hetzner, le DNS, le WAF et les buckets R2                                            |

## Niveau 1 : les stacks

La vue « Briques : les stacks » montre les cinq stacks ; les vues suivantes ouvrent chacune d'elles (niveau 2). Une seule stack dépend d'une autre : `sftp` monte le dossier du site de `wordpress`.

| Stack       | Emplacement         | Services (niveau 2)                                                                                    | Exposition                                                                                                           |
| ----------- | ------------------- | ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| `wordpress` | `stacks/wordpress/` | WordPress, MySQL 8.4, `stack-back` ; un mu-plugin d'anonymat des comptes                               | `www.superlarsen.fr`, derrière le proxy Cloudflare                                                                   |
| `bookstack` | `stacks/bookstack/` | BookStack, MySQL 9.2, `stack-back`                                                                     | `wiki.superlarsen.fr`                                                                                                |
| `castopod`  | `stacks/castopod/`  | Castopod, MariaDB, Redis, `stack-back`                                                                 | `castopod.superlarsen.fr`                                                                                            |
| `libretime` | `stacks/libretime/` | API, legacy, nginx, playout, liquidsoap, analyzer, worker, PostgreSQL, RabbitMQ, Icecast, `stack-back` | `libretime.superlarsen.fr`, `icecast.superlarsen.fr` ; les ports 8001 et 8002 du serveur, pour les entrées de direct |
| `sftp`      | `stacks/sftp/`      | atmoz/sftp, sur le dossier du site de WordPress                                                        | `sftp.superlarsen.fr:2222`                                                                                           |
