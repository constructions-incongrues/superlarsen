---
title: Risques et dette technique
---

## Risques

Du plus grave au moins grave. La priorité croise la probabilité et l'effet.

| Priorité | Risque                                                                 | Effet                                                                                             | Suite                                                                                        |
| -------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Haute    | La reconstruction après perte du serveur n'a jamais été exercée        | le délai est inconnu, et une étape qui manque ne se verra que le jour où il faudra la suivre      | ouvert : exercer le [scénario](06-runtime-view.md) sur un serveur de test, et noter le délai |
| Haute    | Une seule personne tient la plateforme et détient la copie des secrets | sans elle, ni déploiement ni reconstruction ; sans son trousseau, les sauvegardes sont illisibles | ouvert                                                                                       |
| Moyenne  | Un seul serveur, qui porte aussi Cartons                               | sa panne arrête tous les services et l'outil qui les déploie                                      | assumé ; les sauvegardes R2 permettent la reconstruction                                     |
| Moyenne  | Les images tierces portent des vulnérabilités critiques corrigeables   | rien ne bloque un merge ; une personne doit lire le rapport de grype                              | assumé ([ADR-0003](../../adr/local/ADR-0003-third-party-image-scanning.md))                  |
| Moyenne  | Pas de staging : chaque merge part en production                       | une stack cassée est vue après le déploiement, et rien ne revient en arrière tout seul            | assumé ([ADR-0012](../../adr/engineering/ADR-0012-delivery.md))                              |
| Basse    | Pas de contournement d'urgence de la merge queue                       | un correctif urgent attend les checks comme tout changement                                       | assumé ([ADR-0001](../../adr/local/ADR-0001-merge-queue.md))                                 |
| Basse    | Le serveur, Caddy et Cartons sont exploités par un tiers               | un changement de leur côté peut casser l'exposition ou le déploiement sans changement ici         | assumé ([contraintes](02-constraints.md))                                                    |

## Dette technique

| Dette                                                                      | Brique                               | Effet                                                                                            | Suite                                                      |
| -------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| La base de BookStack est dans un volume Docker, hors de `/mnt/superlarsen` | `bookstack`                          | elle disparaît avec le serveur, alors que le volume Hetzner survit ; seul le dump R2 reste       | ouvert : la déplacer sous `/mnt/superlarsen/bookstack/`    |
| Les entrées de direct sont publiées en clair sur les ports 8001 et 8002    | `libretime`                          | le mot de passe de la source passe sans chiffrement                                              | ouvert                                                     |
| Terraform s'applique à la main, après le merge                             | `infrastructure/terraform/`          | `main` et l'infrastructure réelle peuvent diverger ; le volume a déjà été agrandi hors Terraform | ouvert                                                     |
| Le chiffrement de la zone se règle hors Terraform                          | `infrastructure/terraform/`          | un réglage que le code ne montre pas                                                             | bogue du provider Cloudflare v4, noté dans `cloudflare.tf` |
| Le réseau `smtp` est déclaré par trois stacks et rejoint par aucun service | `bookstack`, `castopod`, `wordpress` | une déclaration sans effet, que la documentation a longtemps prise pour le chemin des e-mails    | ouvert : le retirer, ou le brancher                        |
| Le bucket `superlarsen` n'a pas d'usage documenté                          | `infrastructure/terraform/`          | on ne sait pas ce qui le lit ni ce qui y écrit                                                   | ouvert                                                     |
