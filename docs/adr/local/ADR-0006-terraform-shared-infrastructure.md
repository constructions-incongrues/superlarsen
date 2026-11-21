---
adr: ADR-0006
slug: terraform-shared-infrastructure
title: Shared infrastructure is declared in Terraform
status: proposed
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Shared infrastructure is declared in Terraform

## Status

Proposed

## Context

Some of what the stacks need is not a container: the Hetzner volume that holds their data, the DNS records and WAF rule of `superlarsen.fr`, and the R2 buckets. Set by hand in three consoles, these would be visible to nobody but the person who clicked, and could not be rebuilt from the repository.

This decision was in force before it was written down. This record states it; it does not change it.

## Decision

The volume, the DNS records, the WAF rule and the R2 buckets are declared in `infrastructure/terraform/`. State and runs are in Terraform Cloud, workspace `constructions-incongrues/superlarsen`, which also holds the provider tokens.

A change is planned on its branch and applied by hand after the merge. Cartons does not run Terraform.

The server `cartons` is read as a data source, not managed: it belongs to pastis-hosting.

## Consequences

### Positive

- A DNS or WAF change is a reviewed pull request, with its reason in a comment next to the rule.
- The infrastructure can be recreated from the repository.

### Negative

- Between the merge and the manual apply, `main` describes an infrastructure that does not exist yet; nothing detects a forgotten apply.
- Changes made outside Terraform are possible and have happened: the volume was enlarged by hand in 07/2026.
- The zone's encryption mode is set outside Terraform, because of a bug in version 4 of the Cloudflare provider.

### Neutral

- No required check runs `terraform plan`; `checkov` and `tflint` read the files without reaching the providers.

## Alternatives Considered

### The providers' consoles

Nothing to learn, and nothing to read back or review.

### Apply from continuous integration on merge

Removes the forgotten apply, but gives a workflow the tokens of both providers, and applies without anyone having read the plan on `main`.

## References

- engineering/ADR-0012, ADR-0015.
- arc42, sections 4, 6 and 11; the guide "Appliquer un changement Terraform".
