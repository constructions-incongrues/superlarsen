---
title: Risques et dette technique
---

| Risque ou dette                                   | Effet                                         | Suite                                                           |
| ------------------------------------------------- | --------------------------------------------- | --------------------------------------------------------------- |
| Pas de staging : chaque merge part en production  | une stack cassée est vue après le déploiement | assumé ([ADR-0012](../../adr/engineering/ADR-0012-delivery.md)) |
| Un seul serveur                                   | sa panne arrête tous les services             | les sauvegardes R2 permettent la reconstruction                 |
| Le chiffrement de la zone se règle hors Terraform | un réglage que le code ne montre pas          | bogue du provider Cloudflare v4, noté dans `cloudflare.tf`      |
