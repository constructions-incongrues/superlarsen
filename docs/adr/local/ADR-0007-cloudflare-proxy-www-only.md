---
adr: ADR-0007
slug: cloudflare-proxy-www-only
title: Seul www passe par le proxy Cloudflare
status: proposed
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Seul www passe par le proxy Cloudflare

## Status

Proposed

## Context

La zone `superlarsen.fr` est sur le plan Cloudflare Free. Son proxy refuse les envois de plus de 100 Mo, et ses règles WAF ne lisent pas le corps d'une requête. Castopod et LibreTime reçoivent des fichiers audio plus gros que cela ; Icecast sert un flux continu ; SFTP n'est pas du HTTP.

Le 2026-11-19, une rafale de « mot de passe oublié » sur le site WordPress a envoyé 11 e-mails en 58 secondes.

## Decision

`www` est le seul enregistrement proxifié. Tous les autres sont en DNS seul et arrivent directement sur Caddy.

Pour `www` :

- une règle WAF personnalisée impose un défi à toute requête dont le chemin contient `/wp-login.php` ;
- l'origine répond 403 à toute adresse hors des plages publiées par Cloudflare, par des labels Caddy sur le service `wordpress` ;
- la zone est en mode Full (strict) : Cloudflare vérifie le certificat que Caddy présente.

## Consequences

### Positive

- Un robot qui poste sur `wp-login.php` sans charger le formulaire est arrêté avant WordPress.
- Le site ne peut pas être atteint en contournant le proxy.
- Les gros envois vers Castopod et LibreTime continuent de passer.

### Negative

- Le wiki, Castopod, LibreTime et Icecast n'ont pas de WAF et exposent l'adresse du serveur.
- La liste des plages Cloudflare est recopiée dans `stacks/wordpress/compose.yaml` ; si Cloudflare en ajoute une, les visiteurs qui passent par elle reçoivent un 403 jusqu'à la mise à jour de la liste.
- Le défi couvre tout `wp-login.php`, pas la seule action de mot de passe oublié : le plan Free ne lit pas le corps de la requête, où WordPress la lit aussi.

### Neutral

- Un enregistrement proxifié a un TTL automatique ; les autres gardent 300 secondes.

## Alternatives Considered

### Proxifier tous les enregistrements HTTP

Casse les envois de plus de 100 Mo vers Castopod et LibreTime.

### Un plan Cloudflare payant

Lève la limite d'envoi et permet de lire le corps des requêtes, pour un coût récurrent et une seule règle.

### Limiter le débit dans WordPress

Une extension à ajouter et à entretenir dans une image que ce dépôt ne construit pas, et la requête atteint quand même le serveur.

## References

- ADR-0004, ADR-0006.
- `infrastructure/terraform/cloudflare.tf` ; arc42, sections 2, 7 et 10.
