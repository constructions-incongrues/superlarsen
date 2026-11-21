## Context

Aujourd'hui, `main` a une protection de branche classique. Elle exige 1 approbation et l'approbation du dernier push, avec `strict: true`, le check requis `trunk check` et un historique linéaire. trivoallan est en contournement et `enforce_admins` est à `false`. En pratique, toutes les PR sont mergées par leur auteur avec `--admin`. Cartons/Komodo pousse aussi ses `[Komodo] Commit Sync` sur `main` avec le compte trivoallan (`git_account = "trivoallan"`, `managed = true`), dont le dernier date du 2026-03-29.

ADRs en vigueur qui contraignent ce design :

- ADR-0009 : `merge: squash`, `model: github-flow`.
- ADR-0011 : `forge.gate: blocking`, `forge.audit: zizmor`. Les actions sont épinglées par SHA et les permissions limitées.
- ADR-0012 : chaque merge sur `main` part en production par Cartons, sans staging.
- ADR-0018 : `automerge: patch` pour Dependabot, par un workflow et jamais par l'agent.
- ADR-0022 : `review.by: maintainer`, `review.approvals: 0`, une liste de contournement vide, et un agent qui ne merge pas.

Le dépôt appartient à une organisation et il est public : la merge queue est disponible.

## Goals / Non-Goals

**Goals:**

- Un ruleset qui dise vrai (ADR-0022) et qui ne laisse personne contourner les checks.
- Ne plus rebaser à la main chaque PR ouverte après chaque merge.
- Que `main` n'ait qu'un seul écrivain, la merge queue.

**Non-Goals:**

- Grouper plusieurs PR dans un même merge : chaque PR reste un déploiement distinct (ADR-0012).
- Changer qui relit. La revue reste le merge du mainteneur.
- Les checks requis par Dependabot et l'automerge eux-mêmes, qui relèvent des issues #32 et #33.

## Decisions

### Un ruleset versionné, appliqué par `gh api`

La définition du ruleset vit dans `.github/rulesets/main.json`, et c'est `gh api` qui l'applique (`POST`, puis `PUT` sur `repos/{owner}/{repo}/rulesets/{id}`). Ainsi, le réglage se relit dans une PR au lieu de vivre seulement dans l'interface de GitHub.
Alternative : le régler dans l'interface. C'est plus simple, mais ça ne laisse aucune trace dans le dépôt, ce qui est le défaut qu'on a justement constaté sur la protection actuelle.

### Les règles du ruleset

- `pull_request` : 0 approbation, `required_review_thread_resolution: true`, méthode de merge autorisée `squash` uniquement.
- `required_status_checks` : `trunk check` et `zizmor`, attribués à GitHub Actions. `strict_required_status_checks_policy: false`, car la file teste déjà sur le `main` du moment.
- `merge_queue` : `merge_method: SQUASH`, `grouping_strategy: ALLGREEN`, `max_entries_to_build: 1`, `min_entries_to_merge: 1`, `max_entries_to_merge: 1`, `check_response_timeout_minutes: 30`.
- `non_fast_forward`, `deletion`, `required_linear_history`.
- `bypass_actors: []`.
- La protection de branche classique est supprimée une fois le ruleset actif. Sinon, les deux s'appliqueraient ensemble.

Alternative écartée : des groupes de plusieurs PR. Ce serait plus rapide un jour de rafale, mais un groupe qui échoue ne dit pas quelle PR est en cause, et il déploierait plusieurs changements d'un coup.

### `merge_group` dans les workflows requis

`lint.yml` et `audit.yml` ajoutent `merge_group:` à leur `on:`. trunk-action tourne alors sur le commit de groupe. zizmor audite les workflows du groupe. Sur `merge_group`, trunk-action v2.0.0 choisit le mode `none` et n'analyse rien, ce qui donnerait un check vert sans rien vérifier. `lint.yml` le force donc en mode `push` (`check-mode`) et lui passe `merge_group.base_sha` et `merge_group.head_sha`. Son `push.sh` reconnaît les branches `gh-readonly-queue/*` et prend `HEAD^1` comme référence. Les permissions restent les mêmes. Les ADR propres au dépôt vivent dans `docs/adr/local/`, là où `ontrack apply` les range. Le groupe `concurrency` utilise `github.ref` pour `merge_group`, puisque `github.head_ref` y est vide.

### Les apps ne sont pas requises

GitGuardian et l'app Trunk Check continuent de commenter les PR, mais elles ne sont pas requises. Rien ne garantit qu'elles répondent sur `merge_group` : si elles étaient requises, la file attendrait jusqu'à l'expiration du délai.

### Le dépôt, seule source de Cartons

`managed = false` sur le `resource_sync`. Une modification faite dans l'interface de Cartons n'est plus réécrite dans le dépôt : la synchronisation suivante l'écrase. Cela supprime le seul écrivain de `main` qui n'était pas une PR, sans donner de contournement à Komodo.
Alternative écartée : Komodo en contournement. Il faudrait un compte ou une app propre à Komodo, puisqu'il pousse aujourd'hui avec le compte du mainteneur. Ce serait aussi un écart à ADR-0022, pour un usage qui date de mars 2026.

### Les refus de l'agent

`.claude/settings.json` ajoute `permissions.deny: ["Bash(gh pr merge:*)", "Bash(gh pr review:*)"]`. Ce refus couvre aussi `gh pr merge --auto`. L'automerge Dependabot d'ADR-0018 tourne dans un workflow, que ce refus ne touche pas.

## Risks / Trade-offs

- [Un check requis ne tourne pas sur `merge_group`, et la file se bloque] → les deux workflows sont modifiés dans ce même change. On vérifie avec une PR de test mise en file avant de supprimer l'ancienne protection.
- [Le mainteneur perd `--admin` en cas d'urgence] → un incident de production se corrige par une PR passée en file. Si GitHub Actions est en panne, désactiver temporairement le ruleset reste possible : c'est un acte d'administrateur visible dans le journal d'audit.
- [Un changement fait dans l'interface de Cartons est perdu à la synchronisation suivante] → c'est voulu. AGENTS.md dit que toute modification passe par le dépôt.
- [`zizmor` est requis alors que `audit.yml` n'est pas encore sur `main`] → #47 est mergée avant ce change.
- [Le check ontrack d'ADR-0022 ne lit pas le ruleset hors CI] → il n'est vérifié qu'à la main, par `gh api`, à la fin du change.
