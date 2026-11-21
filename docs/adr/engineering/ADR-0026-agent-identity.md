---
adr: ADR-0026
slug: agent-identity
title: Agent identity
status: accepted
revision: 1
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
traits:
  agent:
    identity: maintainer
---

# Agent identity

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

This ADR is written for a repository kept by **one person** who works with
a coding agent. While this key is empty, the agent uses **whatever GitHub
credentials it finds** on the maintainer's machine: their `gh` session,
their SSH key.

**Everything the agent does is then recorded under the maintainer's name.**
Its commits, pushes, pull requests and comments cannot be told from the
maintainer's afterwards, as [ADR-0022](ADR-0022-review-and-merge.md) says
of its merges and approvals.

**And the review stays a merge nobody enforces.** GitHub does not let a
pull request's author approve it. When the agent opens pull requests as
the maintainer, the maintainer is their author, so ADR-0022 can only be
ruled `review.by: maintainer`: the review is the maintainer's merge, and
what holds the agent back from merging is a deny entry in the agent host's
settings, which its documentation says is not a security boundary.

**An identity of its own changes both.** The agent's work is recorded under
its name. Its pull requests have an author other than the maintainer, so
the maintainer's approval is a `peer` review in ADR-0022's sense, and
GitHub refuses the merge until it is given.

**An identity is only its own if the agent cannot reach the other one.** An
agent that runs on the maintainer's machine, with the maintainer's `gh`
session readable, has two identities and picks one. Keeping its credentials
apart is part of the answer, not a detail of it.

**Not concerned:** repositories with several maintainers, ownership
(`CODEOWNERS`) and the assignment of reviewers. Where the review happens
stays ADR-0022's question; this ADR decides who the agent is when it
proposes.

## Decision

**What governance recommends, and why.**

| Key              | Recommended value | Reason                                                                                                                                                                         |
| ---------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `agent.identity` | `maintainer`      | for one person, a second identity, a token kept apart and an approval on every agent pull request cost more to set up and keep than the deny entries ADR-0022 already asks for |

`own` is the stronger answer. It is worth its setup when **the history must
tell the agent from the person** (an audit, a repository others depend on),
or when **the person's review must be an approval GitHub enforces** rather
than a merge the agent host holds the agent back from. Rule `own` for
either reason, and say which.

**What governance fixes when you rule `own`:**

1. **The agent acts under its own GitHub identity**, a GitHub App or a
   machine account. Its commits, pushes, pull requests and comments are
   recorded under it. The identity gets the **write** role on the
   repository, not admin.
2. **Its credentials are kept apart from the maintainer's.** The session
   that runs the agent reaches the agent's token, and not the maintainer's
   `gh` session or SSH key. The token is a secret, stored as
   [ADR-0015](ADR-0015-secrets.md) says secret values are.
3. **ADR-0022 is ruled `review.by: peer`, with `review.approvals: 1`.**
   The maintainer reviews by approving the agent's latest push, and the
   agent merges once GitHub accepts the merge, as ADR-0022 allows under
   `peer`. The agent still never approves, under any account.
4. **A `Co-Authored-By` trailer labels a commit, and is not an identity.**
   It is written by whoever commits, and GitHub enforces nothing on it.

**The ruleset is ADR-0022's `peer` ruleset, with one more bypass actor.**
Under `peer`, the maintainer's own pull requests, written without the
agent, would wait for an approval nobody can give. Add the **repository
admin role** to the bypass list, beside Dependabot, in the mode **"For
pull requests only"**. The maintainer is the only admin: their pull
requests merge, and direct pushes to the default branch stay refused for
everyone. The agent's identity is not a bypass actor, so its pull requests
still wait for the approval.

**What the bypass costs.** It also lets the maintainer merge the agent's
pull request without approving it, exactly as under `maintainer`. GitHub
holds the agent to waiting for a review; it cannot hold the maintainer to
giving one.

**`own` with `review.by: maintainer`** is possible: the agent is recorded
apart, the ruleset keeps zero approvals, and the agent's write role lets
GitHub accept its merge, so the deny entry on `gh pr merge` is again the
only thing that holds it back. It buys attribution, not enforcement.

**A GitHub App or a machine account.**

|          | GitHub App                                                                                                                      | Machine account                                                                                                     |
| -------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Shows as | `your-app[bot]`                                                                                                                 | a user of its own                                                                                                   |
| Token    | an installation token that expires after one hour, minted from the App's private key; a local session needs a helper to mint it | a fine-grained personal access token, long-lived, scoped to the repository                                          |
| Commits  | shown as verified when made through the API without a custom author; a local `git push` is unsigned unless the agent signs      | unsigned unless the account signs                                                                                   |
| Terms    | none beyond creating the App                                                                                                    | one free machine account in addition to your personal account; a person who accepts the terms is responsible for it |
| Setup    | create the App, install it on the repository, keep its private key                                                              | create the account, its 2FA, invite it with the write role, keep its token                                          |

Either satisfies the four rules. The machine account is simpler to run from
a local session; the App leaves no long-lived token behind.

**With `claude-code`** in [ADR-0017](ADR-0017-agent-tooling.md)'s
`agent.hosts`, the sandbox keeps the maintainer's credential files out of the agent's
shell commands, and permission rules keep them out of its Read tool. Both
are needed: a `sandbox.filesystem.denyRead` entry does not stop the Read
tool, and a `Read(...)` deny rule is merged into the sandbox. In
`.claude/settings.json`, beside the denies ADR-0022 asks for:

```json
{
  "permissions": {
    "deny": ["Read(~/.config/gh/**)", "Read(~/.ssh/**)"]
  }
}
```

This reaches files only. If `gh` keeps the maintainer's token in the
system keyring, as it does by default on macOS, a file rule does not reach
it: run the agent where the maintainer's credentials do not exist (a
container, another OS user, a cloud session), and hand it the agent's
token, for example as `GH_TOKEN`.

**With `opencode`** in `agent.hosts`, shell commands run without a
sandbox: a permission rule can keep a path out of its read tool, but a
shell command still reads the file. Run the agent where the maintainer's credentials do not exist,
as above, and hand it the agent's token.

**With `copilot`** in `agent.hosts`, Copilot CLI does not read the
`permissions` above, and governance has not verified a sandbox for it. Run
the agent where the maintainer's credentials do not exist, as above, and
hand it the agent's token.

**Ruling: the recommendation, adopted as is.** The agent already commits
and opens pull requests under the maintainer's account, credited with a
`Co-Authored-By` trailer, which fits ADR-0022's `review.by: maintainer`.

## Consequences

### Positive

- An agent knows which credentials it is meant to use.
- With `own`, the history tells the agent's work from the maintainer's.
- With `own`, GitHub refuses the agent's merge until the maintainer has
  approved its latest push, whatever the agent host allows.

### Negative

- `own` costs a second identity, a token kept apart, and an approval on
  every agent pull request.
- The bypass lets the maintainer merge the agent's work unapproved, as
  under `maintainer`.

### Neutral

- With `maintainer`, nothing changes: ADR-0022's `maintainer` ruling, its
  denies and its ruleset stay the whole rule.

## Alternatives Considered

### `maintainer`

The agent acts under the maintainer's name. No setup, and no way to tell
its work apart afterwards; the deny entries protect against a mistake, not
a workaround. The recommendation for one person, for the cost reason above.

### The agent approves the maintainer's pull requests

Instead of a bypass, the agent's identity gives the approval the
maintainer's own pull requests need. ADR-0022 forbids it: the agent never
approves, under any account, and an agent's approval would make its advice
the gate.

### Every change goes through the agent

No bypass: the maintainer never opens a pull request themselves. A rule
the maintainer breaks the first time they fix a typo.

### A `Co-Authored-By` trailer alone

Free, and already common. It labels commits, enforces nothing, and does
not reach merges, pushes or comments.

### `CODEOWNERS` with a required code owner review

Routes each path to its owner, and can require that owner's approval. While
the maintainer is the only account that approves, it names the same person
the approval already comes from. It belongs to a repository with several
maintainers, as ADR-0022 says.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0015](ADR-0015-secrets.md): where the agent's token is stored.
- [ADR-0017](ADR-0017-agent-tooling.md): `agent.hosts`, which decides how the credentials are kept apart.
- [ADR-0018](ADR-0018-dependencies.md): Dependabot, the other bypass actor under `peer`.
- [ADR-0022](ADR-0022-review-and-merge.md): where the review happens, which `own` lets be an approval.
- GitHub: [approving a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/approving-a-pull-request-with-required-reviews), [creating rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository), [rules API](https://docs.github.com/en/rest/repos/rules), [installation tokens](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app), [commit signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification), [terms of service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service). Claude Code: [sandboxing](https://code.claude.com/docs/en/sandboxing), [settings](https://code.claude.com/docs/en/settings-reference). Read on 2026-11-15.

**The key.**

| Key              | What it holds                                                                 | Allowed values                                        |
| ---------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------- |
| `agent.identity` | under whose GitHub identity the agent commits, pushes and opens pull requests | `maintainer`, `own` (then ADR-0022 `review.by: peer`) |

**An empty key is not an answer.** The value is written in this file and
nowhere else; whoever needs it links here. See ADR-0001 for the check
command.
