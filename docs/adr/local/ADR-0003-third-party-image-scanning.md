---
adr: ADR-0003
slug: third-party-image-scanning
title: Vulnerability scans of third-party images report, they do not block
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Vulnerability scans of third-party images report, they do not block

## Status

Accepted

## Context

engineering/ADR-0019 rules `vulnerabilities.scanner: grype` and `vulnerabilities.fail_on: critical`: a critical vulnerability with a fix available fails the required check. Its rule 4 says an agent fixes by updating the dependency, through ADR-0018's updater.

This repository builds no image (engineering/ADR-0012: `delivery.target: platform`, `registry: none`). Every image in `stacks/*/compose.yaml` is published by its upstream project. On 2026-11-21, grype found fixable critical vulnerabilities in 12 of the 18 images, and in the newest release of every one of them as well: LibreTime 4.5.0 is its latest release, and MySQL 9.7.4, RabbitMQ 4.2.9, Castopod 1.15.7 and stack-back v1.5.4 still ship packages with a fixed version available. "Fixable" means a fixed package exists, not that a fixed image does. The repository cannot apply the fix; only the publisher can.

A check that fails on every pull request for a reason no change here can fix is a check that gets turned off, which is the outcome ADR-0019 warns against.

## Decision

This repository departs from engineering/ADR-0019 on `fail_on` for third-party images only:

- the `vulnerabilities` workflow runs grype on every image of `stacks/*/compose.yaml`, on every pull request and weekly, with `--only-fixed`, and **reports without failing**;
- a critical finding is acted on by updating the image, when a release that fixes it exists and is older than the cooldown, in a pull request of its own;
- `vulnerabilities.fail_on: critical` stays the rule for anything this repository would build or publish itself.

No ignore rule is written: findings stay visible in every run.

## Consequences

### Positive

- The scan runs and is read, instead of being a red check everyone learns to skip.
- Upgrades stay deliberate pull requests, each deployed on its own (engineering/ADR-0012).

### Negative

- Nothing stops a merge while a running image carries a critical vulnerability; a person has to read the report.

### Neutral

- If the repository starts building its own images, ADR-0019's blocking threshold applies to them unchanged.

## Alternatives Considered

### Keep `fail_on: critical` and update every image

Tried on 2026-11-21: no current release of the affected images clears the threshold, so the check would stay red.

### Keep `fail_on: critical` with one ignore rule per finding

Over a hundred entries, each saying "the publisher has not shipped the fix", to be renewed at every release: ADR-0019 rule 5's "switch turned off", spelt out one line at a time.

## References

- engineering/ADR-0012, ADR-0018, ADR-0019.
- Issue constructions-incongrues/superlarsen#34.
