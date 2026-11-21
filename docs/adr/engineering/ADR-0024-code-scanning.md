---
adr: ADR-0024
slug: code-scanning
title: Code scanning
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0024
traits:
  code_scanning:
    tool: checkov
    fail_on: low
---

# Code scanning

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

[ADR-0019](ADR-0019-vulnerabilities.md) scans what the repository depends
on. Nothing reads the code the repository writes: an HTTP route that builds
SQL from a parameter, a path taken from user input, a command assembled
with a string.

While these keys are empty, an agent writing such code does not know
**whether a tool will analyse it**. Facing an alert, it does not know
**whether the alert blocks**, nor whether it may dismiss it or exclude the
file.

**Static analysis reads the code without running it.** CodeQL, GitHub's
engine, supports Python and JavaScript/TypeScript among other languages,
and is free on public repositories. Private repositories need GitHub Code
Security. Semgrep is a rule-based scanner that runs anywhere.

**Narrowing a scan silences it without saying so.** A dismissed alert
stays in the Security tab, with who dismissed it and why. A path in
`paths-ignore`, or a query removed by `query-filters`, leaves nothing to
see: the alert never exists.

**A scan of small code finds little.** Measured on governance itself, a
TypeScript CLI that validates its inputs: CodeQL's 87 default queries
reported one alert, a false positive in a test helper. The question is
asked for the repositories where routes, queries and paths do come from
outside.

**Not concerned:** the workflows themselves
([ADR-0011](ADR-0011-forge-and-ci.md)'s `forge.audit`), secrets
([ADR-0015](ADR-0015-secrets.md)), dependencies (ADR-0019).

## Decision

**What governance recommends, and why.**

| Key                     | Recommended value | Reason                                                                                                                                                                                                                                 |
| ----------------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `code_scanning.tool`    | `codeql`          | free on public repositories, supports both languages [ADR-0004](ADR-0004-languages.md) recommends, and its results carry the severity GitHub's merge protection reads. `semgrep` for a private repository without GitHub Code Security |
| `code_scanning.fail_on` | `high`            | the finding is in code this repository wrote, and the agent that wrote it can fix it in the same change. ADR-0019 stops at `critical` because a dependency's fix waits on someone else's release; this one waits on nobody             |

`none` is an answer for `tool`, for a repository with no code that handles
outside input. Any tool that writes SARIF answers it too.

**What governance fixes, whatever you rule:**

1. **No blocking scan without `forge.gate: blocking`** (ADR-0011). With
   `informative` or `none`, a required check does not exist.
2. **The scan runs in a workflow, pinned, on every change.**
   - It runs in a workflow (for CodeQL, the advanced setup), on every pull
     request and every push to the default branch, with its actions
     pinned by SHA (ADR-0011 rule 3).
   - For CodeQL, set `tools: linked`. A SHA pin alone does not freeze the
     queries: on github.com the action uses the bundle GitHub recommends
     at run time. With `linked`, the bundle and its queries change only
     when Dependabot updates the action, in a pull request that is
     scanned. A scheduled scan then adds nothing.
   - The results go to GitHub code scanning as SARIF, where ADR-0019's
     scanner already sends its own. Where the plan does not allow the
     upload, the SARIF stays a job artifact.
   - Default setup alone does not answer this ADR: it is a setting no file
     records, and it runs the version GitHub picks.
3. **How a finding blocks.** CodeQL blocks through the ruleset rule
   "Require code scanning results", with its security-alerts threshold at
   `fail_on` (`high_or_higher` for `high`). Any other tool blocks through
   its own exit code at `fail_on`, for example
   `semgrep scan --error --severity ERROR` for `high`. Its SARIF is not
   documented to carry the `security-severity` that threshold reads.
4. **All code is scanned, tests included.** governance cannot tell what
   counts as test code in another repository, and a fixture that shells
   out is still a command built from a string.
5. **Narrowing the scan is a person's call.** Dismissing an alert,
   excluding a path (`paths-ignore`, `paths`, a tool's ignore file) and
   removing a query or rule (`query-filters`, a narrower suite) all
   silence a finding. The agent fixes the code, or proposes one of these
   with its reason, and a person dismisses it, or approves or merges it as
   [ADR-0022](ADR-0022-review-and-merge.md)'s `review.by` says, as
   ADR-0019 rule 4 has for an ignore rule.

**What `codeql` looks like in practice:**

```yaml
# .github/workflows/codeql.yml
on:
  pull_request:
  push:
    branches: [main]
permissions:
  contents: read
jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    strategy:
      matrix:
        language: [javascript-typescript] # or python
    steps:
      - uses: actions/checkout@<sha> # vX.Y.Z
        with:
          persist-credentials: false
      - uses: github/codeql-action/init@<sha> # vX.Y.Z
        with:
          languages: ${{ matrix.language }}
          tools: linked
      - uses: github/codeql-action/analyze@<sha> # vX.Y.Z
```

With `semgrep`, the job runs `semgrep scan --sarif --output semgrep.sarif`
then `github/codeql-action/upload-sarif` (or `actions/upload-artifact`),
and a separate `semgrep scan --error --severity ERROR` step that fails the
job.

**Ruling: `tool: checkov`, `fail_on: low`, departing from the
recommendation.** The code written here is Terraform HCL, Compose YAML and a
few lines of PHP: CodeQL analyses none of them, and what it does cover,
GitHub Actions workflows, zizmor already audits (ADR-0011). checkov analyses
the Terraform and Compose files and writes SARIF; it is already pinned in
`.trunk/trunk.yaml` and runs locally before push. Without a Prisma API key
it assigns no severity, so any failed check blocks: `low` writes that down.
At ruling time it runs locally only: it is to run in ADR-0011's workflow on
every pull request and push to `main`, uploading its SARIF to code scanning.

## Consequences

### Positive

- An agent writing a route or a query knows a tool reads it, and what to
  do when it objects.
- Every alert, from this scan and from ADR-0019's, is in one place, and
  every way to silence one goes through a person.
- The scan's version moves only in a pull request.

### Negative

- At `high`, a false positive blocks the merge until a person dismisses it.
- The scan adds minutes to every pull request.
- A private repository pays for GitHub Code Security, or blocks on a tool's
  exit code and loses the common view.

### Neutral

- The ruleset that makes CodeQL's alerts block is a GitHub setting, outside
  the repository, and nothing here checks it.

## Alternatives Considered

### Default setup

One click in the repository's settings, and GitHub picks the languages,
the queries and their version. Nothing in the repository records it, the
check cannot see it, and the version moves without a pull request. It is
fine to try, as governance did, before writing the workflow.

### `fail_on: critical`

ADR-0019's threshold. Fewer blocked merges, and high findings that only
report. It suits code whose fix the agent cannot make, which is not the
case for a repository's own code.

### `semgrep` as the default

It runs anywhere, with no plan condition, and its rules are easy to read
and write. Its results do not carry the severity GitHub's merge protection
reads, so blocking goes through each workflow's flags instead of one
ruleset.

### The exit code everywhere, no SARIF

Simpler: the job fails or passes. Alerts then live in CI logs, and a
finding is silenced by changing a flag instead of dismissing an alert with
its reason.

### Excluding tests by default

Less noise, as with governance's false positive. It needs a list of test
paths per language that governance would guess for every repository, and
it is an exclusion nobody decided.

### A key in ADR-0019

ADR-0019 asks what a release contains. This question is about the code the
repository writes. One ADR for both would be the catch-all the supply-chain
ADRs were split to avoid.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0011](ADR-0011-forge-and-ci.md): the gate, the pinning rule, and `forge.audit` for workflows.
- [ADR-0019](ADR-0019-vulnerabilities.md): the dependency scan, its SARIF upload and its rule 4.
- [ADR-0022](ADR-0022-review-and-merge.md): who reviews and merges.
- GitHub:
  - [about code scanning with CodeQL](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning-with-codeql);
  - [customizing advanced setup](https://docs.github.com/en/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/customizing-your-advanced-setup-for-code-scanning);
  - [uploading a SARIF file](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github);
  - [SARIF support](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning);
  - [merge protection](https://docs.github.com/en/code-security/concepts/code-scanning/merge-protection);
  - [GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security);
  - `github/codeql-action`'s [`init` inputs](https://github.com/github/codeql-action/blob/main/init/action.yml) (`tools: linked`).
- Semgrep: [CLI reference](https://docs.semgrep.dev/cli-reference), [rule syntax](https://docs.semgrep.dev/writing-rules/rule-syntax), [JSON and SARIF fields](https://docs.semgrep.dev/semgrep-appsec-platform/json-and-sarif).
- Read on 2026-11-15.

**The keys.**

| Key                     | What it holds                           | Allowed values                                  |
| ----------------------- | --------------------------------------- | ----------------------------------------------- |
| `code_scanning.tool`    | what analyses the repository's own code | `codeql`, another SARIF-writing tool, or `none` |
| `code_scanning.fail_on` | the lowest severity that blocks a merge | `critical`, `high`, `medium`, `low`, `none`     |

**An empty key is not an answer.** The value is written in this file and
nowhere else; whoever needs it links here. See ADR-0001 for the check
command.
