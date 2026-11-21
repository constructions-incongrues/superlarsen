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

Un changement atteint `main` par une PR puis par la merge queue, sans contournement ([ADR-0001](../../adr/local/ADR-0001-merge-queue.md)). Un check **requis** bloque l'entrée dans la file ; la liste fait foi dans `.github/rulesets/main.json`.

| Check         | Workflow                   | Quand                            | Requis | Ce qu'il vérifie                                                                                                                       |
| ------------- | -------------------------- | -------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `trunk check` | `lint.yml`                 | PR, merge queue                  | oui    | les linters de `.trunk/trunk.yaml` sur les fichiers modifiés                                                                           |
| `zizmor`      | `audit.yml`                | PR, merge queue                  | oui    | la sécurité des workflows GitHub                                                                                                       |
| `checkov`     | `scan.yml`                 | PR, merge queue, push sur `main` | oui    | Terraform et workflows ; résultats envoyés à code scanning                                                                             |
| `docs build`  | `docs.yml`                 | PR, merge queue, push sur `main` | oui    | la construction du site, sa barre latérale et ses liens internes                                                                       |
| `docs deploy` | `docs.yml`                 | push sur `main`                  | —      | publie le site sur GitHub Pages                                                                                                        |
| `grype`       | `vulnerabilities.yml`      | PR, merge queue, chaque lundi    | non    | les vulnérabilités corrigeables des images ; signale sans bloquer ([ADR-0003](../../adr/local/ADR-0003-third-party-image-scanning.md)) |
| `automerge`   | `dependabot-automerge.yml` | PR de Dependabot                 | non    | met en file les mises à jour de patch                                                                                                  |

En local, Trunk lance ses linters, dont `trufflehog` (secrets), à chaque commit et à chaque push. Les apps GitHub GitGuardian et Trunk Check commentent les PR sans être requises. Les versions des outils viennent de `mise.toml` et `mise.lock`, en local comme en CI.
