---
adr: ADR-0001
slug: record-architecture-decisions
title: Record architecture decisions
status: accepted
revision: 4
date: 2026-11-14
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0001
traits:
  record-architecture-decisions:
    format: nygard
---

# Record architecture decisions

## Status

Accepted

> **This ADR is not a question.** The other governance ADRs arrive with
> `status: proposed` and wait for your repository to rule on them. This one
> arrives `accepted`, because it describes the mechanics you will use to
> rule on the others. You can supersede it like any other ADR, with a new
> ADR that lists it in `supersedes:`. Until then, it is what says how ADRs
> are written and ruled on here.

## Context

An architecture decision that lives only in a conversation gets reopened
every six months, with the same arguments and without the context that
settled it. Coding agents make this worse: an agent that finds no written
reason for a choice treats it as an accident, "fixes" it, or asks again.
An ADR is the decision written down: its context, what it decided, what it
costs, and what else was weighed.

Most of these questions are not specific to one repository: commit format,
branching, localization, tests. Deciding them from scratch in every
repository drifts. Copying another repository's answers copies a context
that is not yours.

governance answers this the way [surdesrails](https://github.com/trivoallan/surdesrails)
does: it ships the **question**, with the answer it recommends and why, and
each repository rules on it. governance is a personal edition of
surdesrails, without its enterprise context, and is imported **instead of**
it through [ontrack](https://github.com/trivoallan/ontrack).

What remains to decide is how these ADRs are written, shipped and ruled on.

## Decision

We will keep ADRs as follows. Each point does one job and does not overlap
the others.

**1. The format is Nygard's.** Every ADR has, in this order: `## Status`,
`## Context`, `## Decision`, `## Consequences` (with `### Positive`,
`### Negative` and `### Neutral`), `## Alternatives Considered` and
`## References`. Everything is in English. governance writes its ADRs with
`/pm-skills:develop-adr`, and uses its template sections.

**2. governance ADRs are named `ADR-NNNN-slug.md`** and numbered without
gaps. ontrack imports them into `docs/adr/trivoallan/`. The ADRs your
repository writes for itself live in `docs/adr/`, outside that directory,
with their own numbering.

**3. The frontmatter is the machine source.**

```yaml
adr: ADR-0006 # must match the file name
slug: commits # must match the file name
title: Commits
status: accepted # proposed as shipped; accepted or rejected once ruled
revision: 1 # written by governance: it dates the question, not the file
date: 2026-11-14 # the day you ruled
authors: [Your Name] # the people who decided, no email addresses
supersedes: [] # the ADRs this one replaces
check: npx --no-install ontrack-engineering-check ADR-0006 # optional, see rule 8
traits: { ... } # the machine-readable part of the answer
```

The reverse edge is not written, it is computed: an ADR is superseded when
another one lists it in `supersedes:`. Storing it twice would give two
places to keep in step, and nothing would compare them.

**4. The body freezes once ruled; the status does not.** Once your
repository rules an ADR `accepted` or `rejected`, your copy's text does not
change, and reopening the decision takes a new ADR. The things still
written in a frozen ADR are its `status` and its `check:` line (rule 8),
which says how the decision is checked, not what it is. A superseded ADR stays in the
directory, marked: the directory is a log of decisions, not a list of what
is in force.

This freeze is about **your verdict**. The ADRs this package ships, this one
included, change only through `revision` (rule 6): governance edits the
file and raises the number, and `ontrack plan` tells you. It does not write
a superseding ADR for its own revisions.

**5. A governance ADR asks a question, and the answer belongs to your
repository.** It arrives `status: proposed`, with every key under `traits:`
empty. Its Decision section states what governance recommends and why, then
a how-to-rule block, opened by a marker sentence, that lists the steps to
rule. The schema recognises that sentence, so this ADR does not quote it. Staying `proposed` is a state, not an oversight.

A **trait** is a key this package ships and whose value is yours: the question
and its answer sit in the same place. The prose explains and justifies; the
trait is read without interpretation.

`rejected` is a full answer. When the question does not apply to your
repository, rule `rejected`, remove the whole `traits:` block, and say what
stands in for the decision, so an agent knows what to go by.

**6. `revision` dates the question.** governance raises it by one when, and
only when, the question changes: a trait added, removed or renamed, an enum
value changed, or the recommended answer changed. A wording, typo or link
fix leaves it alone, and so does a change to a `Suggested skills` line in
an ADR's References: that line names the Claude Code skills that help carry
out the decision ([ADR-0017](ADR-0017-agent-tooling.md)), and it is advice,
not part of the question. The same goes for a `check:` line (rule 8) and
for the scripts it calls. `ontrack plan` then reports an ADR as `revised`
only when there is something to rule on again. Each ADR above revision 1
ends with a **Revisions** list that says what changed and what to re-answer:
read it before ruling again.

**7. `mdschema` refuses a half-ruled ADR.** The `.mdschema.yml` shipped
next to these ADRs checks that a ruled ADR carries its verdict: status
decided, date set, no trait key left empty, the sections above present, and
the how-to-rule block gone. This ADR's own `check:` line runs it:
`ontrack check` calls `ontrack-engineering-check ADR-0001`, which runs the mdschema
this package depends on, with that schema, on every copy of these ADRs that
is no longer `proposed`. It fails and names the file and the key. Nothing
is copied into your repository and nothing is installed by hand.

**8. A `check:` line says when your work departs from a decision.** An ADR
may carry, in its frontmatter, a `check:` key holding one shell command.
Once your repository rules the ADR `accepted`, `ontrack check` runs it from
your repository's root and reports the ADR as `pass` or `fail`. A command
this package ships calls `npx --no-install ontrack-engineering-check <ADR number>`: the
script reads the traits you ruled, so the same line holds whatever you
decide, and `--no-install` keeps `npx` from fetching anything from a
registry. Read an imported `check:` line as you would an npm install script:
it runs this package's code in your repository.

Those scripts follow the version of this package, not `revision`:
an `npm update` can change what a check does, and `ontrack plan` does not
report it. A `check:` line governance adds, changes or removes in an ADR
you have already ruled does reach your copy, as rule 4 allows: `ontrack
plan` reports the ADR `check` and shows the line that would go and the one
that would come, and `ontrack apply` reports it `synced` and writes that
line, nothing else. Read the line at `plan`, before `apply` writes it.

**9. If governance asks the wrong question,** write your own ADR in
`docs/adr/`, cite the governance ADR you depart from, and say how. It does
not depend on any network: the record lives where the decision applies.

## Consequences

### Positive

- A decision is found with its context and its cost, by people and by
  agents, in the repository it applies to.
- A repository starts from a reasoned recommendation instead of a blank
  page, and rules on it in one commit.
- The supersession graph and the open questions (`status: proposed`) can be
  computed from the frontmatter.
- `ontrack plan` reports a question as `revised` only when it moved.
- An ADR that carries a `check:` line is checked by `ontrack check`, so a
  departure from it fails before review instead of in it.

### Negative

- Three conventions, one of them tooled: `mdschema` checks a ruled ADR when
  `ontrack check` runs. If nothing runs `ontrack check`, in a pull request or
  elsewhere, nothing looks at your ADRs.
- governance adapts surdesrails and will drift from it. Nothing detects
  when an SDR it adapts changes: the only link is the source line in each
  ADR's References, read by hand.
- A question ADR as this package ships it fails the schema on purpose, so
  governance's own questions are checked by review only.

### Neutral

- governance is imported instead of surdesrails, not alongside it. A
  repository that needs surdesrails' enterprise questions imports
  surdesrails.
- The section format differs from surdesrails (Nygard rather than MADR),
  which makes comparing an ADR with its SDR a little slower.

## Alternatives Considered

### Hand-written ADRs with no tooling

Nothing to install. But nothing machine-readable either: rebuilding the
supersession history or finding the open questions means parsing free text,
and a half-filled ADR goes unnoticed.

### MADR, as surdesrails uses it

A richer section set (Considered Options, Decision Drivers, Pros and Cons).
Rejected so that governance ADRs follow the `/pm-skills:develop-adr`
template they are written with; the Nygard sections carry the same content
under fewer headings.

### Importing surdesrails directly

No adaptation to maintain. But its questions assume an enterprise context
(GitLab, a service baseline, an internal design system, Jira), so every
personal repository would rule several of them `rejected` by default, and
its schema enums would not fit.

### Shipping verdicts instead of questions

governance could ship its own answers as `accepted` ADRs. Simpler to write,
but the consuming repository would have nothing to decide, and the reasons
would describe governance's context instead of its own.

## References

- Suggested skills: `develop-adr` from `pm-skills@product-on-purpose`, to write a governance ADR or your own.
- Adapted from surdesrails [SDR-0001](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0001-record-architecture-decisions.md), revision 1.
- Michael Nygard, [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) (2011).
- [ontrack](https://github.com/trivoallan/ontrack): imports these ADRs and reports `new`, `revised` and `removed` ones.
- [mdschema](https://github.com/jackchuka/mdschema): the checker behind `.mdschema.yml`.
- [`ontrack check`](https://github.com/trivoallan/ontrack#ontrack-check-output-contract): runs the `check:` line of each decided ADR.

**Revisions.** What changed in the question at each revision, and what
a repository that already ruled must re-answer.

- Revision 2: rule 4's freeze applies to a repository's verdict, and governance changes the ADRs it ships only through `revision`; a `Suggested skills` line changes no revision. No key changed: nothing to re-answer.
- Revision 3: rule 8 describes `check:` lines, rule 4 lets a ruled ADR receive one, and rule 6 says a `check:` line and its scripts change no revision. No key changed: nothing to re-answer.
- Revision 4: rule 7 runs the schema through this ADR's `check:` line, which refuses a half-ruled ADR, in place of a command typed by hand after copying `.mdschema.yml`. No key changed: nothing to re-answer.
