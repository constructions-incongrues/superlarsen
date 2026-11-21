---
adr: ADR-0009
slug: branching
title: Branching
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0009
traits:
  branching:
    model: github-flow
    merge: squash
    prefixes: [feat, fix, docs, chore]
---

# Branching

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

While these keys are empty, an agent starting a piece of work does not know
**how to name its branch**, whether it may **push to the default branch**,
or whether its eight commits will land **as eight or as one**. All three
get guessed, badly, and differently each time. Once the three values are
written, it has nothing left to guess.

The three models below work the same on any forge. What a pipeline runs on
a branch is a separate question, asked by
[ADR-0011](ADR-0011-forge-and-ci.md) (forge and CI).

## Decision

**What governance recommends, and why.**

| Key                  | Recommended value   | Reason                                                                                                                                                            |
| -------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `branching.model`    | `github-flow`       | it is what the rest of governance already assumes: **one change, one branch, one pull request, one review**. The other two models would mean rewriting that cycle |
| `branching.merge`    | `squash`            | a change becomes **one** commit on the default branch, whose history then reads as the list of changes shipped                                                    |
| `branching.prefixes` | `[feat, fix, docs]` | these are already commit types: nothing new to remember, and a branch name says what it carries                                                                   |

**`squash` moves the message that matters, and it surprises once.** The
commits of a squashed branch disappear from the history; what remains is
the merge message. **That** message must carry the Conventional Commits
type and any breaking-change marker, since it is the one versions are
derived from. Tidy intermediate commits still help review, but they are not
enough.

**Branch prefixes are a subset, not a second list.** governance allows
eleven commit types (see ADR-0006), listed here in full so you have nothing
to look up: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, `revert`. `branching.prefixes` keeps only those that
usefully name a branch. If you add one, **take it from the eleven**:
inventing a twelfth prefix here would create a standard that competes with
the commit one.

**Ruling: the recommendation, with `chore` added to the prefixes.** The
model and the merge match what the repository already does: short branches
merged through pull requests, and a forge that allows squash merges only,
with a linear history. `chore` is added because upgrading a stack's image
version is a frequent change here, and it is neither a feature nor a fix.

## Consequences

### Positive

- The default branch stays shippable, and its history is one commit per
  change.
- A branch name tells an agent and a reviewer what the branch carries
  before anyone opens it.

### Negative

- `squash` loses the detailed history of a branch on the default branch;
  it survives only in the closed pull request.
- The merge message has to be written with care, because it is the one that
  counts.

### Neutral

- Protecting the default branch against direct pushes is a forge setting,
  not something this ADR enforces.

## Alternatives Considered

### `github-flow`

A short branch per change, a pull request, a review, and the default branch
stays shippable at all times. The name comes from GitHub; nothing in the
model is specific to it.

### `trunk-based`

Push to the default branch, and hide what is not ready behind a flag. Very
fast, and expensive: it needs the flags, and a pipeline you trust.

### `gitflow`

Extra `develop`, `release` and `hotfix` branches. Made for software shipped
as versions installed by third parties; costly for a service deployed
continuously.

## References

- Suggested skills: `worktree` and `pull-request` from `source-control@melodic-software`; `finishing-a-development-branch` from `superpowers@superpowers-marketplace`.
- Adapted from surdesrails [SDR-0009](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0009-branching.md), revision 1.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0006](ADR-0006-commits.md): the commit format and its eleven types.

**The keys.**

| Key                  | What it holds                         | Allowed values                                                                                                     |
| -------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `branching.model`    | how work reaches the default branch   | `github-flow`, `trunk-based`, `gitflow`                                                                            |
| `branching.merge`    | what a branch becomes once merged     | `squash` (one commit), `merge-commit` (history kept under a merge commit), `rebase` (commits replayed as they are) |
| `branching.prefixes` | the prefixes allowed in a branch name | a list taken from the eleven commit types, for example `[feat, fix, docs]`                                         |

**A prefix is not a branch name.** The form is
`prefix/description-in-kebab-case`, with a slash, in lower case, for example
`feat/schema-port` or `fix/dead-glossary-link`. This form is not a trait: it
follows from the prefixes, and a key for a separator would be noise.

**The name of the default branch is not a trait, on purpose.** It can be
read from the repository (`git symbolic-ref refs/remotes/origin/HEAD`), and
a key that copies a checkable fact only goes stale.

**Two of the three keys are checked, the third is not.** `branching.model`
and `branching.merge` have a closed set. `branching.prefixes` is a free
list: the schema checks that you wrote one, never what it contains.
Consistency with the eleven types is kept by review.

**All three keys are required**: an empty key is not an answer. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.
