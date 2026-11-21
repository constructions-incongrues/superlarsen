---
adr: ADR-0002
slug: cartons-config-from-repository
title: The repository is the only source of the Cartons configuration
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# The repository is the only source of the Cartons configuration

## Status

Accepted

## Context

Cartons (Komodo) syncs `infrastructure/resources.toml` and `stacks/` from this repository. With `managed = true` on its `resource_sync`, a change made in the Cartons interface is also written back to `main`, as a `[Komodo] Commit Sync` commit pushed with the maintainer's account. Eighteen such commits exist, the last on 2026-03-29. ADR-0001 leaves `main` with no bypass, so those pushes would be refused.

## Decision

The `resource_sync` declares `managed = false`. Cartons applies the repository and never writes to it. Every change to a stack goes through a pull request.

## Consequences

### Positive

- `main` has a single writer, the merge queue, and every change is reviewed and checked.
- What runs is always what the repository says.

### Negative

- A change made in the Cartons interface is overwritten by the next sync; quick edits there are no longer possible.

### Neutral

- Cartons still deploys on every push to `main` (engineering/ADR-0012).

## Alternatives Considered

### Komodo as a bypass actor

Keeps the interface write-back, but needs an account or app of its own for Komodo, since it pushes as the maintainer today, and is a departure from engineering/ADR-0022 for a feature last used in March 2026.

## References

- ADR-0001; engineering/ADR-0012, ADR-0022.
- OpenSpec change `ruleset-main-merge-queue`; issue constructions-incongrues/superlarsen#36.
