---
title: Concepts transversaux
---

## Secrets

Aucune valeur dans le dépôt. `resources.toml` porte des références `[[NOM]]`, remplies par Cartons au déploiement ; Terraform reçoit ses tokens de Terraform Cloud. Trufflehog, lancé par Trunk à chaque commit, et GitGuardian, sur les PR, cherchent les fuites ([ADR-0015](../../adr/engineering/ADR-0015-secrets.md)).

## Exposition web

Un service web rejoint le réseau Docker externe `caddy` et porte des labels Caddy ; Caddy obtient le certificat et route le domaine.

## E-mail

Chaque stack rejoint le réseau `smtp` et envoie par le SMTP de Gmail, avec un expéditeur par application.

## Sauvegardes

Le service `stack-back` (`ghcr.io/lawndoc/stack-back:v1.4.5`) de chaque stack, sauf sftp, sauvegarde par Restic vers R2. Un service s'inscrit par labels : `stack-back.volumes: true` pour ses volumes, `stack-back.mysql: true` ou `stack-back.postgres: true` pour un dump de sa base.

## Qualité des changements

Trunk lance `checkov`, `tflint`, `yamllint`, `taplo`, `markdownlint`, `prettier` et `trufflehog` à chaque commit et à chaque push, puis en CI sur chaque PR (`trunk check`), avec zizmor qui audite les workflows. Un changement atteint `main` par une PR puis par la merge queue, qui relance ces deux checks sur le résultat, sans contournement ([ADR-0001](../../adr/local/ADR-0001-merge-queue.md)).
