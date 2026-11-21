---
title: Contraintes
---

- **Un seul serveur** Hetzner Cloud, `cartons`, partagé avec d'autres projets hébergés par Cartons.
- **Cartons** (une instance de Komodo) déploie les stacks : sa configuration est `infrastructure/resources.toml`, et rien ne se déploie en dehors de lui.
- **Images amont** : chaque stack utilise l'image publiée par son projet ; ce dépôt n'en construit aucune ([ADR-0012](../../adr/engineering/ADR-0012-delivery.md)).
- **Plan Cloudflare Free** : un envoi de plus de 100 Mo ne passe pas par le proxy, ce qui exclut Castopod et LibreTime du proxy ; seul `www` est proxifié.
- **Secrets hors du dépôt** : injectés par Cartons et Terraform Cloud ([ADR-0015](../../adr/engineering/ADR-0015-secrets.md)).
- **Langues** : prose en français, symboles en anglais ([ADR-0002](../../adr/engineering/ADR-0002-localization.md)).
