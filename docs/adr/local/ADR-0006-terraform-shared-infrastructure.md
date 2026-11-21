---
adr: ADR-0006
slug: terraform-shared-infrastructure
title: L'infrastructure partagée est déclarée en Terraform
status: proposed
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# L'infrastructure partagée est déclarée en Terraform

## Status

Proposed

## Context

Une partie de ce dont les stacks ont besoin n'est pas un conteneur : le volume Hetzner qui porte leurs données, les enregistrements DNS et la règle WAF de `superlarsen.fr`, et les buckets R2. Réglés à la main dans trois consoles, ils ne seraient visibles que de la personne qui a cliqué, et ne pourraient pas être reconstruits depuis le dépôt.

Cette décision était en vigueur avant d'être écrite. Cet ADR la constate ; il ne la change pas.

## Decision

Le volume, les enregistrements DNS, la règle WAF et les buckets R2 sont déclarés dans `infrastructure/terraform/`. L'état et les exécutions sont dans Terraform Cloud, workspace `constructions-incongrues/superlarsen`, qui détient aussi les jetons des providers.

Un changement est planifié sur sa branche et appliqué à la main après le merge. Cartons ne lance pas Terraform.

Le serveur `cartons` est lu comme une source de données, pas géré : il appartient à pastis-hosting.

## Consequences

### Positive

- Un changement de DNS ou de WAF est une PR relue, avec sa raison en commentaire à côté de la règle.
- L'infrastructure peut être recréée depuis le dépôt.

### Negative

- Entre le merge et l'application manuelle, `main` décrit une infrastructure qui n'existe pas encore ; rien ne détecte une application oubliée.
- Des changements hors de Terraform sont possibles et ont eu lieu : le volume a été agrandi à la main en 07/2026.
- Le mode de chiffrement de la zone se règle hors de Terraform, à cause d'un bogue de la version 4 du provider Cloudflare.

### Neutral

- Aucun check requis ne lance `terraform plan` ; `checkov` et `tflint` lisent les fichiers sans atteindre les providers.

## Alternatives Considered

### Les consoles des hébergeurs

Rien à apprendre, et rien à relire ni à retrouver.

### Appliquer depuis l'intégration continue, au merge

Supprime l'application oubliée, mais donne à un workflow les jetons des deux hébergeurs, et applique sans que personne ait lu le plan sur `main`.

## References

- engineering/ADR-0012, ADR-0015.
- arc42, sections 4, 6 et 11 ; le guide « Appliquer un changement Terraform ».
