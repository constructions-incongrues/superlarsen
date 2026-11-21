# AGENTS.md

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
