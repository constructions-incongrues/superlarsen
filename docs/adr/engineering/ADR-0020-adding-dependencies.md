---
adr: ADR-0020
slug: adding-dependencies
title: Adding a dependency
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
traits:
  admission:
    approver: person
    install_scripts: ignored
---

# Adding a dependency

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

While these keys are empty, an agent that needs a library **installs the
first name that fits**. That name may come from its memory rather than
from the package's documentation. It can be a package that did not exist
until someone guessed an agent would invent it, a typosquat, or an
abandoned project.

**The install runs before anyone reads the diff, and it runs code.** npm
runs a package's lifecycle scripts. A Python installer builds a source
distribution by running its build backend. That code runs with the
session's rights, environment included: the active leak that
[ADR-0015](ADR-0015-secrets.md) says no storage prevents.

**Review comes too late for that.** A pull request shows the manifest
after the install command ran. Review can still refuse the import; it
cannot undo the install.

**Two moments, two keys.** `approver` decides who lets a name in **before
it is installed**. `install_scripts` decides **what runs** when it is,
because asking first is a habit and habits fail.

**Python has a trap npm does not.** The name a module imports is often not
the name of the distribution that provides it: `import yaml` comes from
`PyYAML`, `import sklearn` from `scikit-learn`. An agent that installs
what it imports installs whatever took that name.

**Not concerned:** moving a dependency that is already there. That is
[ADR-0018](ADR-0018-dependencies.md)'s question.

## Decision

**What governance fixes, whatever you rule:**

1. **The name comes from a source, not from memory**: the package's own
   documentation or repository, and the registry page points back to that
   repository. In Python, the name installed is the distribution name that
   documentation gives, never the import name.
2. **The version added is at least three days old**, the cooldown of
   ADR-0018 rule 2, for the same reason, and written in the configuration.
3. **Every addition is declared** in the pull request that brings it: its
   name, its version, the source of rule 1, why it is needed, and why the
   standard library or a few lines of code do not cover it. The cheapest
   dependency to admit is the one not added.
4. **Provenance is reported, not required.** The declaration says whether
   the package carries a provenance attestation. Requiring one would
   exclude most of npm and PyPI today.
5. **The lockfile is committed, and CI installs from it** without
   resolving again, so what was admitted is what runs.

How each rule is written, for the languages
[ADR-0004](ADR-0004-languages.md) recommends:

| Rule              | npm                             | pnpm                                                         | Python, uv                                                                                              | Python, pip                                                                       |
| ----------------- | ------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 2. cooldown       | `min-release-age=3` in `.npmrc` | `minimumReleaseAge: 4320` in `pnpm-workspace.yaml` (minutes) | `exclude-newer = "3 days"` under `[tool.uv]`                                                            | `--uploaded-prior-to P3D` (pip 26.1), only with an index that serves upload times |
| 4. provenance     | `npm audit signatures`          | none found                                                   | the PyPI project page; no installer verifies PEP 740 attestations, `pypi-attestations verify pypi` does | as uv                                                                             |
| 5. lockfile in CI | `package-lock.json`, `npm ci`   | `pnpm-lock.yaml`, `pnpm install --frozen-lockfile`           | `uv.lock`, `uv sync --locked`                                                                           | hashed `requirements.txt`, `pip install --require-hashes -r requirements.txt`     |

With npm, a `before` date set in the same place wins over
`min-release-age`. `pylock.toml` (PEP 751) is left out of the table: pip
marks its support experimental. Another ecosystem applies the same five
rules with its own switches.

What is yours to decide is who admits, and whether install code runs.

**What governance recommends, and why.**

| Key                         | Recommended value | Reason                                                                                                                                                                        |
| --------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `admission.approver`        | `person`          | the agent asks **before** running the install command, because installing already runs code. Asking costs one message; a wrong name can cost every secret the session reaches |
| `admission.install_scripts` | `ignored`         | no package code runs at install time. Each exception is named, and naming one is an admission like a new package                                                              |

**What `person` looks like in practice.** The agent's question is the
declaration of rule 3, written before it installs anything:

```text
Add <name>@<version>, published <date>? Source: <documentation URL>.
Why: <what it is for>. Not covered by: <standard module, or the lines it would take>.
Provenance: <attested | none>.
```

On a yes, the same text goes into the pull request.

**What `ignored` looks like in practice.**

- **npm 12** blocks dependency install scripts by default. An exception is
  an entry in the `allowScripts` field of `package.json`, written by
  `npm approve-scripts <pkg>`. `npm approve-scripts --allow-scripts-pending`
  lists what is blocked without changing anything. `strict-allow-scripts`
  turns a blocked script from a warning into an error, for CI. **Do not set
  `ignore-scripts=true`**: it overrides `allowScripts`, so the exceptions
  stop running too.
- **npm 11** knows the `allowScripts` field but runs scripts anyway: ruling
  `ignored` there means moving to npm 12.
- **pnpm** runs no build script of a package missing from `allowBuilds`, a
  map in `pnpm-workspace.yaml`. An exception is `<name>: true`.
- **uv**: `no-build = true` under `[tool.uv]` refuses every source
  distribution. The workspace's own packages and editable requirements are
  still built.
- **pip**: `--only-binary :all:` refuses every source distribution.

**`ignored` is already npm 12's default; the decision is who widens it.**
An agent that runs `npm approve-scripts --all` has ruled `allowed` without
anyone noticing. Under `ignored`, each `allowScripts` or `allowBuilds`
entry goes through `admission.approver`, like a new package.
`approve-scripts` lists a package only once it is installed, scripts
blocked, so that approval comes after the first install and before any of
its code runs.

**Python has no exception.** Neither uv nor pip documents a way to refuse
every source distribution but one. Under `ignored`, a Python package with
no wheel for your platform is not admitted: pick another package, or rule
`allowed` and name that package in your Consequences.

**Ruling: the recommendation, adopted as is.** npm 12 already blocks
install scripts, and `package.json` names its one exception in
`allowScripts`. At ruling time `package-lock.json` is not yet committed (rule 5) and no `.npmrc` sets `min-release-age=3` (rule 2): both are to be added.

## Consequences

### Positive

- An agent knows whether it may install a package now, or must ask first.
- A package installed by mistake runs nothing until something imports it.
- Every dependency in the manifest has a written reason and a source that
  review can follow.
- Additions and updates wait the same three days (ADR-0018).

### Negative

- `person` adds a round trip to every new package.
- `ignored` breaks packages that compile or download a binary at install
  time. npm and pnpm allow them by name; Python cannot, so such a package is
  not admitted.
- On npm, an install-script exception is decided only after a first
  install, with its scripts blocked.
- The name check relies on the agent reading a real source. Review checks
  it by following the source given in the declaration.
- A reported provenance is not a verified one, and in Python no installer
  verifies it.

### Neutral

- Updates to existing dependencies remain ADR-0018's question. What a
  repository publishes, and with which provenance, is not this ADR's
  question.

## Alternatives Considered

### `approver: agent`

The agent installs on its own when the fixed rules hold. A legitimate
answer with `install_scripts: ignored`, where a wrong name runs nothing
until imported. Without it, the first install of a squatted name runs that
name's code.

### `install_scripts: allowed`

Every package runs its install code: no exception to maintain, and npm's
behaviour before version 12. A wrong name, or a compromised version past
the cooldown, runs with the session's rights.

### A list of allowed or forbidden packages

governance cannot know your packages, and a denylist names only what is
already known to be bad. Both go stale; the fixed rules do not.

### Requiring provenance

Strong for what it covers, and it covers too little: most packages on npm
and PyPI carry none, so the rule would be departed from at once.

### npm only, with "the equivalent" for Python

Shorter. The equivalent is where an agent guesses, and the import-name trap
has no npm counterpart to translate from.

### Python: allowing one source distribution by name

uv's `no-build-package` is a deny list, so applying `ignored` with it leaves
every new package unblocked. Pairing `no-build = true` with
`no-binary-package` relies on an interaction uv does not document. Neither
is recommended until a tool documents the exception.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0004](ADR-0004-languages.md): why npm and Python are the ecosystems tabulated.
- [ADR-0015](ADR-0015-secrets.md): the active leak that install code exploits.
- [ADR-0018](ADR-0018-dependencies.md): updates, and the cooldown this ADR reuses.
- [ADR-0019](ADR-0019-vulnerabilities.md): scanning the dependencies once admitted.
- npm: [config](https://docs.npmjs.com/cli/v12/using-npm/config), [approve-scripts](https://docs.npmjs.com/cli/v12/commands/npm-approve-scripts), [audit signatures](https://docs.npmjs.com/cli/v11/commands/npm-audit); pnpm: [build settings](https://pnpm.io/settings/build), [dependency resolution](https://pnpm.io/settings/dependency-resolution); uv: [settings](https://docs.astral.sh/uv/reference/settings/), [resolution](https://docs.astral.sh/uv/concepts/resolution/); pip: [install](https://pip.pypa.io/en/stable/cli/pip_install/), [secure installs](https://pip.pypa.io/en/stable/topics/secure-installs/); [pypi-attestations](https://github.com/pypi/pypi-attestations). Read on 2026-11-14.

**The keys.**

| Key                         | What it holds                                                       | Allowed values       |
| --------------------------- | ------------------------------------------------------------------- | -------------------- |
| `admission.approver`        | who lets a new dependency in, **before it is installed**            | `person`, `agent`    |
| `admission.install_scripts` | whether package code runs at install time, outside named exceptions | `ignored`, `allowed` |

**What the check does not see.** It refuses an empty or unknown value. It
reads neither the manifest nor `.npmrc`, `pnpm-workspace.yaml` or
`pyproject.toml`: `install_scripts: ignored` with `ignore-scripts=true`
passes it, and review catches it.

**An empty key is not an answer**: both are required. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.
