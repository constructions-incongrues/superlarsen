---
title: Risques et dette technique
---

| Risque ou dette                                                        | Effet                                                          | Suite                                                           |
| ---------------------------------------------------------------------- | -------------------------------------------------------------- | --------------------------------------------------------------- |
| Pas de staging : chaque merge part en production                       | une stack cassée est vue après le déploiement                  | assumé ([ADR-0012](../../adr/engineering/ADR-0012-delivery.md)) |
| Images sans tag ou en `latest` (`wordpress`, `libretime-*` par défaut) | une image change sans PR, et un scan ne voit pas ce qui tourne | issue #34                                                       |
| Aucun workflow CI : Trunk ne tourne qu'en local                        | une PR faite depuis GitHub échappe au lint                     | issue #29                                                       |
| Un seul serveur                                                        | sa panne arrête tous les services                              | les sauvegardes R2 permettent la reconstruction                 |
| `stacks/restic/` est obsolète                                          | du bruit dans le dépôt                                         | à supprimer                                                     |
| Le chiffrement de la zone se règle hors Terraform                      | un réglage que le code ne montre pas                           | bogue du provider Cloudflare v4, noté dans `cloudflare.tf`      |
