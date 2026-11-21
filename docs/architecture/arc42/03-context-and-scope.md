---
title: Contexte et périmètre
---

> La vue `context` du modèle LikeC4 (`docs/architecture/model/superlarsen.c4`) montre ce contexte ; les tableaux ci-dessous le détaillent.

## Contexte métier

| Partenaire | Ce qu'il échange avec la plateforme                                                                    |
| ---------- | ------------------------------------------------------------------------------------------------------ |
| Visiteurs  | pages du site et du wiki, épisodes de podcast, flux radio                                              |
| Membres    | publications WordPress, pages BookStack, épisodes Castopod, programmation LibreTime, fichiers par SFTP |
| Mainteneur | changements par PR sur GitHub                                                                          |

## Contexte technique

| Système externe  | Rôle                                                                              |
| ---------------- | --------------------------------------------------------------------------------- |
| GitHub           | héberge ce dépôt ; Cartons le surveille                                           |
| Cartons (Komodo) | déploie les stacks sur `cartons` à chaque push sur `main`                         |
| Hetzner Cloud    | le serveur `cartons` et le volume `superlarsen` (200 Go)                          |
| Cloudflare       | DNS de `superlarsen.fr`, proxy et WAF pour `www`, buckets R2                      |
| Terraform Cloud  | état et exécution de Terraform (workspace `constructions-incongrues/superlarsen`) |
| Gmail SMTP       | envoi des e-mails des applications et des rapports de sauvegarde                  |
| GitHub Pages     | la page d'état, `status.superlarsen.fr`                                           |

Hors périmètre : le serveur `cartons` lui-même, son Caddy et ses réseaux Docker, qui sont gérés par Cartons.
