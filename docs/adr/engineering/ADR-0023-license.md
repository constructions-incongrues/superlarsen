---
adr: ADR-0023
slug: license
title: License
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0023
traits:
  license:
    spdx: MIT
---

# License

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

**A repository with no licence may not be reused.** Without one, copyright
law applies by default: whoever reads the code on GitHub may view and fork
it there, but has no right to copy, change or distribute it. This holds
whether or not the repository publishes a package, so the question does not
wait for [ADR-0012](ADR-0012-delivery.md)'s `delivery.target`.

While this key is empty, an agent creating `package.json` or
`pyproject.toml` does not know **which licence to declare**. The tools do
not decide for it: measured on 2026-11-15, `npm init -y` (npm 12.2.2) and
`uv init` write no licence field at all. The agent writes MIT out of habit,
or nothing. On a published package, either one is a decision nobody made.

**The licence is an SPDX expression.** SPDX gives each licence a short
identifier (`MIT`, `Apache-2.0`), and expressions combine them
(`MIT OR Apache-2.0`). npm's `license` field takes one. So does
`[project] license` in `pyproject.toml` since PEP 639. npm also reserves
`UNLICENSED` for a package nobody may reuse.

**Not concerned:** the licences of the dependencies and whether they are
compatible with yours. That is licence compliance, which
[ADR-0019](ADR-0019-vulnerabilities.md) leaves out. Nor are SPDX headers
in source files.

## Decision

**What governance recommends, and why.**

| Key            | Recommended value | Reason                                                                                                                                                                                                   |
| -------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `license.spdx` | `MIT`             | short, read the same way everywhere, and the most common licence on npm: whoever installs the package knows what it allows. `Apache-2.0` when an explicit patent grant matters to those who use the code |

Any SPDX expression is an answer. Use `UNLICENSED` for a private
repository that nobody outside may reuse.

**Why governance itself is under MIT-0, not MIT.** governance's ADRs are
copied into other repositories and rewritten there. MIT requires keeping its
copyright notice in every copy, which would mean a notice in each imported
ADR. MIT-0 drops that condition. A package someone installs has no such
problem: the notice stays in its `LICENSE`, and MIT costs nothing.

**What governance fixes, whatever you rule:**

1. **The root manifest declares the value**: `"license"` in
   `package.json`, `license` under `[project]` in `pyproject.toml`, as the
   same SPDX expression.
2. **A licence file is committed at the root**, named `LICENSE`,
   `LICENSE.md`, `LICENSE.txt` or `COPYING`, with the licence's full text.
   `UNLICENSED` needs none.
3. **The copyright holder is the organisation that owns the repository**,
   or else the people named in this ADR's `authors:`. The agent writes it in
   the licence file's copyright line and nowhere else. It is not a key: it
   is needed once, to write the file, and read from it afterwards.

**Ruling: the recommendation, adopted as is.** At ruling time the
repository is public with no licence file and no `license` field in
`package.json`, which reserves every right. MIT lets others reuse this
configuration; the `LICENSE` file, held by constructions-incongrues, and the
manifest field are to be added.

## Consequences

### Positive

- Whoever finds the repository knows what they may do with it.
- An agent creating a manifest writes the licence that was ruled, not the
  one it is used to.
- The manifest and the licence file cannot drift apart unnoticed.

### Negative

- MIT lets anyone use the code in closed software, without giving anything
  back.
- The check does not see a licence file whose text contradicts the
  manifest.

### Neutral

- Changing the licence later binds only new versions. Copies already taken
  keep the licence they came with.

## Alternatives Considered

### `Apache-2.0`

As permissive as MIT, with an explicit patent grant and a clause that ends
it for whoever sues over a patent. It is longer to read, and it asks for a
`NOTICE` file to be kept when there is one. It is worth it when the code
touches an area where patents are filed.

### `MIT-0`

MIT without the obligation to keep the notice. It suits text meant to be
copied and rewritten, as governance's ADRs are. For a package, the
notice costs nothing, and MIT is the identifier people already know.

### A copyleft licence (`GPL-3.0-or-later`)

Whoever distributes a modified version must publish its source under the
same licence. It protects the code from closed reuse. Many companies refuse
it in their dependencies, so it costs a package most of its potential
users.

### `UNLICENSED`

Nobody may reuse the code. It is the right answer for a private repository,
and the wrong one for a public repository that expects contributions or
reuse.

### A key in ADR-0012

A licence accompanies a package, but it also applies to a public repository
that publishes nothing. Putting it in ADR-0012 would tie it to
`delivery.target`, and would make every repository that ruled ADR-0012
re-answer it for a question that is not ADR-0012's.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0012](ADR-0012-delivery.md): what accompanies a version.
- [ADR-0019](ADR-0019-vulnerabilities.md): leaves dependency licence compliance out.
- GitHub: [licensing a repository](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository). [choosealicense.com: no license](https://choosealicense.com/no-permission/). npm: [`license` in package.json](https://docs.npmjs.com/cli/v11/configuring-npm/package-json#license). Python: [PEP 639](https://peps.python.org/pep-0639/), [writing `pyproject.toml`: license](https://packaging.python.org/en/latest/guides/writing-pyproject-toml/#license). [SPDX license list](https://spdx.org/licenses/). Read on 2026-11-15.

**The key.**

| Key            | What it holds                                   | Allowed values                              |
| -------------- | ----------------------------------------------- | ------------------------------------------- |
| `license.spdx` | the licence others may use the repository under | an SPDX license expression, or `UNLICENSED` |

**An empty key is not an answer.** The value is written in this file and
nowhere else; whoever needs it links here. See ADR-0001 for the check
command.
