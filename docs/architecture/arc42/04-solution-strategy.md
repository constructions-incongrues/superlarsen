---
title: Stratégie de solution
---

- **Tout en déclarations** : des fichiers Docker Compose, TOML et Terraform, sans code applicatif. Le dépôt n'a ni langue principale ni tests ([ADR-0004](../../adr/engineering/ADR-0004-languages.md), [ADR-0007](../../adr/engineering/ADR-0007-tests.md)).
- **GitOps par Cartons** : `main` est l'état voulu, et Cartons l'applique à chaque push. Il n'y a ni version ni staging ([ADR-0012](../../adr/engineering/ADR-0012-delivery.md)).
- **Une stack par répertoire** : chaque application est autonome dans `stacks/<nom>/`, avec ses données sous `/mnt/superlarsen/<nom>/` ([ADR-0003](../../adr/engineering/ADR-0003-architecture.md)).
- **Exposition par labels** : un service s'expose en rejoignant le réseau `caddy` avec des labels Caddy ; aucun fichier de proxy à éditer.
- **Sauvegarde par opt-in** : un service `stack-back` par stack sauvegarde ce que les labels désignent.
- **Infrastructure partagée en Terraform** : volume, DNS, WAF et buckets.
