---
adr: ADR-0015
slug: secrets
title: Secrets
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0015
traits:
  secrets:
    storage: keychain
    guard: trufflehog
---

# Secrets

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

While these keys are empty, an agent that needs an API key **puts it where
it is easiest to reach**: a `.env` file, a test fixture, a configuration
default. The gitignore covers the first case, if someone wrote it. Nothing
covers the other two, and nothing stops the commit.

**A secret is any value that grants access on its own**: API key, token,
password, private key, connection string with credentials. Its name is not
a secret; its value is.

**The agent is itself a leak channel, and git is not the only exit.** A
`.env` file of clear values, gitignored, never reaches the repository. But
an agent reads it as soon as it looks for why a variable is missing, and
the value goes into the model's context and into the session transcripts.
A file that holds only **references** to values (the way to fetch them, not
the values) can be read without leaking anything.

**What references protect, and what they do not.** They stop the
**passive** leak: a file read to understand an error. They do not stop the
**active** one: a process that inherits the environment, such as an agent
running `printenv`, sees the resolved values. No storage hides a secret from
a process it was handed to. This ADR does not claim otherwise.

**Two moments, two keys, and neither replaces the other.** `storage` decides
where the value lives **while you work**. `guard` decides what **refuses a
commit** that carries one anyway, because storage is a habit and habits
fail.

**Not concerned:** the secrets your CI uses. They live in the forge, under
the rules of [ADR-0011](ADR-0011-forge-and-ci.md).

## Decision

**What governance fixes, and is not up for ruling:**

1. **No secret value enters the repository**, in any file and any commit,
   history included.
2. **A leaked secret is revoked, not rewritten out of history.** Once
   pushed, it has been fetched, forked or cached; `git filter-repo` removes
   it from your copy only. Revoke it at its provider, issue a new one, and
   leave the history as it is. The instinct to "clean up the commit",
   an agent's first of all, is the one to resist.

What is yours to decide is the **mechanism**.

**What governance recommends, and why.**

| Key               | Recommended value                                                 | Reason                                                                                                                                   |
| ----------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `secrets.storage` | _anything but `env-file`_: `keychain` for a solo macOS repository | the files on disk hold references, so an agent reads them without leaking; the keychain is already installed, free, and needs no account |
| `secrets.guard`   | `gitleaks`                                                        | it scans the staged changes before each commit, and refuses the commit when it finds a secret                                            |

**What `keychain` looks like in practice**, with
[direnv](https://direnv.net/) loading the environment:

```bash
# once, to store the value (prompts for it, so it never enters your history)
security add-generic-password -a "$USER" -s openai-api-key -w
```

```bash
# .envrc: committable, it holds the reference, not the value
export OPENAI_API_KEY="$(security find-generic-password -s openai-api-key -w)"
```

`1password` (`op run --env-file=.env`, with `op://vault/item/field` values)
and `sops` (an encrypted file, decrypted with `sops exec-env`) give the same
property on other platforms or across machines.

**`gitleaks` runs locally, and a local hook can be skipped.**
`git commit --no-verify` bypasses it, and agents do reach for that flag when
a hook blocks them. The refusal that cannot be skipped happens on the
server, such as GitHub's push protection where your plan offers it. No
governance ADR asks for it yet, so the hook is often the only thing standing
between a secret and a push. Install it as a pre-commit hook running:

```bash
gitleaks git --pre-commit --staged --redact
```

**Ruling: `storage: keychain`, `guard: trufflehog`.** Deployed secrets
already stay out of the repository: `infrastructure/resources.toml` holds
`[[VARIABLE]]` references that Cartons fills at deploy time, and the
Terraform tokens are `sensitive` variables set in Terraform Cloud. Local
values live in the macOS keychain, as recommended. `guard` departs from the
recommendation: `trufflehog` is already installed and pinned through Trunk
(`.trunk/trunk.yaml`), and a second scanner would duplicate it. At ruling
time it runs before push only (`trunk-check-pre-push`); it is to run before
each commit too, and GitHub's secret push protection, free on a public
repository, is to be turned on as the refusal a skipped hook cannot bypass.

## Consequences

### Positive

- An agent can read every file in the repository without a secret value
  entering its context.
- A commit carrying a secret is refused before it exists, on every machine
  where the hook is installed.
- A leak has one written answer, revocation, instead of a history rewrite
  improvised under pressure.

### Negative

- Moving from a `.env` of clear values to references costs one pass per
  repository, one secret at a time.
- `keychain` works on macOS only, and does not follow you to another machine
  or a container; a second platform means another storage.
- The hook has to be installed on every clone, and `--no-verify` skips it.
- References do not stop the active leak: a process that inherits the
  environment sees the values.

### Neutral

- CI secrets follow ADR-0011; a server-side refusal on push is outside this
  ADR and outside any governance ADR so far.

## Alternatives Considered

### References resolved by a manager (`keychain`, `1password`, `sops`)

Files hold the way to fetch a value, not the value. Recommended; the tool
depends on your platform and on whether secrets are shared.

### A `.env` file of clear values, gitignored (`env-file`)

No tool, and the convention most repositories already follow. It keeps
values out of git, but not out of an agent's context. A legitimate answer
when you accept that cost: write `env-file`, and name the cost in your
Consequences.

### A committed `.env.example`

Variable names without values, so a reader knows what to set. Not required
here: with references, the `.envrc` already lists the names, and without
them, the example adds a second file to keep in step.

### Rewriting history after a leak

Makes the secret disappear from your copy, and only from it. Rejected in
favour of revocation, which works whoever already fetched the commit.

### Denying the agent access to `.env`

An agent permission rule that refuses to read the file. Not recommended:
a shell command reads it anyway, and governance does not configure one
agent's tooling.

### No guard

Review is the only check. A secret is then caught after it was pushed,
which is when revocation becomes mandatory.

## References

- Suggested skills: `claude-security` from `claude-security@claude-plugins-official`, to scan the repository or a diff.
- Original to governance: no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0011](ADR-0011-forge-and-ci.md): where CI secrets live, and the rules that keep them out of logs and forks.
- [ADR-0005](ADR-0005-validation.md): environment variables are a boundary; their shape is validated there, their values are kept here.
- [gitleaks](https://github.com/gitleaks/gitleaks), [direnv](https://direnv.net/), [sops](https://github.com/getsops/sops).

**The keys.**

| Key               | What it holds                                                  | Allowed values                                                                              |
| ----------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `secrets.storage` | where secret values live **while you work**                    | a manager name such as `keychain`, `1password` or `sops`; `env-file`; or `none` (see below) |
| `secrets.guard`   | what refuses a commit carrying a secret, **before it is made** | a tool name such as `gitleaks`, or `none`                                                   |

**`storage: none` means this repository handles no secret at all**, not
that you have not decided where they go. A repository that reads an API key
writes where that key lives.

**`guard: none` is an answer, and a weak one**: the guard exists for the
accident, which happens just as well in a repository that "has no secrets".

**`rejected` is hard to justify here.** The two fixed rules apply whatever
you rule. A repository with no secret and no guard writes `none` twice, so
an agent knows it was decided.

**Neither key is checked against a list.** The schema checks that you
answered, never that the answer is right. Both keys are required: an empty
key is not an answer. The value is written in this file and nowhere else;
whoever needs it links here. See ADR-0001 for the check command.
