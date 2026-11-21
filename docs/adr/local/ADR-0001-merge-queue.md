---
adr: ADR-0001
slug: merge-queue
title: Une merge queue sur la branche par défaut
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Une merge queue sur la branche par défaut

## Status

Accepted

## Context

`main` exigeait que chaque branche soit à jour avant le merge (`strict: true`). Un jour où plusieurs PR étaient en cours (sept merges le 2026-11-21), chaque merge obligeait à rebaser toutes les autres PR ouvertes et à relancer leur CI. Une PR a même été fermée quand la branche sur laquelle elle reposait a été supprimée. Chaque merge atteint la production par Cartons (engineering/ADR-0012) : un résultat de merge qu'aucun check n'a vu est donc un risque pour la production. engineering/ADR-0022 demande par ailleurs un ruleset à zéro approbation et à liste de contournement vide, que cette décision met en place.

## Decision

La branche par défaut est protégée par un ruleset, versionné dans `.github/rulesets/main.json`, avec une merge queue :

- des merges en squash seulement (engineering/ADR-0009), une PR par groupe ;
- les checks requis `trunk check` et `zizmor`, dont les workflows se déclenchent sur `pull_request` et sur `merge_group` ; les checks des apps GitHub ne sont jamais requis ;
- pas d'exigence stricte de branche à jour, puisque la file teste sur le `main` courant ;
- une liste de contournement vide : personne ne merge hors de la file, le mainteneur compris.

Mettre une PR dans la file, c'est merger : selon engineering/ADR-0022, seul le mainteneur le fait, jamais l'agent.

## Consequences

### Positive

- Plus de rebase manuel après chaque merge : la file teste chaque PR sur le `main` où elle va atterrir.
- Chaque commit de `main` a été vérifié tel qu'il est.
- Un merge reste un déploiement, comme avant.

### Negative

- Chaque workflow requis doit aussi se déclencher sur `merge_group`, sans quoi la file attend jusqu'à expiration.
- Pas de contournement d'urgence : un correctif urgent passe par la file comme tout changement.

### Neutral

- La file ajoute une courte attente après le clic de merge, le temps que les checks tournent une fois de plus.

## Alternatives Considered

### Garder l'exigence stricte de branche à jour

Aucun mécanisme nouveau, mais la cascade de rebases revient à chaque journée chargée.

### Lever l'exigence stricte, sans file

Le moins coûteux, mais deux PR vertes séparément peuvent casser `main` ensemble, et rien ne le verrait avant la production.

### Des groupes de plusieurs PR

Plus rapide les jours chargés, mais un groupe en échec ne dit pas quelle PR l'a cassé, et il déploie plusieurs changements d'un coup.

## References

- engineering/ADR-0009, ADR-0011, ADR-0012, ADR-0022.
- Changement OpenSpec `ruleset-main-merge-queue` ; issue constructions-incongrues/superlarsen#36.
