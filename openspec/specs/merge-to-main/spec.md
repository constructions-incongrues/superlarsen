# merge-to-main Specification

## Purpose

Comment un changement atteint `main` : par une pull request, puis par la merge queue, sans contournement. Seul le mainteneur met en file, et le dépôt reste la seule source de la configuration Cartons (ADR-0022, ADR local 0001 et 0002).

## Requirements

### Requirement: Tout changement atteint main par une pull request

Le ruleset de `main` SHALL refuser tout push direct sur `main`, y compris celui du mainteneur et celui de Cartons/Komodo. Sa liste de contournement SHALL être vide.

#### Scenario: Push direct refusé

- **WHEN** quiconque pousse un commit directement sur `main`
- **THEN** GitHub refuse le push

#### Scenario: Pas de contournement administrateur

- **WHEN** le mainteneur lance `gh pr merge --admin` sur une PR dont les checks ne sont pas passés
- **THEN** GitHub refuse le merge

### Requirement: Aucune approbation n'est exigée

Le ruleset SHALL exiger une pull request avec 0 approbation (ADR-0022, `review.approvals: 0`), et la résolution des conversations.

#### Scenario: PR du mainteneur sans relecture

- **WHEN** le mainteneur met en file sa propre PR, verte, sans approbation
- **THEN** la PR entre dans la merge queue

#### Scenario: Conversation non résolue

- **WHEN** une PR a une conversation de revue non résolue
- **THEN** la PR ne peut pas entrer dans la merge queue

### Requirement: Les merges passent par une merge queue

`main` SHALL être protégée par une merge queue. Elle merge en squash (ADR-0009), une PR par groupe, après avoir fait tourner les checks requis sur le résultat du merge avec le `main` du moment.

#### Scenario: Deux PR vertes en file

- **WHEN** deux PR vertes sont mises en file l'une après l'autre
- **THEN** la seconde est testée sur un `main` qui contient déjà la première, sans rebase manuel
- **AND** chacune devient un commit squash distinct sur `main`

#### Scenario: Échec dans la file

- **WHEN** un check requis échoue sur le groupe de la merge queue
- **THEN** la PR sort de la file et `main` n'est pas modifiée

### Requirement: Les checks requis tournent dans la file

Les checks requis SHALL être `trunk check`, `zizmor`, `checkov` et `docs build`, et leurs workflows SHALL se déclencher sur `pull_request` et sur `merge_group`. Les checks des apps GitHub (GitGuardian, Trunk Check) SHALL NOT être requis. `grype` SHALL NOT être requis (ADR local 0003).

#### Scenario: Groupe de merge queue

- **WHEN** une PR entre dans la merge queue
- **THEN** `trunk check`, `zizmor`, `checkov` et `docs build` tournent sur l'événement `merge_group` et rendent un verdict

#### Scenario: Site cassé

- **WHEN** une PR fait échouer `docs build`
- **THEN** la PR ne peut pas entrer dans la merge queue

### Requirement: L'agent ne merge pas et n'approuve pas

`.claude/settings.json` SHALL refuser à l'agent `gh pr merge` et `gh pr review` (ADR-0022, `review.by: maintainer`). Mettre une PR en file est un merge, et seul le mainteneur le fait.

#### Scenario: L'agent tente de merger

- **WHEN** l'agent lance `gh pr merge` ou `gh pr merge --auto`
- **THEN** Claude Code refuse la commande

### Requirement: Le dépôt est la seule source de la configuration Cartons

Le `resource_sync` de `infrastructure/resources.toml` SHALL déclarer `managed = false`. Cartons applique le dépôt et n'y écrit jamais.

#### Scenario: Modification dans l'interface de Cartons

- **WHEN** une stack est modifiée dans l'interface de Cartons
- **THEN** aucun commit n'est poussé sur `main`
- **AND** la prochaine synchronisation depuis le dépôt l'emporte
