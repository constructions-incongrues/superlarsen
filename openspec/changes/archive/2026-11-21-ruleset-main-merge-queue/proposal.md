Issue served: constructions-incongrues/superlarsen#36

## Why

La protection de `main` dit une chose et la pratique en fait une autre. La protection exige une approbation. Pourtant, chaque PR est ouverte et mergée par le mainteneur, sans relecture, grâce à son contournement (`--admin`). ADR-0022 (`review.by: maintainer`, `review.approvals: 0`) demande un ruleset qui dise vrai : une PR obligatoire, 0 approbation, et une liste de contournement vide.

`strict: true` oblige aussi chaque branche à être à jour avec `main`. Un jour où plusieurs PR sont en vol, comme le 2026-11-21 avec 7 merges, chaque merge force à rebaser toutes les autres et à relancer leur CI. Une PR a même été fermée quand la branche qui lui servait de base a été supprimée. Une merge queue teste chaque PR sur le `main` du moment, puis la merge, sans rebase manuel. Elle se règle dans le même ruleset : c'est pourquoi les deux tiennent dans un seul change.

## What Changes

- Un ruleset sur `main` remplace la protection de branche classique. Il exige une PR, 0 approbation et la résolution des conversations, et sa liste de contournement est vide.
- Le ruleset active une merge queue : méthode squash (ADR-0009), une PR par groupe, et les checks `trunk check` et `zizmor` requis.
- `lint.yml` et `audit.yml` se lancent aussi sur `merge_group`, sinon la file attend un check qui ne vient jamais.
- Les checks des apps GitHub (GitGuardian, Trunk Check) ne sont pas requis, car rien ne garantit qu'ils tournent sur `merge_group`.
- `.claude/settings.json` refuse `gh pr merge` et `gh pr review` à l'agent (ADR-0022). Mettre une PR en file revient à la merger, et l'agent ne le fait pas.
- **BREAKING** : `gh pr merge --admin` ne contourne plus rien. Le mainteneur merge en mettant la PR dans la file.
- **BREAKING** : `resource_sync` passe à `managed = false` dans `infrastructure/resources.toml`. Une modification faite dans l'interface de Cartons n'est plus réécrite sur `main` (plus de `[Komodo] Commit Sync`, qui poussait avec le compte du mainteneur) : le dépôt devient la seule source, et toute modification passe par une PR.

## Capabilities

### New Capabilities

- `merge-to-main` : comment un changement atteint `main`, c'est-à-dire la PR obligatoire, qui merge, la file d'attente, les checks requis et ce que l'agent n'a pas le droit de faire.

### Modified Capabilities

Aucune : il n'existe pas encore de spec dans `openspec/specs/`.

## Impact

- Réglages de la forge : le ruleset de `main`, la merge queue, et la suppression de la protection de branche actuelle.
- `.github/workflows/lint.yml`, `.github/workflows/audit.yml` (ce dernier vient de #47, à merger avant).
- `.claude/settings.json`.
- `infrastructure/resources.toml` (`managed = false`), et donc la façon de modifier une stack, qui ne passe plus par l'interface de Cartons.
- Déploiement (ADR-0012) : avec une PR par groupe, chaque merge reste un déploiement distinct par Cartons.

## Open Questions

Aucune. La question de Komodo est tranchée : `managed = false`, sans contournement.
