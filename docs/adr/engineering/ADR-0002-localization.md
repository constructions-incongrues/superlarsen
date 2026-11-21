---
adr: ADR-0002
slug: localization
title: Localization
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
traits:
  localization:
    language:
      default: french
      documentation:
      commits:
      code: english
      comments:
---

# Localization

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

While these keys are empty, an agent writing in this repository does not
know which language to name a function in, which language to comment in,
or how to write a commit message. It guesses, and guesses differently each
time. Once the values are written, it reads and applies them without asking
you again.

The question exists because each medium has different readers.
Documentation is read by the people who use and maintain the repository; a
symbol by anyone who reads the code, including tools; a comment by whoever
rereads a function in six months; a commit message by whoever walks the
history in two years. "The same language everywhere" is an answer, but it
is one you choose, and `default` is where you say it.

## Decision

**What governance recommends, and why.** One default language, no
overrides:

| Key       | Recommended value | Reason                                                                                                                                  |
| --------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `default` | `english`         | the repository may be read by anyone, and by agents and tools whose default language is English; one language means no rule to remember |

`documentation`, `commits`, `code` and `comments` are left empty: they take
`default`. **Only fill one of those four to depart from the default.**
Otherwise leave it empty, which keeps the decision readable at a glance.
Removing the key says the same thing, and both forms pass the check.

**This recommendation does not bind your repository.** It exists so there
is something to react to instead of a blank page: keep it, amend it or set
it aside. A team that works in French and writes for itself has good
reasons to answer `default: french` with `code: english`, which is what
surdesrails recommends.

**Ruling: departs from the recommendation**, with `default: french` and
`code: english`, the split the Alternatives Considered call "French prose,
English symbols". The team is French-speaking and writes for itself and the
association it hosts for: the README, commit messages since #14 and recent
comments are already in French. Symbols (Terraform resources, Compose
services) stay in English, next to the Docker, Terraform and WordPress APIs
they sit beside. `CLAUDE.md`, in English at ruling time, is an exception to
correct. The governance ADRs keep the language they ship in.

## Consequences

### Positive

- An agent never has to guess the language of a name, a comment, a commit
  or a page.
- Maintainers write prose, commits and comments in their own language,
  without losing nuance.
- Symbols read naturally next to the libraries and APIs they use.

### Negative

- Two languages means one rule to remember: prose in French, names in
  English.
- Contributors who do not read French cannot read the documentation or the
  history.

### Neutral

- Earlier English commit messages stay in the history; only new ones follow
  this ruling.

## Alternatives Considered

### Everything in French

Documentation, commits, symbols and comments in French. Natural for a
French-speaking team writing for itself, but symbols in French read oddly
next to every library and API, and the repository closes itself to
non-French readers.

### French prose, English symbols

surdesrails' recommendation: `default: french`, `code: english`. A good fit
for a French-speaking team; governance does not recommend it because its
repositories are written for a wider audience, and two languages means one
more rule to apply.

### Another split

The four overrides are independent: nothing forces them to line up, for
example English code and comments with French documentation. Each extra
override is one more thing to remember.

## References

- Adapted from surdesrails [SDR-0002](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0002-localization.md), revision 1.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.

**The keys.**

| Key             | What it holds                                           | Allowed values      |
| --------------- | ------------------------------------------------------- | ------------------- |
| `default`       | the language of everything not overridden below         | `french`, `english` |
| `documentation` | documentation, if it differs from the default           | `french`, `english` |
| `commits`       | commit messages, if they differ                         | `french`, `english` |
| `code`          | symbols (functions, classes, variables), if they differ | `french`, `english` |
| `comments`      | code comments, if they differ                           | `french`, `english` |

**Only `default` is required.** The other four are overrides: an empty or
removed key means "same as `default`", and that is an answer, not an
oversight. The value is written in this file and nowhere else; whoever needs
it links here.

**Checking.** The schema refuses an empty `default` and names it, and lets
an empty override pass. It does not see a removed `default`: an absent key
passes, and only review catches it. See ADR-0001 for the command.
