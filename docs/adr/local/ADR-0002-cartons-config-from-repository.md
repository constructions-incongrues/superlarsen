---
adr: ADR-0002
slug: cartons-config-from-repository
title: Le dépôt est la seule source de la configuration de Cartons
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Le dépôt est la seule source de la configuration de Cartons

## Status

Accepted

## Context

Cartons (Komodo) synchronise `infrastructure/resources.toml` et `stacks/` depuis ce dépôt. Avec `managed = true` sur son `resource_sync`, un changement fait dans l'interface de Cartons est aussi réécrit sur `main`, par un commit `[Komodo] Commit Sync` poussé avec le compte du mainteneur. Il existe dix-huit commits de ce genre, le dernier du 2026-03-29. ADR-0001 laisse `main` sans contournement : ces pushes seraient donc refusés.

## Decision

Le `resource_sync` déclare `managed = false`. Cartons applique le dépôt et n'y écrit jamais. Tout changement d'une stack passe par une PR.

## Consequences

### Positive

- `main` n'a qu'un seul auteur d'écriture, la merge queue, et chaque changement est relu et vérifié.
- Ce qui tourne est toujours ce que dit le dépôt.

### Negative

- Un changement fait dans l'interface de Cartons est écrasé par la synchronisation suivante ; les retouches rapides n'y sont plus possibles.

### Neutral

- Cartons déploie toujours à chaque push sur `main` (engineering/ADR-0012).

## Alternatives Considered

### Komodo comme acteur de contournement

Garde la réécriture depuis l'interface, mais demande un compte ou une app propre à Komodo, puisqu'il pousse aujourd'hui au nom du mainteneur, et s'écarte d'engineering/ADR-0022 pour une fonction utilisée pour la dernière fois en mars 2026.

## References

- ADR-0001 ; engineering/ADR-0012, ADR-0022.
- Changement OpenSpec `ruleset-main-merge-queue` ; issue constructions-incongrues/superlarsen#36.
