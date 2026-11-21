---
adr: ADR-0006
slug: commits
title: Commits
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0006
traits:
  commits:
    scopes:
      [bookstack, castopod, libretime, sftp, wordpress, cloudflare, hetzner]
    tool: none
---

# Commits

## Status

Accepted

> **What is this file?** A question governance asks your repository, with
> the answer it recommends. While it says `status: proposed`, you may edit
> it freely. `revision:` dates the question, not the file: you do not fill
> it, and it only moves when the question changes. `rejected` is a full
> answer: when the question does not apply here, rule `rejected`, remove
> the whole `traits:` block, and say what stands in for it.
> [ADR-0001](ADR-0001-record-architecture-decisions.md) explains the
> mechanics.

## Context

While these keys are empty, an agent writing a commit message **invents a
scope**: `fix(api)`, then `fix(backend)`, then `fix(server)` for the same
place. The history can no longer be filtered, and a release generated from
the messages sorts changes into the wrong places. Once the list is written,
the agent picks from it.

**The format itself is not decided here.** governance requires
[Conventional Commits](https://www.conventionalcommits.org/) and its eleven
types. What is yours to decide is the **scope vocabulary** of this
repository, and the **tool** that enforces it, or the absence of one.

**What `rejected` means in this ADR**, then: that you name neither scopes
nor a tool. Not that you refuse the format, which does not depend on you. A
single-area repository with no pipeline is the typical case.

## Decision

**What governance fixes, and is not up for ruling:** the Conventional
Commits format, its **eleven types** (`feat`, `fix`, `docs`, `style`,
`refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`) and its
breaking-change syntax. It is the one thing that makes histories comparable
from one repository to the next.

**What governance recommends for the tool, and why.**

| Key            | Recommended value | Reason                                                                                                                                                         |
| -------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `commits.tool` | `commitlint`      | **if this repository generates its versions from commit messages**: an off-format message then produces a wrong version, and review does not catch it reliably |

**Check that premise first.** If you set versions by hand, the
recommendation falls, and `none` is just as good an answer. The reason rests
on that premise and only holds for repositories it describes.

**For `commits.scopes`, governance has no answer to recommend**, and that is
information: scopes name **your** areas, and governance does not know them.
A default list would be a guess dressed as a recommendation. Write one word
per area you want to be able to filter on, and not one more. **`[]` is a
full answer**: a single-area repository has nothing to name, and a list
invented on adoption ages worse than no list.

**Ruling: scopes as listed, `tool: none`.** The scopes name the areas
already used in the history: one per stack under `stacks/`, plus `cloudflare`
and `hetzner` for the infrastructure under `infrastructure/terraform/`.
`security`, used once, is a topic that crosses areas, not an area. `tool`
departs from the recommendation because its premise does not hold: the
repository has no tag and no release tool, so no version is derived from
commit messages. Revisit if ADR-0012 introduces a release tool.

## Consequences

### Positive

- An agent picks a scope from a closed list instead of inventing one, so
  the history can be filtered by area.

### Negative

- Nothing refuses an off-format message; review is the only control.
- A closed scope list has to be updated when the repository grows a new
  area; until then, the new area has no scope.

### Neutral

- The eleven types and the breaking-change syntax apply whatever you rule
  here.

## Alternatives Considered

### A closed list of scopes

One word per area of the repository, decided once. Filterable history; the
list needs updating when areas change.

### No scopes

`feat:` with no parentheses. A sound answer for a single-area repository;
write `[]`, not nothing.

### `commitlint`

The reference tool, run in CI: it refuses the pull request, so it also
protects what arrives through the forge.

### `hook`

A local check before each commit. It warns earlier, but it does not see what
is pushed from a machine that does not have it installed.

### No tool

Review keeps the convention. Enough when versions are set by hand.

## References

- Suggested skills: `commit` from `source-control@melodic-software`.
- Adapted from surdesrails [SDR-0006](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0006-commits.md), revision 1.
- [Conventional Commits](https://www.conventionalcommits.org/).
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0009](ADR-0009-branching.md): with `squash`, the merge message is the one that carries the type.

**The keys.**

| Key              | What it holds                               | Allowed values                                |
| ---------------- | ------------------------------------------- | --------------------------------------------- |
| `commits.scopes` | the scopes allowed in this repository       | a list of words, or `[]`                      |
| `commits.tool`   | what enforces the convention, and **where** | `commitlint` in CI, `hook` locally, or `none` |

**What these keys do not cover:** the eleven types and the breaking-change
syntax. They come from governance and are not declared here.

**An empty key is not an answer**: both are required. `[]` and `none` are
answers; empty is not. The value is written in this file and nowhere else;
whoever needs it links here. See ADR-0001 for the check command.
