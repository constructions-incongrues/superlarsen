---
adr: ADR-0005
slug: stack-back-backups
title: Chaque stack se sauvegarde vers R2 avec stack-back
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Chaque stack se sauvegarde vers R2 avec stack-back

## Status

Accepted

## Context

La récupérabilité est le deuxième objectif de qualité de la plateforme (arc42, section 1) : perdre le serveur ne doit pas faire perdre les données. Tout tourne sur un seul serveur ; une sauvegarde doit donc le quitter, et quitter son hébergeur. Une seule personne tient la plateforme : une sauvegarde qui demanderait un script par base ne serait pas entretenue.

Cette décision était en vigueur avant d'être écrite. Cet ADR la constate ; il ne la change pas.

## Decision

Chaque stack qui porte des données inclut un service `backup`, `ghcr.io/lawndoc/stack-back`, qui pilote Restic :

- un service s'inscrit par label : `stack-back.volumes: true` pour ses volumes, `stack-back.mysql`, `stack-back.mariadb` ou `stack-back.postgres` pour un dump de sa base ;
- la sauvegarde tourne chaque jour à 01:00 UTC et part vers Cloudflare R2, hors de Hetzner ;
- la rétention est de 7 instantanés quotidiens, 4 hebdomadaires, 12 mensuels et 3 annuels ;
- un rapport part par e-mail après chaque exécution.

`sftp` ne porte aucune donnée propre et n'a pas de service `backup`.

## Consequences

### Positive

- Au plus 24 heures de données sont perdues.
- Inscrire un service aux sauvegardes tient en un label, dans la PR qui ajoute le service.
- Les sauvegardes survivent à la perte du serveur, de son volume et du compte Hetzner.

### Negative

- Le mot de passe Restic et les clés R2 sont injectés par Cartons, qui tourne sur le serveur sauvegardé. La seule autre copie est dans le trousseau du mainteneur (engineering/ADR-0015) : sans elle, les sauvegardes sont illisibles.
- Une reconstruction complète depuis ces sauvegardes n'a jamais été exercée (arc42, section 11).
- Une sauvegarde en échec n'est connue que par le rapport e-mail, envoyé à un seul destinataire.

### Neutral

- Chaque stack a son propre service `backup` : la même image et les mêmes réglages sont répétés quatre fois.

## Alternatives Considered

### Les instantanés de volume Hetzner

Pas de dump par base, et la copie reste chez l'hébergeur du serveur.

### Une seule tâche de sauvegarde pour tout le serveur

Un seul endroit à configurer, mais il vit sur le serveur, hors du dépôt, et ne sait rien des bases des stacks.

## References

- engineering/ADR-0012, ADR-0015.
- arc42, sections 6, 8, 10 et 11 ; le guide « Restaurer une stack depuis une sauvegarde ».
