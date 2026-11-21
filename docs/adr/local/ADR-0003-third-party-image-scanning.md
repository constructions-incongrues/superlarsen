---
adr: ADR-0003
slug: third-party-image-scanning
title: Les scans de vulnérabilités des images tierces signalent, ils ne bloquent pas
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Les scans de vulnérabilités des images tierces signalent, ils ne bloquent pas

## Status

Accepted

## Context

engineering/ADR-0019 fixe `vulnerabilities.scanner: grype` et `vulnerabilities.fail_on: critical` : une vulnérabilité critique dont un correctif existe fait échouer le check requis. Sa règle 4 dit qu'un agent corrige en mettant à jour la dépendance, par l'outil de mise à jour d'ADR-0018.

Ce dépôt ne construit aucune image (engineering/ADR-0012 : `delivery.target: platform`, `registry: none`). Chaque image de `stacks/*/compose.yaml` est publiée par son projet amont. Le 2026-11-21, grype a trouvé des vulnérabilités critiques corrigeables dans 12 des 18 images, et aussi dans la dernière version de chacune : LibreTime 4.5.0 est sa dernière version, et MySQL 9.7.4, RabbitMQ 4.2.9, Castopod 1.15.7 et stack-back v1.5.4 livrent encore des paquets dont une version corrigée existe. « Corrigeable » veut dire qu'un paquet corrigé existe, pas qu'une image corrigée existe. Le dépôt ne peut pas appliquer le correctif ; seul l'éditeur le peut.

Un check qui échoue sur chaque PR pour une raison qu'aucun changement ici ne peut corriger est un check qu'on finit par désactiver, ce contre quoi ADR-0019 met en garde.

## Decision

Ce dépôt s'écarte d'engineering/ADR-0019 sur `fail_on`, pour les images tierces seulement :

- le workflow `vulnerabilities` lance grype sur chaque image de `stacks/*/compose.yaml`, à chaque PR et chaque semaine, avec `--only-fixed`, et **signale sans échouer** ;
- une vulnérabilité critique se traite en mettant à jour l'image, quand une version qui la corrige existe et a passé le délai d'attente, dans une PR à part ;
- `vulnerabilities.fail_on: critical` reste la règle pour tout ce que ce dépôt construirait ou publierait lui-même.

Aucune règle d'exception n'est écrite : les résultats restent visibles à chaque exécution.

## Consequences

### Positive

- Le scan tourne et se lit, au lieu d'être un check rouge que chacun apprend à ignorer.
- Les montées de version restent des PR délibérées, déployées une par une (engineering/ADR-0012).

### Negative

- Rien n'arrête un merge alors qu'une image en service porte une vulnérabilité critique ; une personne doit lire le rapport.

### Neutral

- Si le dépôt se met à construire ses propres images, le seuil bloquant d'ADR-0019 s'y applique tel quel.

## Alternatives Considered

### Garder `fail_on: critical` et mettre à jour chaque image

Essayé le 2026-11-21 : aucune version courante des images touchées ne passe sous le seuil, et le check resterait rouge.

### Garder `fail_on: critical` avec une règle d'exception par résultat

Plus de cent entrées, chacune disant « l'éditeur n'a pas livré le correctif », à renouveler à chaque version : « l'interrupteur éteint » de la règle 5 d'ADR-0019, écrit une ligne à la fois.

## References

- engineering/ADR-0012, ADR-0018, ADR-0019.
- Issue constructions-incongrues/superlarsen#34.
