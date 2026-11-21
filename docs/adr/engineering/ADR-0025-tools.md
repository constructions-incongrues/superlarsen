---
adr: ADR-0025
slug: tools
title: Tools outside the package manager
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0025
traits:
  tools:
    manager: mise
---

# Tools outside the package manager

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

Several ADRs name a tool that is neither a dependency in the manifest nor a
GitHub Action: the guard of [ADR-0015](ADR-0015-secrets.md), the scanner of
[ADR-0019](ADR-0019-vulnerabilities.md) when it runs locally, a workflow
linter. No lockfile records such a binary.

While this key is empty, an agent that needs one **installs it the way the
place it runs in suggests**. In the repository that raised the question,
one binary was handled three ways:

- on the runner, a script pinned it by version and checksum;
- on a workstation, a hook message asked for `brew install`, with no
  version;
- in a remote agent session, it was missing, and a commit went through
  without the hook.

**The workstation and the runner can then differ without anyone
noticing**, and the guard an ADR rules does not run everywhere the ADR
applies.

**A tool manager is itself such a tool.** It is a binary fetched from the
network, and it fetches others.

**Not concerned:** dependencies in the manifest
([ADR-0020](ADR-0020-adding-dependencies.md)), actions and images
([ADR-0011](ADR-0011-forge-and-ci.md) rule 3), the language runtime
([ADR-0004](ADR-0004-languages.md)).

## Decision

**What governance recommends, and why.**

| Key             | Recommended value                                     | Reason                                                                                                                                                                                                                                                                     |
| --------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tools.manager` | `script` with one tool; `mise` or `aqua` with several | one pinned script is a few lines anyone can read, and a manager is one more binary to pin for a single tool. With several, a manager keeps every version and checksum in one committed file, where a script grows a download and a checksum line per tool and per platform |

`none` is an answer only when no accepted ADR names such a tool.

**What governance fixes, whatever you rule:**

1. **One place holds each tool's version and checksum.** Every tool an
   accepted ADR names is listed in one committed place: the script, or the
   manager's files (`mise.toml` and `mise.lock`; `aqua.yaml` and
   `aqua-checksums.json`). A version without a checksum is not a pin.
2. **The same place serves the workstation, the runner and an agent
   session.** A hook, a workflow and a session setup all call it. None
   carries a version of its own, and none falls back to `brew install` or
   to whatever is on the `PATH`.
3. **The manager is installed pinned.** It is a dependency under ADR-0020:
   its version is written down, and what installs it is pinned by hash
   where it is an action (ADR-0011 rule 3).
4. **What keeps the pins current is written in this file.** Dependabot,
   which [ADR-0018](ADR-0018-dependencies.md) recommends, lists none of
   mise, aqua or asdf among its ecosystems. When you rule, say who or what
   moves each pin, and that the checksum moves in the same pull request.

**What each value looks like in practice:**

| Value    | Where the pins live                                                                                 | Refusing an unpinned tool                                                                              | The manager itself                                                      | What can move the pins                                                                                                        |
| -------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `script` | one script in the repository, holding the version, the checksum per platform and the `sha256sum -c` | the script exits on a mismatch                                                                         | none                                                                    | a person; Renovate's regex manager can propose the version, and is not documented to update a checksum beside it              |
| `mise`   | `mise.toml`, and `mise.lock` with `lockfile = true`                                                 | `mise install --locked` fails on a tool with no lockfile entry; a checksum mismatch fails the download | `MISE_VERSION` for the install script, `version:` for `jdx/mise-action` | Renovate's `mise` manager, which also updates `mise.lock`                                                                     |
| `aqua`   | `aqua.yaml`, and `aqua-checksums.json` with `checksum.enabled: true` (off by default)               | `AQUA_ENFORCE_CHECKSUM` and `AQUA_ENFORCE_REQUIRE_CHECKSUM`                                            | `aqua_version:` for `aquaproj/aqua-installer`                           | Renovate with the `aqua-renovate-config` preset for versions; its documentation does not say it updates `aqua-checksums.json` |

Two limits to know before choosing:

- `mise.lock` holds a checksum only where the backend provides one. A tool
  installed through mise's asdf backend is recorded by version alone, which
  rule 1 refuses.
- With aqua, a checksum missing from `aqua-checksums.json` is added on
  first download. Review the file's diff as you would a lockfile's.

**Ruling: the recommendation, `mise`, for several tools.** At ruling time
no manager exists: Trunk pins its own CLI and linters in `.trunk/trunk.yaml`,
its launcher is installed outside the repository, and Terraform comes from a
floating devcontainer feature. `mise.toml` and `mise.lock` (`lockfile =
true`) are to pin `trunk`, `terraform`, `grype` and `zizmor`, for the
workstation, the runner and agent sessions alike; Trunk keeps pinning its
linters. Who moves the pins: a person, by hand, in a pull request that
updates `mise.lock` with the version, since Dependabot (ADR-0018) does not
watch mise.

## Consequences

### Positive

- An agent that needs a tool an ADR names knows where its version is and
  how to install it, in a session as on a runner.
- The workstation, the runner and the session run the same binary.
- A tool's version moves in a pull request, with its checksum.

### Negative

- One more file to keep current, by a means Dependabot does not offer.
- With a manager, one more binary to pin and to trust.
- A new platform (a contributor on another architecture) needs its own
  checksum before the tool installs there.

### Neutral

- `ontrack-engineering-check ADR-0025` verifies, with `mise`, that the tools
  `secrets.guard` and `forge.audit` name are pinned. Review still covers a
  tool another trait or a local ADR names, a tool whose binary has another
  name than the value, the pins under `script` and `aqua`, and rule 4.
- governance installs no tool by ruling this; each repository writes its
  script or its manager's files.

## Alternatives Considered

### `script`, whatever the number of tools

No manager to install, pin or learn, and the whole mechanism is readable
in the repository. Each tool adds a download URL and one checksum per
platform, written by hand, and nothing documented moves the checksum with
the version. It is the recommendation for one tool, and it wears out past
a few.

### `mise`

One lockfile with versions and checksums, an install that can refuse what
the lockfile does not hold, and Renovate updates both files. It costs a
manager to pin, a lockfile that only holds a checksum where the backend
gives one, and Renovate instead of ADR-0018's recommended updater. On a
self-hosted Renovate, updating `mise.lock` must also be allowed as an
unsafe execution.

### `aqua`

Tools come from a registry of declarative YAML definitions, with no shell
script to write, and checksums are committed in `aqua-checksums.json`.
Verification is off until `checksum.enabled: true`, a missing checksum is
trusted on first download, and the documented Renovate preset covers
versions, so the checksum file needs its own step.

### asdf

The widest plugin catalogue. A plugin is a Git repository of scripts that
download and install the tool, and asdf's documentation asks no checksum
of them. mise's own documentation describes them as shell scripts that run
with your permissions. That is the install-time code ADR-0020 refuses with
`install_scripts: ignored`, and nothing in it is pinned as ADR-0011 rule 3
asks. Rejected.

### `none` while a tool is named

Nothing to maintain. Each place installs the tool its own way, which is
the situation this ADR was written to end. `none` stays an answer for a
repository where no accepted ADR names such a tool.

### A revision of ADR-0011 or ADR-0015

ADR-0011 is about the runner and ADR-0015 about one tool. The question
covers the workstation and the agent session too, and every tool. A
revision would also have asked every repository to rule again on a
question it had already answered.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0011](ADR-0011-forge-and-ci.md): the pinning rule for actions and images.
- [ADR-0015](ADR-0015-secrets.md) and [ADR-0019](ADR-0019-vulnerabilities.md): the tools they name.
- [ADR-0018](ADR-0018-dependencies.md): updates.
- [ADR-0020](ADR-0020-adding-dependencies.md): how a dependency comes in, and install-time code.
- mise: [`mise.lock`](https://mise.jdx.dev/dev-tools/mise-lock.html), [installing mise](https://mise.jdx.dev/installing-mise.html), [`jdx/mise-action`](https://github.com/jdx/mise-action), [asdf backend](https://mise.jdx.dev/dev-tools/backends/asdf.html).
- aqua: [checksum verification](https://aquaproj.github.io/docs/reference/security/checksum/), [aqua-installer](https://aquaproj.github.io/docs/products/aqua-installer/), [aqua-renovate-config](https://aquaproj.github.io/docs/products/aqua-renovate-config).
- asdf: [creating a plugin](https://asdf-vm.com/plugins/create.html).
- Dependabot: [supported ecosystems](https://docs.github.com/en/code-security/dependabot/ecosystems-supported-by-dependabot/supported-ecosystems-and-repositories).
- Renovate: [`mise` manager](https://docs.renovatebot.com/modules/manager/mise/), [regex manager](https://docs.renovatebot.com/modules/manager/regex/).
- Read on 2026-11-15.

**The key.**

| Key             | What it holds                                                  | Allowed values                   |
| --------------- | -------------------------------------------------------------- | -------------------------------- |
| `tools.manager` | how tools outside the package manager are installed and pinned | `mise`, `aqua`, `script`, `none` |

**An empty key is not an answer.** The value is written in this file and
nowhere else; whoever needs it links here. See ADR-0001 for the check
command.
