---
adr: ADR-0004
slug: caddy-labels
title: Les services s'exposent par des labels Caddy
status: accepted
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Les services s'exposent par des labels Caddy

## Status

Accepted

## Context

Le serveur `cartons` fait tourner un seul Caddy pour tous les projets qu'il héberge. Ce Caddy lit les labels Docker et en tire sa propre configuration. Ce dépôt ne le possède pas (arc42, section 2), et une seule personne tient la plateforme : un fichier de proxy à éditer sur le serveur pour chaque nouveau domaine serait une étape hors du dépôt, ce qu'excluent engineering/ADR-0012 et ADR-0002.

Cette décision était en vigueur avant d'être écrite. Cet ADR la constate ; il ne la change pas.

## Decision

Un service web s'expose par deux éléments de son `compose.yaml`, et rien d'autre :

- il rejoint le réseau Docker externe `caddy` ;
- il porte les labels `caddy: <domaine>` et `caddy.reverse_proxy: "{{upstreams <port>}}"`.

Caddy obtient le certificat et route le domaine. Les règles d'accès propres à un service sont des labels elles aussi, comme l'origine de `wordpress` réservée à Cloudflare.

Un service qui n'est pas du HTTP publie un port à la place : `sftp` sur 2222, et les entrées de direct de LibreTime sur 8001 et 8002.

## Consequences

### Positive

- Exposer un service fait partie de la PR qui l'ajoute, et se relit avec elle.
- Aucune configuration de proxy ne vit hors du dépôt.

### Negative

- L'exposition dépend d'un Caddy que ce dépôt ne configure pas et ne versionne pas : un changement sur le serveur peut casser le routage sans aucun changement ici.
- Un port publié contourne Caddy et n'en reçoit pas de TLS. Les entrées de direct de LibreTime sont en clair.
- Entre Caddy et un conteneur, le trafic est du HTTP en clair sur le réseau `caddy`.

### Neutral

- Aucun linter ne vérifie les labels ; une faute de frappe se voit après le déploiement.

## Alternatives Considered

### Un Caddyfile sur le serveur

Un fichier pour tous les domaines, édité à la main : une étape hors du dépôt et hors de la relecture.

### Un reverse proxy dans chaque stack

Chaque stack aurait besoin des ports 80 et 443, qu'un seul serveur ne peut pas donner à cinq stacks.

## References

- ADR-0002 ; engineering/ADR-0003, ADR-0012.
- arc42, sections 4, 7 et 8.
