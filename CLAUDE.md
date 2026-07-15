# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Infrastructure-as-Code and configuration management for the Superlarsen hosting platform. It defines Docker Compose stacks and Terraform infrastructure — there is no application code to build or test.

## Deployment model

Deployments are triggered automatically by **Cartons** (https://cartons.pastis-hosting.net/stacks) when commits are pushed to `main`. Cartons reads `infrastructure/resources.toml` to know how to deploy each stack.

- All stacks run on a single Hetzner Cloud server named `cartons`
- All persistent data lives under `/mnt/superlarsen/<stack-name>/` on that server
- DNS: all domains CNAME to `cartons.pastis-hosting.net`, served through Caddy (reverse proxy on the server, auto-configured via Docker labels)
- Terraform manages the Hetzner volume and Cloudflare DNS/R2 buckets; state is in Terraform Cloud (`constructions-incongrues/superlarsen` workspace)

## Linting

Trunk is the linter runner. Active linters: `checkov` (IaC security), `markdownlint`, `prettier`, `taplo` (TOML), `tflint`, `trufflehog` (secrets), `yamllint`.

```bash
trunk check        # lint all changed files
trunk check --all  # lint everything
trunk fmt          # auto-format
```

Trunk runs `trunk-fmt-pre-commit` and `trunk-check-pre-push` hooks automatically.

## Terraform

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## How changes propagate

Cartons picks up changes via a `resource_sync` block in `resources.toml` that watches `infrastructure/resources.toml` and `stacks/`. Pushing to `main` triggers a sync — no manual Cartons UI step needed.

## Key files

- `infrastructure/resources.toml` — single source of truth for all stack configurations consumed by Cartons. Secrets are templated as `[[VARIABLE_NAME]]` and injected by Cartons at deploy time.
- `stacks/<name>/compose.yaml` — Docker Compose definition for each stack.

## Stacks

| Stack     | URL                                                               | Notes                                             |
| --------- | ----------------------------------------------------------------- | ------------------------------------------------- |
| bookstack | https://wiki.superlarsen.fr                                       | Wiki, MySQL 9.2                                   |
| castopod  | https://castopod.superlarsen.fr                                   | Podcast hosting, MariaDB + Redis                  |
| libretime | https://libretime.superlarsen.fr / https://icecast.superlarsen.fr | Radio scheduling, PostgreSQL + RabbitMQ + Icecast |
| wordpress | https://www.superlarsen.fr                                        | Main site, MySQL 8.0                              |
| sftp      | sftp://sftp.superlarsen.fr:2222                                   | File access to WordPress volume                   |

## LibreTime special handling

LibreTime requires a pre-deploy step (defined in `resources.toml`) that:

1. Runs `envsubst` to render `config.template.yml` → `config.yml` using the injected `.env`
2. Runs database migrations via `docker compose run --rm api libretime-api migrate`

When editing `stacks/libretime/`, keep `config.template.yml` as the source of truth — never edit the generated `config.yml`.

## Backups

Every stack (except sftp) includes a `stack-back` service (`ghcr.io/lawndoc/stack-back:v1.4.5`) that runs Restic backups daily at 01:00 UTC to Cloudflare R2. Retention: 7 daily / 4 weekly / 12 monthly / 3 yearly.

Services opt in to backups via Docker labels:

- `stack-back.volumes: true` — backs up named/bind volumes on that service
- `stack-back.mysql: true` / `stack-back.postgres: true` — dumps the database before backup

## Networking

Each stack connects to two external Docker networks:

- `caddy` — for reverse proxy routing (services expose themselves via Docker labels)
- `smtp` — for outbound email via Gmail SMTP

When adding a new web-facing service, add the `caddy` network and the appropriate Caddy labels.
