---
adr: ADR-0011
slug: forge-and-ci
title: Forge and continuous integration
status: accepted
revision: 4
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0011
traits:
  forge:
    gate: blocking
    audit: zizmor
---

# Forge and continuous integration

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

governance assumes **GitHub** as the forge: pull requests, GitHub Actions
workflows in `.github/workflows/`, secrets in repository or environment
settings, and branch protection in rulesets. A repository on another forge
rules this ADR `rejected` and names its forge in the reason.

While the key is empty, an agent opening a pull request does not know
whether a red pipeline **blocks the merge** or only **reports**. It either
spends time fixing a red that had no consequence, or merges a red that did.

**A red pipeline blocks nothing on its own.** It blocks a merge only once a
ruleset on the repository (or the organisation) names the check as
required. That setting lives on GitHub, not in a file of the repository, so
the value written here is a statement of intent that the ruleset makes
real.

**The workflows are code an agent writes, and nothing reads them.** The
rules below are written for whoever writes a workflow. Measured on
governance's own workflows with zizmor 1.32.0, five findings slipped past
them, among them a template injection and write permissions granted to the
whole workflow, while every action was correctly pinned. While
`forge.audit` is empty, an agent does not know whether a tool will read
what it wrote.

What a pipeline runs on which branch follows from other ADRs: the branching
model ([ADR-0009](ADR-0009-branching.md)), the delivery
([ADR-0012](ADR-0012-delivery.md)), the languages and tests
([ADR-0004](ADR-0004-languages.md), [ADR-0007](ADR-0007-tests.md)).

## Decision

**What governance recommends, and why.**

| Key           | Recommended value | Reason                                                                                                                                                                                                                                     |
| ------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `forge.gate`  | `blocking`        | a check that prevents nothing is not a check, it is a report. Make it real with a ruleset that requires the pipeline's checks on the default branch                                                                                        |
| `forge.audit` | `zizmor`          | it reads workflows for what this ADR's rules forbid: a movable action reference, `pull_request_target`, a template expanded into `run:`, permissions wider than a job needs. actionlint checks that a workflow parses, not that it is safe |

`none` is how a repository says it has no pipeline at all: keep `traits:`
and write `none`. `rejected` has one use only, a forge other than GitHub.

Who reviews a change to this repository, and who merges it, is
[ADR-0022](ADR-0022-review-and-merge.md)'s question: `review.by`.

**What governance fixes, whatever you rule.** Five rules apply to every
workflow job, not only to deployment:

1. **Deploy only from the default branch.** A pushed feature branch deploys
   nothing. Bind each deploy job to the default branch in its workflow
   `on:` and its job `if:`, and protect the environment it uses.
2. **Deploy secrets are protected.** They live in repository secrets, or in
   environment secrets when rule 1 needs them, never in a file.
3. **Pin actions and images immutably.** An action tag such as
   `actions/checkout@v4` can be moved, so the only immutable form is the
   commit SHA, with the tag in a comment. An image is pinned by digest or by
   a tag nobody moves, never `latest`.
4. **No job writes a secret's value to a log.** The rule targets the fact,
   not a list of commands. Printing what the pipeline publishes anyway (a
   staging URL, a commit) is fine.
5. **An untrusted contribution receives no secrets**, and a job running with
   the repository's rights does not execute proposed code: that is
   `pull_request_target` checking out the fork's head. Secret-free CI still
   runs on pull requests from forks: what stops is the secret, not the test.

**What governance fixes when you rule `forge.audit: zizmor`:**

1. **A job runs zizmor on every pull request**, through
   `zizmorcore/zizmor-action` pinned by SHA (rule 3). In CI it also runs
   the online audits, with the job's `GITHUB_TOKEN`.
2. **A finding is silenced only inline**, on its line, with its reason:
   `# zizmor: ignore[template-injection] the title is only echoed`. The
   agent proposes it and a person approves or merges it, as
   [ADR-0022](ADR-0022-review-and-merge.md)'s `review.by` says and as
   [ADR-0019](ADR-0019-vulnerabilities.md) rule 4 has for an ignore rule. A
   `zizmor.yml` that loosens or disables an audit is not a way to silence:
   the check does not read it.
3. **Every action is pinned by hash**, GitHub's own (`actions/*`)
   included. zizmor's default policy already requires it.

**Secrets are named, never given.** An agent produces the list of secret
_names_ a workflow needs; a person sets the values on GitHub. A token, a
password or a kubeconfig never goes into a change, a commit or a reply to
the agent.

**Departing from a rule** is declared in your own ADR, with its reason. A
silent bypass is not a departure.

**Which jobs exist follows from other ADRs, not from the agent's judgement.**

| Stage             | Exists when                                                                                                                  | Its form comes from                                                                      |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `lint`            | a tracked file (a `package.json` script, a Makefile target, a `pyproject.toml` section) carries a lint command               | that command; the workflow cites the file                                                |
| `test`            | the same, for a test command                                                                                                 | that command; the failing threshold is `tests.coverage_target` (ADR-0007)                |
| `scan`            | `vulnerabilities.scanner` is not `none` (ADR-0019), on pull requests and on a schedule                                       | that scanner; the failing threshold is `vulnerabilities.fail_on` (ADR-0019)              |
| `audit`           | `forge.audit` is not `none`                                                                                                  | that tool, on the files under `.github/workflows/`                                       |
| `build`           | always                                                                                                                       | `languages.main.name` (ADR-0004), plus the frontend (ADR-0013) if ruled                  |
| `image`           | `delivery.target: container` (ADR-0012)                                                                                      | the registry in `delivery.registry`                                                      |
| `release`         | `delivery.release_tool` is neither `manual` nor `none`                                                                       | that tool (ADR-0012), plus the SBOM when `vulnerabilities.sbom` is not `none` (ADR-0019) |
| `deploy`          | `deployment.manifests` is a relative path; one job per entry of `delivery.environments`, in order, each with its own trigger | the manifests in that path                                                               |
| propose elsewhere | `deployment.manifests` is a URL; this replaces `deploy`                                                                      | that address                                                                             |

An absent stage is a full answer: an agent that adds a job in these cases
has invented one. A command named only in an agent instructions file does
not create a stage. If `deployment.manifests` is neither a relative path to
an existing directory nor a URL with a scheme, the agent asks and writes
nothing. The table never writes a job's content.

**Ask before writing, once.** None of the following follows from a trait:
the names of the registry and cluster credentials, the namespace or the
platform's service declaration, the apply tool (governance prescribes
none), who reviews a change proposed elsewhere, and the service URL. The
order is: rule ADR-0012, collect these, then write.

**What a deploy job prints.** The staging URL, the deployed commit, and a
dated line naming that commit. On failure, the stage that failed and a link
to the job log, with three known causes: a policy refused the manifest (fix
the manifest, not the policy), a secret is missing (set it, named as
listed), an image is not found (check it was pushed and matches the pin).

**Ruling: the recommendation, adopted as is.** At ruling time the
repository has no `.github/` directory: `trunk check` runs only through a
local pre-push hook, which a pull request made in GitHub's interface skips,
and the default branch requires no status check. A `lint` workflow running
`trunk check` (the command `.trunk/trunk.yaml` carries), required by the
default branch's protection, and a zizmor job are to be added. Deployment
stays with Cartons and Terraform Cloud, outside GitHub Actions.

## Consequences

### Positive

- A red pipeline means the same thing to every agent and reviewer: with a
  required check, nothing merges on red.
- The five rules close the common leaks: moved action tags, secrets in logs,
  deploys from feature branches, secrets handed to forks.
- Which jobs exist is derived from the other ADRs, so two agents write the
  same workflow.

### Negative

- A flaky pipeline blocks everyone, and the pressure to bypass the check
  grows with it.
- Pinning actions by SHA makes updates a deliberate chore, unless a tool
  proposes them: [ADR-0018](ADR-0018-dependencies.md) decides which.
- zizmor enforces rule 3 for actions and part of rule 5. Rules 1, 2 and 4,
  and image pins, stay with review, which reads every `uses:`, `image:` and
  `run:`.
- A new zizmor release can add an audit that fails a workflow that passed
  the day before.

### Neutral

- The ruleset that makes `blocking` real is a GitHub setting, outside the
  repository, and is not checked by anything here.

## Alternatives Considered

### `blocking`

Nothing merges on red. Recommended. The cost is real: an unstable pipeline
blocks people who did nothing wrong.

### `informative`

The pipeline reports, review decides. Less friction, and no guarantee: a red
that is reported gets ignored.

### `none`

No pipeline; review is the only control. Tenable for a repository with no
executable code.

### `forge.audit: none`

Nothing reads the workflows but review. Tenable when no workflow exists,
or when a person writes and reads every one of them.

### actionlint only

It catches a workflow that does not parse or a wrong expression type. It
does not flag a movable tag, `pull_request_target` or a secret in a log
(measured below): it is a linter, not an audit. It is still worth running
before pushing.

### CodeQL's `actions` language

GitHub's code scanning analyses workflows too. Measured on governance's
workflows on 2026-11-15, its 17 queries reported nothing where zizmor found
five issues.

### Honouring the repository's `zizmor.yml`

The usual way to configure zizmor. It lets a file turn an audit off while
the check still passes, which is the silent bypass the rules above forbid.

### A forge other than GitHub

Rule `rejected` and name the forge. The five rules then no longer apply
from here; copy those you keep into your own ADR.

## References

- Suggested skills: `setup` from `actionlint@melodic-software`, to install and wire actionlint.
- Adapted from surdesrails [SDR-0010](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0010-forge-and-ci.md), revision 2 (GitHub only: `forge.vendor` and the sections for the other forge dropped; the `image` stage follows `delivery.target` instead of `hosting.offer`).
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [actionlint](https://github.com/rhysd/actionlint) and [act](https://github.com/nektos/act).
- zizmor: [audits](https://docs.zizmor.sh/audits/), [usage and ignores](https://docs.zizmor.sh/usage/), [configuration](https://docs.zizmor.sh/configuration/), [zizmorcore/zizmor-action](https://github.com/zizmorcore/zizmor-action). Measured with zizmor 1.32.0 on 2026-11-15.

**The key.**

| Key           | What it holds                                      | Allowed values                                                                                       |
| ------------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `forge.gate`  | what a red pipeline prevents                       | `blocking` (nothing merges on red), `informative` (it reports, review decides), `none` (no pipeline) |
| `forge.audit` | what reads the workflows for what the rules forbid | `zizmor`, another named tool, or `none`                                                              |

**Testing a workflow before pushing**, in three steps, cheapest first. Install
`actionlint` and `act` as standalone binaries from their GitHub releases,
checked against the checksum file each project publishes, in
`$HOME/.local/bin`, without `sudo`.

| Step                            | Command                                                                                                                 | Expect                                                                |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| 1. the configuration parses     | `actionlint` (it finds `.github/workflows` itself)                                                                      | no error                                                              |
| 2. the predicted jobs are there | `act -l` (needs no Docker daemon)                                                                                       | at least the jobs the stage table predicts, and none it excludes      |
| 3. they run                     | `act -P ubuntu-latest=catthehacker/ubuntu:act-latest --env-file /dev/null --secret-file /dev/null --var-file /dev/null` | lint, test and build green; deploy red, since it runs against nothing |

Notes on `act`, measured in surdesrails on 2026-09-20:

- **Always pass `-P`.** Otherwise `act` asks which image to use, and a
  non-interactive run fails with a bare `level=fatal msg=EOF`.
- **Always pass the three empty files.** `act` loads `.env` (printed in
  clear), `.secrets` and `.vars` from the repository root by default.
- **Never pass `-s GITHUB_TOKEN="$(gh auth token)"`.** `act` replaces
  `actions/checkout` with a local copy that needs no token, and the jobs that
  really need the GitHub API cannot be tested locally anyway.
- **`act -l` does not evaluate `if:`.** It lists the static graph, so
  distrust a job it shows.
- On Apple Silicon, add `--container-architecture linux/amd64`. `act -j
<job>` runs a single job.
- Do not lift these flags to get green.
- **Three greens do not make a working deploy.** Registry access, the apply
  tool, the namespace and admission policies are untouched.

**What the tools do not catch**, measured with actionlint v1.7.12:

- **Not flagged:** a movable action tag (`@v5`), `echo ${{ secrets.X }}`, a
  bare `env`, `curl -u user:pass`, and `pull_request_target`.
- **Flagged:** direct interpolation of `github.event.pull_request.title` in
  `run:`.
- **Flagging is not enforcing:** you run it by hand, and it refuses no merge.

Measured with zizmor 1.32.0, offline, without configuration:

- **Flagged:** a movable action tag, GitHub's own included (`unpinned-uses`),
  `pull_request_target` (`dangerous-triggers`), the pull request title in
  `run:` (`template-injection`), a checkout that keeps its credentials
  (`artipacked`), and `contents: write` at workflow level when the workflow
  has several jobs (`excessive-permissions`).
- **Not flagged:** `echo ${{ secrets.X }}`, a bare `env`, `curl -u
user:pass`, and workflow-level `contents: write` in a single-job
  workflow. Rule 4 stays with review, as does rule 1.

**Checking rule 1 by hand.** Run
`grep -rn --include='*.yml' --include='*.yaml' 'environment:' .github/workflows/`,
then check that each hit is bound to the default branch through `on:` and
`if:`. This is a floor, not a guarantee:

- It misses a deploy with no `environment:`, a branch condition set
  elsewhere, environment protections and rulesets.
- A job that publishes Pages, for example, is a false positive.

**An empty key is not an answer**: both are required. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.

**Revisions.** What changed in the question at each revision, and what
a repository that already ruled must re-answer.

- Revision 2: a new key, `forge.audit` (`zizmor`, another tool or `none`, recommended `zizmor`), three rules for `zizmor`, and an `audit` stage. Answer `forge.audit`; nothing else to re-answer.
- Revision 3: a new key, `forge.review` (`peer`, `author` or `agent`, recommended `peer`), which says who can accept a change, and what `author` leaves beside each value of `forge.gate`. Answer `forge.review`; nothing else to re-answer.
- Revision 4: `forge.review` moves to [ADR-0022](ADR-0022-review-and-merge.md) as `review.by`, with what it leaves beside each value of `forge.gate`. Answer `review.by` there, then delete `forge.review` from this file: the check fails while it remains.
