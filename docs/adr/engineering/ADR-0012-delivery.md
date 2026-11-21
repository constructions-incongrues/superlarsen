---
adr: ADR-0012
slug: delivery
title: Delivery
status: accepted
revision: 3
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0012
traits:
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
---

# Delivery

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

While these keys are empty, an agent finishing a change does not know
whether merging puts it in front of users or only onto the default branch,
nor what produces a version. Of all the questions governance asks, this is
the one where a wrong guess reaches people outside the repository.

**Releasing and deploying are two acts.** Releasing makes a named version
with its changelog (`delivery.release_tool`) and the notes that come with it
(`delivery.release_notes`). Deploying puts something in
service (each environment's trigger). A repository can do one without the
other: a library releases and never deploys; a service can deploy every
merge without naming versions.

**Semantic versioning is not a question here**: `feat` gives a minor
version, `fix` and `perf` a patch, a breaking change a major. The commit
format is [ADR-0006](ADR-0006-commits.md). Calendar versioning would be a
departure, declared in your own ADR.

## Decision

**What governance recommends, and why.**

| Key                      | Recommended value                                           | Reason                                                                                                                                                                                                                                             |
| ------------------------ | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `delivery.target`        | _no recommendation_                                         | it describes what this repository ships, which governance cannot know. It is the trait that changes most what an agent writes: an image job, platform configuration, a publish job, or nothing                                                     |
| `delivery.environments`  | staging on `merge`, production on `tag`                     | staging should mirror the default branch with no extra step; production runs a named version, so a rollback has a target. **The list itself is asked, never guessed**                                                                              |
| `delivery.release_tool`  | `release-please`                                            | governance assumes GitHub, and it is the most widely used tool there that turns Conventional Commits into a version, a changelog and a release pull request                                                                                        |
| `delivery.release_notes` | `highlights`                                                | a generated changelog lists commits, for whoever maintains the repository; it does not tell a consumer what the release brings or what they must do. A short text that heads the release does, and only a reader of the whole release can write it |
| `delivery.registry`      | _a form, not a value_: an address such as `ghcr.io/<owner>` | needed as soon as `delivery.target` is `container`; GitHub's registry needs no other account                                                                                                                                                       |
| `deployment.manifests`   | _a form, not a value_: a relative path or a URL             | the form decides the pipeline (below), and only this repository knows where its manifests live                                                                                                                                                     |

**`delivery.target` says what leaves the repository.**

- **`container`:** an image is built and pushed to `delivery.registry`, and
  manifests describe how it runs (Kubernetes or another orchestrator).
- **`platform`:** a platform builds and runs the code itself (Vercel,
  Netlify, Fly.io, Render, Cloudflare Pages…). The agent writes the
  platform's declaration, not manifests, and there is no image job.
- **`package`:** the repository publishes a package (npm, PyPI…). Its one
  environment is the registry it publishes to, triggered on `tag`.
- **`none`:** nothing is deployed.

The trait exists because `deployment.manifests: none` alone cannot tell
"deploys without manifests" from "deploys nothing".

**The form of `deployment.manifests` decides the pipeline**
([ADR-0011](ADR-0011-forge-and-ci.md)):

- **A relative path:** the manifests are here, and the pipeline applies
  them, with one deploy job per environment.
- **A URL:** the manifests live in another repository. The pipeline
  proposes a change there and has no deploy job here; merging over there is
  the deployment (GitOps).
- **`none`:** nothing is applied.

Write URLs with their scheme (`https://`, `ssh://`, or `git@host:path`).
Without one, `forge.example.test/group/repo` is a valid relative path. If the
value is neither form, or is a relative path to a directory that does not
exist, the agent stops and asks, writing nothing. With a URL, an
environment's trigger describes what triggers the _proposal_, not the
deployment. Keeping manifest sources here and pushing rendered output
elsewhere is not covered: declare it in your own ADR.

**`manual` is not `none`.** `manual` means versions are made by hand (number,
changelog, tag). `none` means there are no versions at all. A repository
that publishes a package answers `manual`, never `none`. A tool that does
only half the job (publishes without a changelog) still counts: say
"changelog by hand" under Consequences.

**`delivery.release_notes` says what comes with a version.**

- **`changelog`:** the changelog `delivery.release_tool` generates, alone.
  Nothing is done when a release is made.
- **`highlights`:** the changelog, plus a short text for readers that heads
  the release's notes on the forge: what the release brings, what a
  consumer must do, and, in a repository that ships ADRs, every ADR it
  revises. With `release-please`, write it once the tag exists and prepend
  it to the GitHub release (`gh release edit`): release-please rewrites its
  release pull request at every merge, so text written there is lost. A
  release is not finished until its highlights are written.
- **`none`:** there are no versions. It goes with
  `delivery.release_tool: none`.

**Before 1.0.0, a breaking change gives a minor version.** With
`release-please`, a repository whose current version is below 1.0.0 sets
`"bump-minor-pre-major": true` in `release-please-config.json`. Without it,
the first breaking change in a 0.x repository releases 1.0.0, a promise of
stability nobody decided. Going to 1.0.0 stays a deliberate act
(a `Release-As: 1.0.0` footer), after which the option no longer applies. A
repository already at 1.0.0 or above does not set it.

**A change is done in its own pull request.** Its last tasks are:

1. **Once a pipeline file exists**, check that it passes on the pull
   request, even when there is no deploy job.
2. **Update the documentation the change makes false**, in the same pull
   request: a page, the README, an example. Not in a later one, and not at
   release time.

With [ADR-0016](ADR-0016-changes.md)'s `changes.framework: openspec`, the
change is also archived in that same pull request.

Whatever a check can verify belongs in a check, so the pipeline catches it
next time; review covers the rest. Nothing else waits for the release,
except the highlights when `delivery.release_notes` is `highlights`.

**Ruling: what the repository already does, departing from the
recommended environments, release tool and release notes.** Cartons
(Komodo) is the platform: it reads `infrastructure/resources.toml`, its
declaration, and runs the `stacks/*/compose.yaml` on the `cartons` server
from third-party images, so `target` is `platform`, `registry` is `none`,
and `deployment.manifests` is `none` (a relative path would make ADR-0011
require a GitHub deploy job duplicating Cartons). There is one environment,
production, synced on every push to `main`: a staging environment would
need a second server nobody has asked for. Each stack follows its upstream
image, and the repository has no version of its own to number, so
`release_tool` and `release_notes` are `none`. Terraform changes are applied
by hand through Terraform Cloud.

## Consequences

### Positive

- An agent knows what a merge puts in service (production, through
  Cartons) without asking at every change.
- No release step: a merged change is live, with nothing to tag.
- The pipeline's jobs follow from these keys (ADR-0011): no image, release
  or deploy job is invented.

### Negative

- Every merge goes straight to production, with no staging to catch a
  broken stack first.
- There is no named version to roll back to: a rollback is a revert on
  `main`.

### Neutral

- When the repository does not deploy itself (`platform` with the
  platform's own Git integration, or GitOps elsewhere), what happens after
  the merge is outside this repository and is not checked here.

## Alternatives Considered

### Deploy on tag

What runs has a name. One more step, and a rollback has a target.

### Deploy on merge

The merge is enough, and the delay is minimal. What runs becomes a SHA
nobody remembers, and a rollback has no obvious target.

### Deploy by hand

Someone decides and runs it. Honest for a repository that ships rarely; the
cost is that the act is written nowhere.

### `releaser-pleaser`

surdesrails' recommendation, because it covers GitHub and GitLab alike, and
it is proven on GitHub Actions. governance assumes GitHub only, where
`release-please` is the more widely used choice. A repository already on
`releaser-pleaser` has no reason to migrate.

## References

- Suggested skills: `deploy-checklist` from `engineering@knowledge-work-plugins`; `verification-before-completion` from `superpowers@superpowers-marketplace`, for the last tasks of a change; `deliver-release-notes` from `pm-skills@product-on-purpose`, for the highlights.
- Adapted from surdesrails [SDR-0011](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0011-delivery.md), revision 1 (its internal hosting-offer trait `hosting.offer` replaced by `delivery.target`; recommends `release-please` instead of `releaser-pleaser`).
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [release-please](https://github.com/googleapis/release-please) and [Semantic Versioning](https://semver.org/).

**The keys.**

| Key                      | What it holds                                                            | Allowed values                                                                                                        |
| ------------------------ | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| `delivery.target`        | what leaves the repository                                               | `container`, `platform`, `package`, `none`                                                                            |
| `delivery.environments`  | the environments a version goes through, in order, each with its trigger | a list of `{ name, trigger }`, `trigger` being `tag`, `merge` or `manual`; `[]` for a repository that deploys nothing |
| `delivery.release_tool`  | what makes a version and its changelog                                   | `release-please`, `releaser-pleaser`, another tool, `manual` or `none`                                                |
| `delivery.release_notes` | what comes with a version                                                | `changelog`, `highlights` or `none`                                                                                   |
| `delivery.registry`      | where images are pushed                                                  | an address, or `none`                                                                                                 |
| `deployment.manifests`   | where the deployment manifests live                                      | a relative path, a URL with a scheme, or `none`                                                                       |

**`delivery.registry` sits under `delivery`** because pushing an image builds
an artifact; it puts nothing in service. A registry is not an environment.

**What the check does not see.** It refuses an empty key and an unknown
`delivery.target`. It does not check a `trigger` value inside
`delivery.environments`, and it cannot tell a path from a URL in
`deployment.manifests`: review does.

**`rejected` means nothing leaves the repository**: no service, no package,
no image, as in a documentation, schema or configuration repository. It is
not the same as deploying by hand, which is `manual`.

**All six keys are required**: an empty key is not an answer. This file
decides when, where and what is delivered; the rules a pipeline follows are
ADR-0011's. The value is written in this file and nowhere else; whoever
needs it links here. See ADR-0001 for the check command.

**Revisions.** What changed in the question at each revision, and what
a repository that already ruled must re-answer.

- Revision 2: with `release-please` and a version below 1.0.0, `release-please-config.json` sets `"bump-minor-pre-major": true`. No key changed: if your repository is below 1.0.0, set the option.
- Revision 3: a new key, `delivery.release_notes` (`changelog`, `highlights` or `none`, recommended `highlights`), and a change's last tasks now include updating the documentation it makes false. Answer `delivery.release_notes`; nothing else to re-answer.
