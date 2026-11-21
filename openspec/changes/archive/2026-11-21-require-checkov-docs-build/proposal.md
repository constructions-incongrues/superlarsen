Issue served: none

## Why

Le ruleset de `main` n'exige que `trunk check` et `zizmor`. Deux checks tournent pourtant déjà sur chaque PR et dans la merge queue sans rien bloquer : `checkov` (ADR-0024, `fail_on: low`) et `docs build`. Une PR qui casse l'analyse du code ou le site peut donc arriver sur `main`, et `main` publie le site (ADR-0008).

## What Changes

- Le ruleset de `main` (`.github/rulesets/main.json`) exige aussi `checkov` et `docs build`.
- `grype` reste non requis : il signale sans bloquer (ADR local 0003).

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `merge-to-main` : la liste des checks requis s'allonge de `checkov` et `docs build`.

## Impact

- Réglage de la forge : le ruleset `main` (id 27807281), appliqué par `gh api`.
- `.github/rulesets/main.json`.
