# ADR Review Manifest

## ADR Review Completed

- Date: 2026-11-21
- Reviewer: Tristan Rivoallan
- Change: ruleset-main-merge-queue

## In-Force ADR Context Reviewed

- docs/adr/engineering/ADR-0009-branching.md - squash merges, github-flow: the queue merges in squash
- docs/adr/engineering/ADR-0011-forge-and-ci.md - blocking gate, zizmor, pinned actions: the required checks and their workflows
- docs/adr/engineering/ADR-0012-delivery.md - every merge reaches production: one pull request per group
- docs/adr/engineering/ADR-0018-dependencies.md - patch automerge runs in a workflow, through the queue
- docs/adr/engineering/ADR-0022-review-and-merge.md - zero approvals, empty bypass list, the agent never merges: this change applies it

## Repository-Level ADRs Created

- docs/adr/local/ADR-0001-merge-queue.md - the default branch is merged through a merge queue, with no bypass
- docs/adr/local/ADR-0002-cartons-config-from-repository.md - Cartons applies the repository and never writes to it (`managed = false`)

## Notes

- No governance ADR is superseded; both new ADRs apply engineering/ADR-0022 rather than depart from it.
