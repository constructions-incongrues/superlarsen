---
adr: ADR-0005
slug: stack-back-backups
title: Each stack backs itself up to R2 with stack-back
status: proposed
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Each stack backs itself up to R2 with stack-back

## Status

Proposed

## Context

Recoverability is the second quality goal of the platform (arc42, section 1): losing the server must not lose the data. Everything runs on one server, so a backup has to leave it, and leave its provider. One person maintains the platform, so a backup that needs a script per database would not be kept up.

This decision was in force before it was written down. This record states it; it does not change it.

## Decision

Every stack that holds data includes a `backup` service, `ghcr.io/lawndoc/stack-back`, which runs Restic:

- a service opts in by label: `stack-back.volumes: true` for its volumes, `stack-back.mysql`, `stack-back.mariadb` or `stack-back.postgres` for a dump of its database;
- the backup runs every day at 01:00 UTC and goes to Cloudflare R2, outside Hetzner;
- retention is 7 daily, 4 weekly, 12 monthly and 3 yearly snapshots;
- a report is sent by e-mail after each run.

`sftp` holds no data of its own and has no `backup` service.

## Consequences

### Positive

- At most 24 hours of data are lost.
- Adding a service to the backups is one label, in the pull request that adds the service.
- The backups survive the loss of the server, of its volume, and of the Hetzner account.

### Negative

- The Restic password and the R2 keys are injected by Cartons, which runs on the server being backed up. The only other copy is in the maintainer's keychain (engineering/ADR-0015): without it the backups cannot be read.
- A full rebuild from these backups has never been exercised (arc42, section 11).
- A failed backup is known only from the e-mail report, to one recipient.

### Neutral

- Each stack runs its own `backup` service, so the same image and settings are repeated four times.

## Alternatives Considered

### Hetzner volume snapshots

No per-database dump, and the copy stays with the provider of the server.

### One backup job for the whole server

A single place to configure, but it lives on the server, outside the repository, and knows nothing of the stacks' databases.

## References

- engineering/ADR-0012, ADR-0015.
- arc42, sections 6, 8, 10 and 11; the guide "Restaurer une stack depuis une sauvegarde".
