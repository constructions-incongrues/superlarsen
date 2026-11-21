## Context

`scan.yml` (job `checkov`) et `docs.yml` (job `docs build`) se déclenchent déjà sur `pull_request` et `merge_group`, et ont réussi à chaque passage dans la file.

## Goals / Non-Goals

**Goals:** bloquer une PR qui casse l'analyse du code ou le site.

**Non-Goals:** rendre `grype` bloquant (ADR local 0003) ; changer les workflows.

## Decisions

- Ajout de `{ "context": "checkov", "integration_id": 15368 }` et `{ "context": "docs build", "integration_id": 15368 }` aux `required_status_checks` du ruleset. Le check `Checkov` en majuscule, publié par code scanning à partir du SARIF, n'est pas requis.
- Le ruleset est appliqué avant le merge de cette PR, par `gh api -X PUT …/rulesets/27807281 --input .github/rulesets/main.json` depuis cette branche, puisque les deux workflows sont déjà sur `main`. La PR qui coche la dernière tâche archive le change.

## Risks / Trade-offs

- [Une panne de Pages ou de npm bloque toutes les PR via `docs build`] → `docs build` ne déploie rien : il ne dépend que de npm. En cas de panne, le ruleset reste modifiable par un administrateur, et l'acte est visible dans le journal d'audit.
