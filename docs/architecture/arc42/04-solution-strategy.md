---
title: Stratégie de solution
---

Chaque choix sert un [objectif de qualité](01-introduction-and-goals.md).

| Choix                                | Ce qu'il veut dire                                                                                                                  | Objectif servi                 | Décision                                                                                                                       |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| Tout en déclarations                 | des fichiers Docker Compose, TOML et Terraform, sans code applicatif ; le dépôt n'a ni langue principale ni tests                   | maintenabilité, sobriété       | [ADR-0004](../../adr/engineering/ADR-0004-languages.md), [ADR-0007](../../adr/engineering/ADR-0007-tests.md)                   |
| GitOps par Cartons                   | `main` est l'état voulu, et Cartons l'applique à chaque push ; il lit le dépôt et n'y écrit jamais ; il n'y a ni version ni staging | maintenabilité                 | [ADR-0002](../../adr/local/ADR-0002-cartons-config-from-repository.md), [ADR-0012](../../adr/engineering/ADR-0012-delivery.md) |
| Une stack par répertoire             | chaque application est autonome dans `stacks/<nom>/`, avec ses données sous `/mnt/superlarsen/<nom>/`                               | maintenabilité                 | [ADR-0003](../../adr/engineering/ADR-0003-architecture.md)                                                                     |
| Exposition par labels                | un service s'expose en rejoignant le réseau `caddy` avec des labels Caddy ; aucun fichier de proxy à éditer                         | maintenabilité                 | [ADR-0004](../../adr/local/ADR-0004-caddy-labels.md), proposé                                                                  |
| Sauvegarde par opt-in                | un service `stack-back` par stack sauvegarde vers R2 ce que les labels désignent                                                    | récupérabilité                 | [ADR-0005](../../adr/local/ADR-0005-stack-back-backups.md), proposé                                                            |
| Infrastructure partagée en Terraform | volume, DNS, WAF et buckets sont du code, appliqué par Terraform Cloud                                                              | maintenabilité, récupérabilité | [ADR-0006](../../adr/local/ADR-0006-terraform-shared-infrastructure.md), proposé                                               |
| Proxy Cloudflare pour `www` seul     | le site passe par le proxy et le WAF ; les autres domaines arrivent directement sur Caddy                                           | sobriété                       | [ADR-0007](../../adr/local/ADR-0007-cloudflare-proxy-www-only.md), proposé                                                     |

Les ADR-0003, 0004 et 0007 de gouvernance ont le statut _rejected_ : la question qu'ils posent n'a pas d'objet ici, et leur texte dit ce qui en tient lieu.
