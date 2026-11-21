---
title: Vue d'exécution
---

## Déployer un changement

```mermaid
sequenceDiagram
    participant M as Mainteneur
    participant G as GitHub
    participant C as Cartons
    participant S as Serveur cartons
    M->>G: met une PR verte dans la merge queue
    G->>G: trunk check et zizmor sur main + PR, puis squash
    G->>C: webhook de push
    C->>C: synchronise resources.toml et stacks/
    C->>S: docker compose up de chaque stack modifiée
```

Pour LibreTime, Cartons lance d'abord l'étape `pre_deploy` : `envsubst` produit `config.yml` depuis `config.template.yml`, puis `libretime-api migrate` migre la base.

## Sauvegarder

```mermaid
sequenceDiagram
    participant B as stack-back
    participant D as Base de données
    participant R as Cloudflare R2
    participant E as Gmail SMTP
    Note over B: chaque jour à 01:00 UTC
    B->>D: dump (labels stack-back.mysql / postgres)
    B->>R: sauvegarde Restic des volumes et dumps
    B->>R: purge 7 j / 4 s / 12 m / 3 a
    B->>E: rapport par e-mail
```

## Modifier l'infrastructure

Un changement sous `infrastructure/terraform/` est planifié puis appliqué à la main sur Terraform Cloud, après le merge.
