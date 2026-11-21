---
adr: ADR-0003
slug: architecture
title: Software architecture
status: rejected
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Software architecture

## Status

Rejected

> **What is this file?** A question governance asks your repository, with
> the answer it recommends. While it says `status: proposed`, you may edit
> it freely. `revision:` dates the question, not the file: you do not fill
> it, and it only moves when the question changes. `rejected` is a full
> answer: when the question does not apply here, rule `rejected`, remove
> the whole `traits:` block, and say what stands in for it.
> [ADR-0001](ADR-0001-record-architecture-decisions.md) explains the
> mechanics.

## Context

While this key is empty, an agent adding a module to this repository
invents a structure, and invents a different one each time, because it
infers from whichever file it has open. Once the value is written, it knows
where code goes and what may depend on what.

The question comes early because it is expensive to undo: a directory
layout and dependency boundaries change one module at a time, long after
anyone stopped thinking about them.

Where the architecture is _documented_ is a separate question, asked by
[ADR-0010](ADR-0010-architecture-documentation.md).

## Decision

**What governance recommends, and why.**

| Key                    | Recommended value | Reason                                                                                                                                                                     |
| ---------------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `architecture.pattern` | `hexagonal`       | **it suits agentic work**: the domain depends on no I/O, so an agent writes and tests it without a running environment, and changes an adapter without touching the domain |

The reason deserves unpacking, because it is not the usual one. A hexagonal
pattern bounds what an agent has to hold in mind to change a rule: the
domain alone, with no database, no network, no framework. It is also what
makes a change checkable without standing up an environment, so an agent
knows whether it broke something instead of assuming it did not.

**This recommendation does not bind your repository.** It holds for an
application service of moderate size. Under about 500 lines, or for a
repository that is not a service, `monolithic` is often the honest answer;
and if the question has no object here, rule `rejected`.

**Ruling: rejected.** This repository has no application code to
structure: it declares third-party stacks (`stacks/<name>/compose.yaml`,
images published by their own projects) and the infrastructure under
`infrastructure/`. What stands in for a pattern is that layout: one
self-contained stack per `stacks/<name>/` directory, its persistent data under
`/mnt/superlarsen/<name>/` on the server, and shared infrastructure
(Terraform, the Cartons configuration) in `infrastructure/`. The arc42
building block view (ADR-0010) describes it.

## Consequences

### Positive

- An agent does not impose a software pattern on declarations that have
  none.
- Adding a service means adding a directory under `stacks/`, with nothing
  else to wire.

### Negative

- The layout is a convention, not a pattern a tool can check; review keeps
  it.

### Neutral

- If the repository grows application code of its own, a new ADR names its
  pattern.

## Alternatives Considered

### `hexagonal`

Ports and adapters: the domain depends on no I/O.

### `layered`

Classic layers, each knowing only the next one down.

### `microservices`

Services deployed separately.

### `monolithic`

One deployable, without strong internal boundaries.

### `event-driven`

Components communicate through events.

### `soa`

Shared services, coupled through contracts.

## References

- Suggested skills: `architecture` and `system-design` from `engineering@knowledge-work-plugins`.
- Adapted from surdesrails [SDR-0003](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0003-architecture.md), revision 1 (its `architecture.pattern` key; `architecture.document` is asked by ADR-0010).
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.

**The key.**

| Key                    | What it holds                                      | Allowed values                                                               |
| ---------------------- | -------------------------------------------------- | ---------------------------------------------------------------------------- |
| `architecture.pattern` | the pattern that structures this repository's code | `event-driven`, `hexagonal`, `layered`, `microservices`, `monolithic`, `soa` |

**One key, on purpose.** governance does not carry your directory layout,
package names or dependency rules: they are decided in your repository and
written in this ADR's body. The trait carries only what an agent must read
without interpreting.

**An empty key is not an answer**: this one is required. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.
