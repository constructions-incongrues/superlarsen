---
adr: ADR-0022
slug: review-and-merge
title: Review and merge
status: accepted
revision: 3
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0022
traits:
  review:
    by: maintainer
    approvals: 0
---

# Review and merge

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

A coding agent branches, commits and opens the pull request
([ADR-0009](ADR-0009-branching.md)). While these keys are empty, it does
not know **whether it may approve a pull request, or merge one** once the
checks are green. It either waits without saying so, or merges what nobody
read.

**An agent's act cannot be told apart afterwards.** The agent works with a
person's `gh` session or token, so GitHub records its merge, and its
approval, under that person's name. The history shows a merge or an
approval, never who decided it. The rule can only be enforced **before**
the act, not audited after it, unless the agent acts under an identity of
its own ([ADR-0026](ADR-0026-agent-identity.md)).

**Where the review happens depends on who else can approve.** GitHub does
not let the author of a pull request approve it. In a repository kept by
one person, no approval is possible, so the moment that person reads the
diff and merges it is the review. Once another account can approve, the
review moves to that approval, and the merge can follow from it.

Two ADRs already settle a case: [ADR-0018](ADR-0018-dependencies.md) lets
some updates merge without a person, and
[ADR-0019](ADR-0019-vulnerabilities.md) has a person approve or merge
every vulnerability ignore rule. This ADR states the rule they are cases
of.

**Not concerned:** who owns which path (`CODEOWNERS`). It routes a review;
it does not change what the agent may do.

## Decision

**What governance recommends, and why.**

| Key                | Recommended value                      | Reason                                                                                                                                                                          |
| ------------------ | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `review.by`        | `maintainer`                           | a person reads every change before it lands, and in a repository kept by one person, their merge is the only review GitHub allows. Rule `peer` once another account can approve |
| `review.approvals` | `0` with `maintainer`, `1` with `peer` | the number of approvals the ruleset requires, written where an agent and the check can read it                                                                                  |

`review.by` says where the review a person does happens:

- `maintainer`: the merge of the one person who keeps the repository;
- `peer`: the approval of the latest push by an account other than the one
  that opened the pull request;
- `agent`: nowhere. Acceptable for a repository nobody depends on, such as
  a demo or a throwaway, and justified here when you rule it.

`review.approvals` follows from it: `0` with `maintainer` and `agent`,
because a maintainer cannot approve their own pull request and the agent
never approves; `1` or more with `peer`. The number is your own choice,
and it changes nothing the agent does.

**What governance fixes, whatever you rule:**

1. **The agent opens the pull request ready for review, says when its
   checks are green, and never approves a pull request**, its own or
   another's, under any account. Not as a draft: a draft adds a click and
   no review.
2. **With `maintainer`, the agent merges nothing.** Not with
   `gh pr merge`, not by enabling auto-merge (`--auto`), not through the
   API, not by pushing to the default branch.
3. **With `peer`, the agent may merge once GitHub accepts the merge**, and
   never by working around the ruleset. The ruleset below refuses the
   merge until another account approved the latest push.
4. **With `agent`, the agent merges once the checks are green.**
5. **A bot that a workflow runs under another ADR's ruling is not an
   agent session.** ADR-0018's automerge is that exception: Dependabot's
   pull request is merged by a workflow the repository ruled, not by the
   agent.
6. **A review the agent runs is advice.** It can find faults and fix them.
   It never stands in for the person's merge or approval.

**On GitHub, a ruleset backs the rule.** On the default branch:

| `review.by`  | Ruleset                                                                                                                                                     |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `maintainer` | require a pull request before merging, with zero approvals                                                                                                  |
| `peer`       | require a pull request with `review.approvals` approvals, dismiss stale approvals when new commits are pushed, and require approval of the most recent push |
| `agent`      | require a pull request before merging, with zero approvals                                                                                                  |

Leave the bypass list empty, except Dependabot under `peer`, which
ADR-0018 names, and, with [ADR-0026](ADR-0026-agent-identity.md)'s
`agent.identity: own`, the repository admin role, for pull requests only. Pushing to the default branch then fails for everyone, the
agent included. The approval of the most recent push is what makes `peer`
safe: an agent that pushes a fix after the approval needs a new one.

**What `maintainer` leaves, beside each value of
[ADR-0011](ADR-0011-forge-and-ci.md)'s `forge.gate`.** With `none`, no
control but the maintainer's reading. With `blocking`, the pipeline and
that reading. With `informative`, the pipeline reports and the maintainer
alone decides what to do with a red.

**Each agent host denies what the agent may not do**, in its committed
settings, for every host in [ADR-0017](ADR-0017-agent-tooling.md)'s
`agent.hosts`.

With `claude-code`, `.claude/settings.json`. With `maintainer`:

```json
{
  "permissions": {
    "deny": ["Bash(gh pr merge:*)", "Bash(gh pr review:*)"]
  }
}
```

With `peer`, only `"Bash(gh pr review:*)"`: denying the merge would block
the merge rule 3 allows. The agent comments on its own pull request with
`gh pr comment`, which the deny leaves open.

With `opencode`, `opencode.json`. opencode applies the last rule that
matches, so the denies go **last** in `permissions`, after any broader
`allow`. With `maintainer`:

```json
{
  "permissions": [
    { "action": "shell", "resource": "gh pr review *", "effect": "deny" },
    { "action": "shell", "resource": "gh pr merge *", "effect": "deny" }
  ]
}
```

With `peer`, only the `gh pr review *` rule.

With `copilot`, `.claude/settings.json` again, but Copilot CLI ignores
`permissions`, so the `claude-code` denies do not hold for it. A
`PreToolUse` hook does: Copilot CLI and Claude Code both run it, and both
block the call when it exits `2`. With `maintainer`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "grep -q 'gh pr review' && { echo 'the agent never approves a pull request (ADR-0022)' >&2; exit 2; } || exit 0"
          },
          {
            "type": "command",
            "command": "grep -q 'gh pr merge' && { echo 'a person merges this pull request (ADR-0022)' >&2; exit 2; } || exit 0"
          }
        ]
      }
    ]
  }
}
```

With `peer`, only the `gh pr review` hook. Each hook reads the tool call on
its standard input. With `[claude-code, copilot]`, keep both the denies and
the hooks.

If the GitHub MCP server is installed, deny its review and merge tools as
well, under the names your configuration gives the server (for example
`mcp__github__create_pull_request_review` and
`mcp__github__merge_pull_request`).

**Ruling: the recommendation, adopted as is.** It matches what the
repository does: every pull request is opened and merged by its maintainer,
with no review. At ruling time the branch protection says otherwise (one
approval, approval of the latest push) and is bypassed by the maintainer
at every merge. It is to be replaced by the `maintainer` ruleset (a pull
request, zero approvals, an empty bypass list), and `.claude/settings.json`
is to deny `gh pr merge` and `gh pr review`. Komodo's commit sync, which
pushes to `main` directly, is to go through a pull request or be named
here as a bypass.

## Consequences

### Positive

- An agent at a green pull request knows what to do: say so and stop, or,
  with `peer`, merge once GitHub accepts it.
- No approval in a person's name comes from an agent.
- Nothing reaches the default branch without a person having read it,
  except the updates ADR-0018 lets merge.
- ADR-0018 and ADR-0019 apply one rule instead of two separate ones.

### Negative

- With `maintainer`, every change waits for the maintainer, even a
  trivial one.
- The deny entries protect against a mistake, not against a workaround;
  without the ruleset, the merge rule is an intention.

### Neutral

- The ruleset lives on GitHub, outside the repository. The check reads it
  in CI, but not its bypass list.

## Alternatives Considered

### `review.by: agent`

The agent merges once the checks are green. No wait, and no reader: a
green check is not a review (ADR-0018 says why). Tenable for a repository
nobody installs from or depends on.

### A person merges even under `peer`

The approval and the merge both wait for a person. The second wait proves
nothing the approval of the latest push does not already prove, once the
ruleset requires it.

### Two keys: who reviews, and whether the team is one person or several

`review.by: person | agent` beside `review.team: solo | team`. One
combination, `agent` with `team`, has no effect: the agent never approves,
so it merges with zero approvals in either case. Two keys with a dead
combination carry no more than one key with three values.

### One required approval for a single maintainer

The usual rule for a team. For one maintainer it cannot work: GitHub
refuses the author's own approval, so every merge is blocked or bypassed,
and a rule bypassed on every merge is not a rule. It becomes workable once
the agent has an identity of its own: see
[ADR-0026](ADR-0026-agent-identity.md).

### `CODEOWNERS`

Routes each path to its owners for review. It belongs with `peer`, and it
changes who approves, not what the agent may do.

### Draft pull requests

The agent opens a draft, and the person marks it ready, then merges. The
extra step proves nothing the merge does not already prove.

## References

- Original to governance; no surdesrails SDR asks this question.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [ADR-0009](ADR-0009-branching.md): one change, one branch, one pull request.
- [ADR-0011](ADR-0011-forge-and-ci.md): the required checks a merge waits for.
- [ADR-0017](ADR-0017-agent-tooling.md): `agent.hosts`, which decides what the check reads.
- [ADR-0018](ADR-0018-dependencies.md) and [ADR-0019](ADR-0019-vulnerabilities.md): the two cases this ADR generalises.
- Claude Code: [permissions](https://code.claude.com/docs/en/permissions). opencode: [permissions](https://opencode.ai/docs/permissions/), and its source (`anomalyco/opencode`, branch `dev`: `packages/core/src/permission.ts`, `util/wildcard.ts`, `config.ts`) for the order rules are joined and evaluated in. GitHub: [about rulesets](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets), [available rules](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets), [rules for a branch](https://docs.github.com/en/rest/repos/rules#get-rules-for-a-branch), [approving a pull request](https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/approving-a-pull-request-with-required-reviews). Read on 2026-11-15.

**The keys.**

| Key                | What it holds                                       | Allowed values                                                                                                     |
| ------------------ | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `review.by`        | where the review a person does happens              | `maintainer` (the maintainer's merge), `peer` (another account's approval of the latest push), `agent` (no person) |
| `review.approvals` | the approvals the default branch's ruleset requires | `0` with `maintainer` and `agent`; `1` or more with `peer`                                                         |

**An empty key is not an answer**: both are required. The values are
written in this file and nowhere else; whoever needs them links here. See
ADR-0001 for the check command.

**Revisions.** What changed in the question at each revision, and what
a repository that already ruled must re-answer.

- Revision 2: `review.merge_by` is replaced by `review.by` and `review.approvals`, which also take over ADR-0011's `forge.review`. The agent never approves; with `peer` it may merge once GitHub accepts it. Re-answer both keys and delete `review.merge_by`: `forge.review: author` with `merge_by: person` becomes `maintainer` with `approvals: 0`; `forge.review: peer` becomes `peer` with the approvals your ruleset requires, at least `1`; `merge_by: agent` becomes `agent` with `approvals: 0`. Add the `Bash(gh pr review:*)` deny.
- Revision 3: the denies are required on each host of ADR-0017's `agent.hosts`, and the Decision shows the opencode rules. The keys are unchanged: nothing to re-answer; a repository whose `agent.hosts` holds `opencode` adds the denies to `opencode.json`.
