---
title: Appliquer un changement Terraform
description: Modifier le DNS, le WAF, les buckets ou le volume, puis l'appliquer.
---

Ce guide applique un changement de `infrastructure/terraform/` : DNS et WAF Cloudflare, buckets R2, volume Hetzner.

## Avant de commencer

- Un accès au workspace Terraform Cloud `constructions-incongrues/superlarsen`.
- `terraform` installé par `mise install --locked`, et `terraform login` déjà fait.

## 1. Préparer le changement

Modifiez les fichiers `.tf` sur une branche, puis vérifiez-les :

```bash
cd infrastructure/terraform
terraform init
terraform validate
trunk check
```

## 2. Lire le plan

```bash
terraform plan
```

Le plan tourne dans Terraform Cloud, avec les variables du workspace (les jetons Cloudflare et Hetzner). Vérifiez qu'il ne touche que ce que vous attendez, et en particulier qu'il ne détruit rien.

## 3. Merger, puis appliquer

Ouvrez la PR et mettez-la en file (`gh pr merge <numéro> --squash`). Une fois sur `main`, appliquez :

```bash
terraform apply
```

L'application est manuelle : Cartons ne touche pas à Terraform.

## Cas particuliers

- **Le chiffrement de la zone** (Full strict) se règle hors Terraform, avec la CLI Cloudflare, à cause d'un bogue du provider v4 décrit dans `cloudflare.tf`.
- **Le volume Hetzner** ne se réduit pas, et il est protégé contre la suppression.
