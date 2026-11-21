---
adr: ADR-0005
slug: validation
title: Validation
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
traits:
  validation:
    boundary: none
    data_files: json-schema
---

# Validation

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

While these keys are empty, an agent writing an entry point (an HTTP route,
a command, a configuration reader) does not know **what to describe the
shape of incoming data with**. It writes a hand-made check, different at
every boundary, or none at all, and lets a missing field become a default
nobody wanted.

**A boundary is any point where data enters without the running code
having produced it**: request body, configuration file, queue message,
environment variable, command-line argument. Two less obvious cases count
too: **a row read from a database**, which an older version of the code may
have written, and **a semi-structured column** (`jsonb`, a blob), even inside
an otherwise validated row.

**Why declare rather than check by hand.** Three reasons, in the order they
bite:

1. **A hand-written check is opt-in, and its coverage decays on its own.**
   Adding a field adds an unvalidated field, silently. The argument holds
   fully for `boundary`, where the model _is_ the type. It holds only half
   for `data_files`: adding a key to a file without adding it to the schema
   is still possible, but the omission **shows**, because the schema sits
   next to the file.
2. **A schema can be read without running anything.** A check buried in a
   function only says what it accepts to someone who reads and runs it.
3. **A schema is a machine-readable contract.** An agent that must produce
   conforming data reads the schema; without one it guesses from an example,
   and **an example never says what is required**, only what was present
   that day.

**Two moments, two guarantees, and neither replaces the other.** `boundary`
validates **when the program reads** the data: the only protection at run
time, including against a file edited later. `data_files` validates
**statically**, when the file is written: the only one that shows the error
in the editor of whoever makes it, and the only one a reviewer can exercise
without running the program. A repository that holds data files needs both.

**Not concerned:** internal structures that your own code produces and
consumes. They crossed no boundary, and the language already checks them.

## Decision

**What governance fixes:** data is validated at every boundary. What is
yours to decide is the **mechanism**. A repository that cannot use any of
the recommended mechanisms (a performance-critical path, a zero-dependency
constraint) names another and says why: it departs from the means, never
from the requirement.

**What governance recommends, and why.**

| Key                     | Recommended value                                                   | Reason                                                                                                                                  |
| ----------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `validation.boundary`   | _depends on your language_: `pydantic` (Python), `zod` (TypeScript) | each validates at run time, derives the type from the schema so there is one source, and exports a JSON Schema                          |
| `validation.data_files` | `json-schema`                                                       | the one format editors already consume, and YAML and TOML map onto it. One schema serves the file, the editor, the review and the agent |

**The grid used to set other options aside**, so you can apply it to a
language not listed here. In order, an option falls if it: **describes
without validating** at run time; validates **by hand**, field by field, so
an added field is an uncovered field; exposes **no exportable schema**; or,
all else equal, has the narrowest ecosystem. For Go, surdesrails retained
`go-playground/validator` on this grid.

**The value's format:** the name the library is installed under (`pydantic`,
`zod`), with no version. The version lives in your dependency file; copied
here, it would go stale with nothing to say so.

**`json-schema` does not contradict `pydantic` or `zod`.** Writing JSON
Schemas _to type code_ would give two sources that drift, which is why the
boundary recommendation is a type-first library. A data file read by no type
has no second source to drift from. Where both exist (a file read by a
model), **the model is authoritative**, and the schema is derived from it or
aligned by hand in the same pull request.

**Ruling: `boundary: none`, `data_files: json-schema`.** `boundary`
departs from the recommendation because no code written here reads data at
run time: Docker Compose, Terraform and Cartons consume the files, and the
WordPress mu-plugin parses no input. That is the case `none` exists for.
`data_files` follows the recommendation. At ruling time no file is attached to a
schema, and Trunk's linters (`yamllint`, `taplo`, `tflint`, `checkov`) check
syntax and security, not keys: each `compose.yaml` is to be attached to the
compose-spec JSON Schema with a `# yaml-language-server: $schema=` comment.

## Consequences

### Positive

- A misspelt or misplaced key in a stack definition is flagged in the
  editor and in review, before Cartons deploys it.
- An agent knows there is no run-time boundary to guard here, and adds no
  validation library.

### Negative

- Each `compose.yaml` carries a schema comment, and the schema version has
  to follow the Compose version in use.

### Neutral

- Terraform files keep their own validation (`terraform validate`,
  `tflint`), which a JSON Schema would not add to.

## Alternatives Considered

### A declared schema, validated automatically

The shape is written once, and validation follows from it. Recommended.

### A hand-written check at each boundary

No new dependency, and coverage that depends on everyone's discipline,
boundary by boundary, field by field.

### Nothing

Trust what comes in. Tenable only for a repository with no boundary; rule
`rejected` then, not an empty key.

## References

- Adapted from surdesrails [SDR-0005](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0005-validation.md), revision 1 (adds `zod` for TypeScript, which SDR-0005 left open).
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0004](ADR-0004-languages.md): the main language, which picks the `boundary` library.

**The keys.**

| Key                     | What it holds                                                                        | Allowed values                                                    |
| ----------------------- | ------------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| `validation.boundary`   | what describes and validates data **when the program reads it**                      | a library name such as `pydantic` or `zod`, or `none` (see below) |
| `validation.data_files` | what validates a data file **statically**, without running the program that reads it | `json-schema`, another named mechanism, or `none`                 |

**`boundary: none` exists, and does not mean "we do not validate".** It
means this repository **reads no data at run time**: it holds files, and
nothing runs to consume them, as in a configuration, schema or text
repository, which still needs `data_files`. A repository that runs code and
chooses not to validate does not write `none`: it is not compliant, and
review has to say so.

**The schema must be attached to the file, or it guards nothing.** Attach
it with `$schema` in the file when the encoding allows it, or else through
the naming convention of the tool you use.

**The model lives next to the boundary it guards**, not in a shared types
module: the entry point decides what it accepts.

**Neither key is checked against a list.** Validation libraries are not a
closed set, and freezing one would refuse the departure this file allows.
The schema checks that you answered, never that the answer is right.

**`rejected` means this repository has no data boundary at all**, which is
rare but real. It is not the same as "we validate by hand": that is a value,
and it is written.

**Both keys are required**: an empty key is not an answer. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.
