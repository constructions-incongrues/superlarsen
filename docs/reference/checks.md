---
title: Checks et workflows
description: Ce que chaque workflow vérifie, quand il tourne, et s'il bloque un merge.
---

Les workflows de `.github/workflows/`. Un check **requis** bloque l'entrée d'une PR dans la merge queue ; la liste fait foi dans `.github/rulesets/main.json`.

| Check         | Workflow                   | Quand                            | Requis | Ce qu'il vérifie                                                             |
| ------------- | -------------------------- | -------------------------------- | ------ | ---------------------------------------------------------------------------- |
| `trunk check` | `lint.yml`                 | PR, merge queue                  | oui    | les linters de `.trunk/trunk.yaml` sur les fichiers modifiés                 |
| `zizmor`      | `audit.yml`                | PR, merge queue                  | oui    | la sécurité des workflows GitHub                                             |
| `checkov`     | `scan.yml`                 | PR, merge queue, push sur `main` | oui    | Terraform et workflows ; résultats envoyés à code scanning                   |
| `docs build`  | `docs.yml`                 | PR, merge queue, push sur `main` | oui    | la construction du site, barre latérale comprise                             |
| `docs deploy` | `docs.yml`                 | push sur `main`                  | —      | publie le site sur GitHub Pages                                              |
| `grype`       | `vulnerabilities.yml`      | PR, merge queue, chaque lundi    | non    | les vulnérabilités corrigeables des images des stacks ; signale sans bloquer |
| `automerge`   | `dependabot-automerge.yml` | PR de Dependabot                 | non    | met en file les mises à jour de patch                                        |

## Hors GitHub Actions

| Check                    | Où                        | Ce qu'il vérifie                         |
| ------------------------ | ------------------------- | ---------------------------------------- |
| GitGuardian, Trunk Check | apps GitHub, sur les PR   | secrets, lint ; jamais requis            |
| `trunk-check-pre-commit` | à chaque commit, en local | les linters, dont `trufflehog` (secrets) |
| `trunk-check-pre-push`   | à chaque push, en local   | les linters                              |

## Outils

Les versions de `zizmor`, `grype`, Node et du lanceur Trunk viennent de `mise.toml` et `mise.lock`, en local comme en CI. Trunk épingle ensuite son CLI et ses linters dans `.trunk/trunk.yaml`.
