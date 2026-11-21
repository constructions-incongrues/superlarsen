# AGENTS.md

Instructions pour les agents qui travaillent dans ce dépôt.

## Ce qu'est ce dépôt

L'infrastructure as code et la gestion de configuration de la plateforme d'hébergement Superlarsen. Il définit des stacks Docker Compose et une infrastructure Terraform. Il ne contient pas de code applicatif à construire ni à tester.

## Modèle de déploiement

Les déploiements sont déclenchés automatiquement par **Cartons** (<https://cartons.pastis-hosting.net/stacks>) à chaque push sur `main`. Cartons lit `infrastructure/resources.toml` pour savoir comment déployer chaque stack.

- Toutes les stacks tournent sur un seul serveur Hetzner Cloud, nommé `cartons`.
- Toutes les données persistantes sont sous `/mnt/superlarsen/<nom-de-stack>/` sur ce serveur.
- DNS : tous les domaines sont des CNAME vers `cartons.pastis-hosting.net`, servis par Caddy (reverse proxy sur le serveur, configuré automatiquement par les labels Docker).
- Terraform gère le volume Hetzner, le DNS Cloudflare et les buckets R2. L'état est dans Terraform Cloud (workspace `constructions-incongrues/superlarsen`).

## Lint

Trunk lance les linters. Linters actifs : `checkov` (sécurité IaC), `markdownlint`, `prettier`, `taplo` (TOML), `tflint`, `trufflehog` (secrets), `yamllint`.

```bash
trunk check        # lint des fichiers modifiés
trunk check --all  # lint de tout le dépôt
trunk fmt          # formatage automatique
```

Trunk installe les hooks `trunk-fmt-pre-commit` et `trunk-check-pre-push`.

## Terraform

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## Propagation des changements

Cartons récupère les changements par un bloc `resource_sync` de `resources.toml`, qui surveille `infrastructure/resources.toml` et `stacks/`. Un push sur `main` déclenche une synchronisation, sans étape manuelle dans l'interface de Cartons.

## Fichiers clés

- `infrastructure/resources.toml` : la source unique de la configuration de toutes les stacks consommées par Cartons. Les secrets y sont des gabarits `[[NOM_DE_VARIABLE]]`, injectés par Cartons au déploiement.
- `stacks/<nom>/compose.yaml` : la définition Docker Compose de chaque stack.

## Stacks

| Stack     | URL                                                                   | Notes                                                |
| --------- | --------------------------------------------------------------------- | ---------------------------------------------------- |
| bookstack | <https://wiki.superlarsen.fr>                                         | Wiki, MySQL 9.2                                      |
| castopod  | <https://castopod.superlarsen.fr>                                     | Hébergement de podcasts, MariaDB + Redis             |
| libretime | <https://libretime.superlarsen.fr> / <https://icecast.superlarsen.fr> | Programmation radio, PostgreSQL + RabbitMQ + Icecast |
| wordpress | <https://www.superlarsen.fr>                                          | Site principal, MySQL 8.4                            |
| sftp      | <sftp://sftp.superlarsen.fr:2222>                                     | Accès aux fichiers du volume WordPress               |

## LibreTime : traitement particulier

LibreTime demande une étape avant déploiement (définie dans `resources.toml`) qui :

1. lance `envsubst` pour produire `config.yml` à partir de `config.template.yml` et du `.env` injecté ;
2. lance les migrations de base de données avec `docker compose run --rm api libretime-api migrate`.

Pour modifier `stacks/libretime/`, `config.template.yml` reste la source de vérité. Ne jamais modifier le `config.yml` généré.

## Sauvegardes

Chaque stack (sauf sftp) inclut un service `stack-back` (`ghcr.io/lawndoc/stack-back:v1.4.5`) qui lance chaque jour à 01:00 UTC une sauvegarde Restic vers Cloudflare R2. Rétention : 7 quotidiennes, 4 hebdomadaires, 12 mensuelles, 3 annuelles.

Les services s'inscrivent aux sauvegardes par des labels Docker :

- `stack-back.volumes: true` : sauvegarde les volumes nommés ou montés du service ;
- `stack-back.mysql: true` / `stack-back.mariadb: true` / `stack-back.postgres: true` : fait un dump de la base avant la sauvegarde.

## Réseau

Un service exposé sur le web rejoint le réseau Docker externe `caddy` : le reverse proxy le route d'après ses labels Docker.

Les e-mails partent directement vers `smtp.gmail.com`, avec les réglages de `resources.toml`. Le réseau externe `smtp`, déclaré par trois stacks, n'est rejoint par aucun service.

Pour ajouter un service exposé sur le web, ajouter le réseau `caddy` et les labels Caddy correspondants.

## Atteindre main

- Un changement atteint `main` par une pull request, puis par la merge queue ([ADR-0001](docs/adr/local/ADR-0001-merge-queue.md)). Personne ne pousse directement sur `main` et personne ne contourne la file, le mainteneur compris.
- C'est le mainteneur qui met une PR dans la file. L'agent ne merge pas, n'approuve pas et ne met rien en file (ADR-0022) : `.claude/settings.json` lui refuse `gh pr merge` et `gh pr review`.
- Un workflow dont le check est requis se déclenche sur `pull_request` et sur `merge_group`.
- Cartons applique le dépôt et n'y écrit jamais ([ADR-0002](docs/adr/local/ADR-0002-cartons-config-from-repository.md)). Une stack se modifie par une PR, jamais dans l'interface de Cartons : la synchronisation suivante écraserait la modification.

<!-- ontrack:begin -->

## Project instructions (ontrack)

When asked to review, rule on or supersede an ADR, run `npx ontrack review [adr]` and follow its output.

### Record architecture decisions (engineering/ADR-0001-record-architecture-decisions)

```yaml
record-architecture-decisions:
  format: nygard
```

### Localization (engineering/ADR-0002-localization)

```yaml
localization:
  language:
    default: french
    documentation:
    commits:
    code: english
    comments:
```

### Validation (engineering/ADR-0005-validation)

```yaml
validation:
  boundary: none
  data_files: json-schema
```

### Commits (engineering/ADR-0006-commits)

```yaml
commits:
  scopes: [bookstack, castopod, libretime, sftp, wordpress, cloudflare, hetzner]
  tool: none
```

### Documentation (engineering/ADR-0008-documentation)

```yaml
docs:
  tool: starlight
  root: docs/
  audience: public
  channels: [main]
```

### Branching (engineering/ADR-0009-branching)

```yaml
branching:
  model: github-flow
  merge: squash
  prefixes: [feat, fix, docs, chore]
```

### Architecture documentation (engineering/ADR-0010-architecture-documentation)

```yaml
architecture:
  document: arc42
  model: likec4
  diagrams: mermaid
```

### Forge and continuous integration (engineering/ADR-0011-forge-and-ci)

```yaml
forge:
  gate: blocking
  audit: zizmor
```

### Delivery (engineering/ADR-0012-delivery)

```yaml
delivery:
  target: platform
  environments:
    - name: production
      trigger: merge
  release_tool: none
  release_notes: none
  registry: none
deployment:
  manifests: none
```

### Work tracking (engineering/ADR-0014-work-tracking)

```yaml
tracking:
  tool: github-issues
  project: constructions-incongrues/superlarsen
```

### Secrets (engineering/ADR-0015-secrets)

```yaml
secrets:
  storage: keychain
  guard: trufflehog
```

### Changes (engineering/ADR-0016-changes)

```yaml
changes:
  framework: openspec
  schema: spec-driven-with-adr
```

### Agent tooling (engineering/ADR-0017-agent-tooling)

```yaml
agent:
  hosts: [claude-code]
```

### Dependencies (engineering/ADR-0018-dependencies)

```yaml
dependencies:
  updater: dependabot
  automerge: patch
```

### Vulnerabilities (engineering/ADR-0019-vulnerabilities)

```yaml
vulnerabilities:
  sbom: none
  scanner: grype
  fail_on: critical
```

### Adding a dependency (engineering/ADR-0020-adding-dependencies)

```yaml
admission:
  approver: person
  install_scripts: ignored
```

### Review and merge (engineering/ADR-0022-review-and-merge)

```yaml
review:
  by: maintainer
  approvals: 0
```

### License (engineering/ADR-0023-license)

```yaml
license:
  spdx: MIT
```

### Code scanning (engineering/ADR-0024-code-scanning)

```yaml
code_scanning:
  tool: checkov
  fail_on: low
```

### Tools outside the package manager (engineering/ADR-0025-tools)

```yaml
tools:
  manager: mise
```

### Agent identity (engineering/ADR-0026-agent-identity)

```yaml
agent:
  identity: maintainer
```

<!-- ontrack:end -->
