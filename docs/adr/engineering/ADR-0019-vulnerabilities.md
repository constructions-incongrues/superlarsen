---
adr: ADR-0019
slug: vulnerabilities
title: Vulnerabilities
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
traits:
  vulnerabilities:
    sbom: none
    scanner: grype
    fail_on: critical
---

# Vulnerabilities

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

[ADR-0018](ADR-0018-dependencies.md) keeps dependencies current. It does
not say whether what you ship **right now** carries a known vulnerability,
nor what happens when it does. Its updates arrive weekly, after a cooldown;
a CVE published this morning against a version you already released does
not wait for them.

While these keys are empty, an agent that meets a red vulnerability scan
does one of two things: it ignores the finding to turn the check green, or
it stops every change until someone looks. And nobody can say, a month
after a release, which versions of which packages that release contained.

**Two artefacts, one question.** The **SBOM** (software bill of materials)
is the list of components a release contains, written in a standard format
when the release is built. The **scan** matches a list of components against
a vulnerability database. The SBOM answers "what did we ship?"; the scan
answers "is any of it vulnerable?". Scanning the SBOM of a release answers
the second question about exactly what was shipped, not about what the
working copy holds today.

**A vulnerability is found in code nobody changed.** The database moves
every day; the lockfile does not. A scan that runs only on pull requests
stays green on a repository nobody touches, until someone does.

**Not concerned:** secrets ([ADR-0015](ADR-0015-secrets.md)), static analysis
of your own code ([ADR-0024](ADR-0024-code-scanning.md)), and licence
compliance, even though an SBOM lists
licences too.

## Decision

**What governance fixes, whatever you rule:**

1. **No blocking scan without `forge.gate: blocking`**
   ([ADR-0011](ADR-0011-forge-and-ci.md)). With `informative` or `none`, a
   `fail_on` other than `none` blocks nothing, and writing it claims a gate
   that does not exist. That combination is forbidden.
2. **The scan runs on every pull request and on a schedule** on the default
   branch, at least weekly: the first catches what a change brings in, the
   second what the database learned since.
3. **Only a fixable vulnerability fails the check** (`--only-fixed` for
   Grype). A vulnerability with no fixed version cannot be resolved by a
   change, so blocking on it blocks every change. It is still reported.
4. **An agent never silences a finding to turn a check green.** Not by
   adding an ignore rule, not by lowering `fail_on`, not by removing the
   job. It fixes by updating the dependency, through ADR-0018's updater
   when one is ruled. When no fixed version exists, or the vulnerable code
   is not reachable, it proposes an ignore rule and a person approves or
   merges it, as [ADR-0022](ADR-0022-review-and-merge.md)'s `review.by`
   says.
5. **Every ignore rule names one vulnerability and says why**: in
   `.grype.yaml`, an entry under `ignore:` with `vulnerability:` and
   `reason:`. An ignore by severity, by package alone or without a reason
   is not an answer, it is a switch turned off.
6. **The SBOM is built from what is released**, by the release job, and
   published with it: attached to the GitHub release, and for an image,
   attested to its digest. An SBOM regenerated later from the source
   describes the source on that later day, not the release.
7. **The scanner and its actions obey ADR-0011**: pinned by SHA (rule 3),
   explicit `permissions:`, no secret.

What is yours to decide is the format, the tool, and the threshold.

**What governance recommends, and why.**

| Key                       | Recommended value | Reason                                                                                                                                                                                        |
| ------------------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `vulnerabilities.sbom`    | `cyclonedx`       | designed for security use (vulnerabilities, VEX); Grype reads it as well as SPDX                                                                                                              |
| `vulnerabilities.scanner` | `grype`           | a single binary with no account, it scans an SBOM, a directory or an image, and its threshold and ignore rules are plain configuration                                                        |
| `vulnerabilities.fail_on` | `critical`        | a critical vulnerability with a fix available justifies stopping a merge; below that, a blocking check is turned off sooner or later, by a person or an agent, and then blocks nothing at all |

Grype's SBOM companion is [Syft](https://github.com/anchore/syft), from the
same publisher; ruling `sbom: cyclonedx` with `scanner: grype` means Syft
writes the SBOM, unless you name another tool in your reason.

**What `grype` looks like in practice.** In the pipeline, on pull requests
and on a weekly `schedule:`, with `anchore/scan-action` pinned by SHA:

```yaml
- uses: anchore/scan-action@<sha> # vX.Y.Z
  with:
    path: .
    severity-cutoff: critical # vulnerabilities.fail_on
    only-fixed: true # rule 3
    fail-build: true
    output-format: sarif
```

The SARIF output can be uploaded to code scanning, so findings below the
threshold remain visible. Locally, or on a release's SBOM:

```bash
syft . -o cyclonedx-json=sbom.cdx.json
grype sbom:./sbom.cdx.json --fail-on critical --only-fixed
```

In the release job, `anchore/sbom-action` with `format: cyclonedx-json`
uploads the SBOM as a release asset when it runs during a GitHub release.
For an image, `actions/attest` with `sbom-path` binds the SBOM to the image
digest; it needs `id-token: write`, `attestations: write` and
`artifact-metadata: write`.

An ignore rule, proposed by an agent, approved or merged by a person:

```yaml
# .grype.yaml
ignore:
  - vulnerability: CVE-2026-12345
    reason: "parser only reached through admin CLI; no fix released yet"
```

Grype refuses to scan with a database older than five days by default
(`db.max-allowed-built-age`). Leave it: a stale database is a green check
that knows nothing.

**Ruling: `sbom: none`, `scanner: grype`, `fail_on: critical`.** `sbom`
departs from the recommendation because this repository releases nothing
(ADR-0012): the images it runs are published by their upstream projects, and
rule 6 builds an SBOM from a release. Scanner and threshold follow the
recommendation. At ruling time only Dependabot alerts run, at the forge, and
they cover `package.json` and the Terraform lock file, not the Docker images
that make up the attack surface. Grype is to scan the images referenced in
`stacks/*/compose.yaml`, on every pull request and weekly, through ADR-0011's
pipeline; images pinned to `latest` or to no tag are to be pinned, so the
scan sees the image that runs.

## Consequences

### Positive

- An agent facing a red scan knows its move: update the dependency, or
  propose an ignore rule for a person to approve or merge. Never silence it.
- Every release says what it contains, in a file a scanner reads, so a CVE
  published later can be checked against releases already shipped.
- The weekly scan finds vulnerabilities in code nobody touched.

### Negative

- The scheduled scan can turn the default branch red without any change;
  someone has to read it.
- `critical` lets high vulnerabilities merge with only a report; the SARIF
  upload is where they are seen, if anyone looks.
- `--only-fixed` hides from the gate a critical vulnerability with no fix,
  however exploitable; reading the report is the only defence.
- Ignore rules accumulate, and Grype gives them no expiry date: they are
  reviewed by reading `.grype.yaml`, or not at all.

### Neutral

- Dependabot alerts and GitHub's own SBOM export (SPDX, from the
  dependency graph) may run alongside; neither is the gate this ADR asks
  for.

## Alternatives Considered

### `grype` with Syft

Recommended. No account, no service, configuration in one file. Its cost:
two tools to pin instead of one, and a vulnerability database downloaded on
every run unless cached (`cache-db`).

### `trivy`

One tool for the SBOM, the scan, images, and infrastructure files. A
legitimate answer, especially for a repository that also wants its
Dockerfiles or Terraform checked. Its cost: a wider tool means a wider
action to trust, and rule 3 of ADR-0011 (pin by SHA) applies to it as to
any other.

### GitHub only (Dependabot alerts, `dependency-review-action`)

Nothing to install: the dependency graph exports an SPDX SBOM, alerts
report vulnerable dependencies, and `actions/dependency-review-action` can
fail a pull request that adds one. Its limits: it sees manifests the
dependency graph understands, not an image's operating-system packages,
and the SBOM it exports describes the default branch today, not a release.
Write `github` as the scanner if that is enough for you.

### `fail_on: high`

Stricter. Each high finding with a fix stops the merges until the update
lands; on a repository without automerge
([ADR-0018](ADR-0018-dependencies.md)), that is often enough to have the
gate turned off.

### `fail_on: none`

The scan reports and blocks nothing. Honest when `forge.gate` is not
`blocking`, and the required value then (rule 1).

### `sbom: spdx`

The ISO standard (ISO/IEC 5962), and the format GitHub exports. Equally
readable by Grype. Preferred where a customer or regulator asks for SPDX.

### No SBOM (`sbom: none`)

The scan still runs on the working copy. What a past release contained is
then reconstructed from its tag, if the lockfile was complete.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0011](ADR-0011-forge-and-ci.md): `forge.gate`, the `scan` stage, and the rules every workflow obeys.
- [ADR-0012](ADR-0012-delivery.md): the release job that builds and publishes the SBOM.
- [ADR-0018](ADR-0018-dependencies.md): the updates that fix what the scan finds.
- [Grype](https://github.com/anchore/grype) and its [CLI](https://oss.anchore.com/docs/reference/grype/cli/) and [configuration](https://oss.anchore.com/docs/reference/grype/configuration/) references, [Syft](https://github.com/anchore/syft), [anchore/scan-action](https://github.com/anchore/scan-action), [anchore/sbom-action](https://github.com/anchore/sbom-action), [actions/attest](https://github.com/actions/attest); GitHub documentation, [exporting an SBOM for a repository](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/exporting-a-software-bill-of-materials-for-your-repository), read on 2026-11-14.

**The keys.**

| Key                       | What it holds                                                                | Allowed values                                              |
| ------------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `vulnerabilities.sbom`    | the format of the SBOM each release publishes                                | `cyclonedx`, `spdx`, `none`                                 |
| `vulnerabilities.scanner` | what matches components against a vulnerability database                     | a tool name such as `grype`, `trivy` or `github`, or `none` |
| `vulnerabilities.fail_on` | the lowest severity of a fixable vulnerability that fails the required check | `critical`, `high`, `medium`, `low`, `none`                 |

**`scanner: none` means nothing scans**, and then `fail_on` is `none` too.
**`sbom` follows releases**: a repository whose `delivery.release_tool`
(ADR-0012) is `none` writes `sbom: none`.

**What the check does not see.** The schema refuses an empty key and an
unknown `sbom` or `fail_on`. It reads neither the workflows nor ADR-0011:
`fail_on: critical` with `forge.gate: informative` passes it, and review
catches it. An empty key is not an answer: all three are required. The
value is written in this file and nowhere else; whoever needs it links
here. See ADR-0001 for the check command.
