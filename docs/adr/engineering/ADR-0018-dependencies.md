---
adr: ADR-0018
slug: dependencies
title: Dependencies
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0018
traits:
  dependencies:
    updater: dependabot
    automerge: patch
---

# Dependencies

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

[ADR-0011](ADR-0011-forge-and-ci.md) rule 3 pins every action by commit
SHA. A pin does not move, so it does not update either: without a tool that
proposes the new SHA, it stays where it was written, security fixes
included. The same holds for every dependency a lockfile freezes.

While these keys are empty, an agent that meets a bot's pull request does
not know **whether it may merge it**. It either leaves it open, and the
pull requests pile up until someone closes them all unread, or it merges
what nobody checked.

**Two moments, two keys.** `updater` decides what **proposes** an update.
`automerge` decides which of those proposals **merge without a person**.
The second matters more to an agent than the first.

**A green check is not a review.** Automerge trusts the required checks of
ADR-0011 and nothing else. A patch release can be broken in a way no test
covers, or published by someone who took over the package. Waiting a few
days before proposing it lets others find out first; it proves nothing
about the code.

**Automerge is the exception
[ADR-0022](ADR-0022-review-and-merge.md) allows** to its rule that a
person reviews: a workflow the repository ruled merges the update, not an
agent. With ADR-0022's `review.by: peer`, the ruleset requires an
approval, so Dependabot is the one actor in its bypass list, and its
automerge passes the approval rule; no other actor goes there, except the
repository admin role under
[ADR-0026](ADR-0026-agent-identity.md)'s `agent.identity: own`.

**Not concerned:** security alerts that report a vulnerable dependency
without proposing an update. They inform, under
[ADR-0019](ADR-0019-vulnerabilities.md); this ADR is about what keeps the
repository current. Nor is adding a new dependency: that is
[ADR-0020](ADR-0020-adding-dependencies.md)'s question.

## Decision

**What governance fixes, whatever you rule:**

1. **No automerge without `forge.gate: blocking`** (ADR-0011). With
   `informative` or `none`, a required check does not exist, and automerge
   merges code no test stood in front of. That combination is forbidden.
2. **A cooldown before any update is proposed**: at least three days after
   its release, written explicitly in the configuration (`cooldown` for
   Dependabot, `minimumReleaseAge` for Renovate). It is the only defence an
   automerged update has against a compromised release.
3. **Updates to GitHub Actions are never merged automatically**, whatever
   the level. A new SHA runs with the pipeline's rights, and its version
   number says nothing about what changed. A person merges them.
4. **Major updates are always reviewed by a person.**
5. **The ecosystems watched follow from tracked files**, not from the
   agent's judgement: a `package.json` adds `npm`, a `.github/workflows/`
   directory adds `github-actions`, a `pyproject.toml` adds `pip`. An
   ecosystem no file justifies is not configured.

What is yours to decide is the tool, and how far automerge goes.

**What governance recommends, and why.**

| Key                      | Recommended value | Reason                                                                                                     |
| ------------------------ | ----------------- | ---------------------------------------------------------------------------------------------------------- |
| `dependencies.updater`   | `dependabot`      | GitHub is the forge (ADR-0011), so it is built in: no third-party app holds write access to the repository |
| `dependencies.automerge` | `patch`           | a patch that passes the required checks does not deserve a reader; a minor sometimes does, a major always  |

**Dependabot does not merge by itself.** Automerge is a workflow you write,
and that workflow obeys ADR-0011 like any other:

- it runs on `pull_request`, never `pull_request_target` (rule 5), and only
  when the pull request's author is `dependabot[bot]`;
- it reads the update type with `dependabot/fetch-metadata`, pinned by SHA
  (rule 3), and acts only on `version-update:semver-patch` (or `-minor`
  if you ruled `minor`) and never on the `github-actions` ecosystem;
- it declares its `permissions:` (`contents: write`,
  `pull-requests: write`) instead of relying on defaults;
- it runs `gh pr merge --auto` with the merge method ruled in
  [ADR-0009](ADR-0009-branching.md). `--auto` merges only once the
  required checks pass, and needs "Allow auto-merge" turned on in the
  repository settings.

Workflows triggered by Dependabot see Dependabot secrets, not Actions
secrets. This one needs none.

**What `dependabot` looks like in practice**, for a repository with a
`package.json` and workflows:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
    cooldown:
      default-days: 3
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    cooldown:
      default-days: 3
```

**Dependabot updates a SHA pin, it does not create one.** An action
written `@v4` stays a tag; rule 3 of ADR-0011 is still enforced by review.

**Ruling: the recommendation, adopted as is.** At ruling time only
Dependabot security updates are turned on, at the forge; version updates
are made by hand. A `.github/dependabot.yml` is to be written for the
ecosystems the tracked files justify: `docker-compose` (`stacks/*/compose.yaml`),
`terraform` (`infrastructure/terraform/.terraform.lock.hcl`), `npm`
(`package.json`) and, once ADR-0011's workflows exist, `github-actions`.
Patch automerge waits for ADR-0011's blocking gate. Note that every merge
reaches production directly (ADR-0012), so an automerged patch is live as
soon as its required checks pass.

## Consequences

### Positive

- An agent knows which bot pull requests it may leave to merge on their
  own, and which wait for a person.
- SHA pins and lockfiles move forward without anyone remembering to do it.
- Automerge cannot outrun the pipeline: it exists only where a red check
  blocks the merge.

### Negative

- The automerge workflow is code with write permissions, to keep under
  ADR-0011's rules like any other.
- Action updates and majors remain manual merges, and they pile up if
  nobody reads them.
- A patch that passes the checks can still be wrong; the cooldown narrows
  the window, it does not close it.
- Dependabot does not pin a tag to a SHA: rule 3 of ADR-0011 stays a review
  check.

### Neutral

- Security alerts and the repository's Dependabot settings live on
  GitHub, outside the repository and outside this ADR.

## Alternatives Considered

### `dependabot`

Recommended. Built in, no app to trust, configured in one file. It merges
nothing by itself, which costs a workflow.

### `renovate`

Native automerge per rule (`packageRules` with `matchUpdateTypes`),
`minimumReleaseAge`, a preset that pins actions to SHAs
(`helpers:pinGitHubActionDigests`), regex managers for versions in a
Dockerfile or a Makefile, and a dashboard issue listing every pending
update. The cost: a third-party GitHub App with write access, or a
self-hosted runner to maintain. Its multi-forge reach buys nothing here,
since ADR-0011 fixes GitHub. A legitimate answer when pinning or custom
managers matter more than the app.

### `updater: none`

Updates by hand, when someone thinks of it. Tenable for a repository with
no dependency and no workflow; elsewhere, pins go stale silently.

### `automerge: minor`

Fewer pull requests to read. A minor can change behaviour within semver's
promise, and a test suite seldom covers all of it.

### `automerge: none`

Every update read by a person. The safest, and the one whose pull requests
pile up first.

## References

- Suggested skills: `github-project` from `github-project@netresearch-claude-code-marketplace`, for auto-merge of Dependabot pull requests and the repository settings it needs.
- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0011](ADR-0011-forge-and-ci.md): `forge.gate`, and the rules every workflow obeys, the automerge one included.
- [ADR-0009](ADR-0009-branching.md): the merge method `gh pr merge` uses.
- GitHub documentation: [Dependabot options reference](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference) and [automating Dependabot with GitHub Actions](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/automating-dependabot-with-github-actions); Renovate [configuration options](https://docs.renovatebot.com/configuration-options/) and [helper presets](https://docs.renovatebot.com/presets-helpers/), read on 2026-11-14.

**The keys.**

| Key                      | What it holds                                                                | Allowed values                   |
| ------------------------ | ---------------------------------------------------------------------------- | -------------------------------- |
| `dependencies.updater`   | what proposes dependency updates                                             | `dependabot`, `renovate`, `none` |
| `dependencies.automerge` | the largest update that merges without a person, actions and majors excepted | `none`, `patch`, `minor`         |

**What the check does not see.** It refuses an empty or unknown value. It
reads neither `.github/dependabot.yml` nor `renovate.json`, nor ADR-0011:
`automerge: patch` with `forge.gate: informative` passes it, and review
catches it.

**An empty key is not an answer**: both are required. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.
