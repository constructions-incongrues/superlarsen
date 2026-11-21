---
title: Contexte et périmètre
---

> Ces vues viennent du modèle LikeC4 (`docs/architecture/model/superlarsen.c4`). Le modèle complet se parcourt sur [/superlarsen/model/](/superlarsen/model/) ; les tableaux ci-dessous détaillent les vues.

<script type="module" src="/superlarsen/model/likec4-views.js"></script>

<likec4-view view-id="context"></likec4-view>

## Contexte métier

| Partenaire | Ce qu'il échange avec la plateforme                                                                    |
| ---------- | ------------------------------------------------------------------------------------------------------ |
| Visiteurs  | pages du site et du wiki, épisodes de podcast, flux radio                                              |
| Membres    | publications WordPress, pages BookStack, épisodes Castopod, programmation LibreTime, fichiers par SFTP |
| Mainteneur | changements par PR sur GitHub                                                                          |

## Contexte technique

| Système externe  | Rôle                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------- |
| GitHub           | héberge ce dépôt, que Cartons surveille, et la page d'état `status.superlarsen.fr` (GitHub Pages) |
| Cartons (Komodo) | déploie les stacks sur `cartons` à chaque push sur `main`                                         |
| Caddy            | reverse proxy du serveur : obtient les certificats et route les domaines vers les stacks          |
| Hetzner Cloud    | le serveur `cartons` et le volume `superlarsen` (200 Go)                                          |
| Cloudflare       | DNS de `superlarsen.fr`, proxy et WAF pour `www`                                                  |
| Cloudflare R2    | les buckets `superlarsen` et `superlarsen-backups` ; le second reçoit les sauvegardes             |
| Terraform Cloud  | état et exécution de Terraform (workspace `constructions-incongrues/superlarsen`)                 |
| Gmail SMTP       | envoi des e-mails des applications et des rapports de sauvegarde                                  |

Hors périmètre : le serveur `cartons` lui-même, Cartons, Caddy et les réseaux Docker du serveur. Ce dépôt s'en sert et ne les configure pas.
