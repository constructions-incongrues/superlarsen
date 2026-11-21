---
title: Décisions d'architecture
sidebar:
  label: À propos
---

Les décisions vivent dans `docs/adr/`, une par fichier, au format d'[ADR-0001](../../adr/engineering/ADR-0001-record-architecture-decisions.md) :

- les [décisions du dépôt](../../adr/local/ADR-0001-merge-queue.md), dans `docs/adr/local/` ;
- les [décisions de gouvernance](../../adr/engineering/ADR-0001-record-architecture-decisions.md), dans `docs/adr/engineering/`.

Cette section ne les recopie pas. Celles qui façonnent l'architecture sont citées, avec le choix qu'elles tranchent, dans la [stratégie de solution](04-solution-strategy.md).

Un ADR accepté ne se réécrit pas : il dit ce qui a été décidé ce jour-là. Quand une liste a grandi depuis, le fichier versionné fait foi. C'est le cas des checks requis : [ADR-0001](../../adr/local/ADR-0001-merge-queue.md) en nomme deux, `.github/rulesets/main.json` en exige quatre.
