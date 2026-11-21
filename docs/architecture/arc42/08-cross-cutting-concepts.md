---
title: Concepts transversaux
---

## Secrets

Aucune valeur dans le dépôt. `resources.toml` porte des références `[[NOM]]`, remplies par Cartons au déploiement ; Terraform reçoit ses tokens de Terraform Cloud. Trufflehog, lancé par Trunk à chaque commit, et GitGuardian, sur les PR, cherchent les fuites ([ADR-0015](../../adr/engineering/ADR-0015-secrets.md)).

## Exposition web

Un service web rejoint le réseau Docker externe `caddy` et porte des labels Caddy ; Caddy obtient le certificat et route le domaine.

## E-mail

Les applications et `stack-back` envoient directement par `smtp.gmail.com`, avec le même compte et un expéditeur par application ; les réglages sont dans `resources.toml`. Trois stacks déclarent un réseau Docker externe `smtp` qu'aucun service ne rejoint ([dette](11-risks-and-technical-debt.md)).

## Sauvegardes

Le service `stack-back` (`ghcr.io/lawndoc/stack-back`) de chaque stack, sauf sftp, sauvegarde par Restic vers R2 ; sa version est dans chaque `compose.yaml`. Un service s'inscrit par labels : `stack-back.volumes: true` pour ses volumes, `stack-back.mysql: true`, `stack-back.mariadb: true` ou `stack-back.postgres: true` pour un dump de sa base.

## Surveillance

La page d'état <https://status.superlarsen.fr>, servie par GitHub Pages hors du serveur, dit si les services répondent. Le rapport quotidien de `stack-back`, par e-mail, dit si la sauvegarde a réussi. Rien d'autre n'alerte.

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
