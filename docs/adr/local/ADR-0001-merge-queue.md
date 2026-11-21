---
adr: ADR-0001
slug: merge-queue
title: Merge queue on the default branch
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Merge queue on the default branch

## Status

Accepted

## Context

`main` required every branch to be up to date before merging (`strict: true`). On a day with several pull requests in flight (seven merges on 2026-11-21), each merge forced every other open pull request to be rebased and its CI rerun. One pull request was even closed when the branch it was based on was deleted. Every merge reaches production through Cartons (engineering/ADR-0012), so a merged result that no check has seen is a production risk. engineering/ADR-0022 also asks for a ruleset with zero approvals and an empty bypass list, which this decision lands in.

## Decision

The default branch is protected by a ruleset, versioned in `.github/rulesets/main.json`, with a merge queue:

- squash merges only (engineering/ADR-0009), one pull request per group;
- required checks `trunk check` and `zizmor`, whose workflows run on `pull_request` and `merge_group`; GitHub app checks are never required;
- no strict up-to-date requirement, since the queue tests on the current `main`;
- an empty bypass list: nobody merges outside the queue, the maintainer included.

Putting a pull request in the queue is a merge: under engineering/ADR-0022 only the maintainer does it, never the agent.

## Consequences

### Positive

- No manual rebase after each merge: the queue tests each pull request against the `main` it will land on.
- Every commit on `main` was checked as it stands.
- One merge stays one deployment, as before.

### Negative

- Every required workflow must also trigger on `merge_group`, or the queue waits until it times out.
- No emergency bypass: a hotfix goes through the queue like any change.

### Neutral

- The queue adds a short wait after the merge click, the time for the checks to run once more.

## Alternatives Considered

### Keep the strict up-to-date requirement

No new mechanism, but the rebase cascade returns on every busy day.

### Drop the strict requirement without a queue

Cheapest, but two pull requests that are green apart can break `main` together, and nothing would catch it before production.

### Groups of several pull requests

Faster on busy days, but a failing group does not say which pull request broke it, and it deploys several changes at once.

## References

- engineering/ADR-0009, ADR-0011, ADR-0012, ADR-0022.
- OpenSpec change `ruleset-main-merge-queue`; issue constructions-incongrues/superlarsen#36.
