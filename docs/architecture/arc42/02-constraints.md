---
title: Contraintes
---

Une contrainte est ici ce que le mainteneur ne peut pas changer seul.

| Contrainte                                                                                                                          | Pourquoi elle s'impose                                                                                                                |
| ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Un seul serveur** Hetzner Cloud, `cartons`, partagé avec d'autres projets                                                         | Superlarsen n'a pas de serveur à lui : pastis-hosting l'héberge sur le sien                                                           |
| **Cartons** (une instance de Komodo) déploie les stacks, à partir de `infrastructure/resources.toml` ; rien ne se déploie en dehors | c'est l'outil de déploiement de ce serveur, commun à tous les projets qu'il héberge                                                   |
| **Caddy et les réseaux Docker** du serveur sont donnés                                                                              | ils appartiennent au serveur, pas à ce dépôt ; une stack s'y branche, elle ne les configure pas                                       |
| **Plan Cloudflare Free** : un envoi de plus de 100 Mo ne passe pas par le proxy, et une règle WAF ne lit pas le corps d'une requête | la zone est sur le plan gratuit ; Castopod et LibreTime, qui reçoivent de gros fichiers, restent hors du proxy, et seul `www` y passe |

Trois règles ressemblent à des contraintes et sont des décisions, que le mainteneur peut réviser par un ADR : les images viennent de leur projet amont et ce dépôt n'en construit aucune ([ADR-0012](../../adr/engineering/ADR-0012-delivery.md)) ; les secrets restent hors du dépôt ([ADR-0015](../../adr/engineering/ADR-0015-secrets.md)) ; la prose est en français et les symboles en anglais ([ADR-0002](../../adr/engineering/ADR-0002-localization.md)).
