# 2. Diffuser notre flux en direct avec notre propre serveur Icecast

Date : 2025-08

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

Pour être écoutée en ligne, une radio a besoin d'un serveur de flux : un
programme qui reçoit le son de l'antenne et le renvoie à chaque auditeur, dans
un navigateur, une application ou un lecteur réseau. Son adresse finit dans
les annuaires de radios, sur le site et dans les applications : elle doit
rester stable.

Deux façons de faire :

1. **Un service de diffusion payant** : il fournit le serveur, souvent les
   statistiques d'écoute et un lecteur à intégrer. On paie au nombre
   d'auditeurs simultanés, et l'adresse du flux appartient au prestataire.
2. **Un serveur à soi.** Le logiciel libre de référence est
   [Icecast](https://icecast.org). C'est gratuit, mais il faut un serveur et
   quelqu'un pour le surveiller.

## Décision

Nous diffusons avec notre propre serveur Icecast 2.4.4, à l'adresse
`https://icecast.superlarsen.fr`.

- Il fait partie de la stack LibreTime
  ([`stacks/libretime/compose.yaml`](../../stacks/libretime/compose.yaml)),
  qui l'alimente directement (voir l'[ADR-0005](0005-automatisation-d-antenne.md)).
- Il est publié en HTTPS derrière le même serveur web que nos autres services
  (Caddy, qui gère les certificats tout seul).
- Le lecteur du site peut lire le flux depuis un autre domaine : Icecast 2.4.4
  envoie lui-même l'autorisation nécessaire (CORS), sans réglage de notre part.

## Conséquences

### Ce que nous gagnons

- L'adresse du flux est sur notre domaine : changer de serveur ne change rien
  pour les auditeurs.
- Pas de coût au nombre d'auditeurs.

### Ce que nous devons tenir

- La bande passante sort de notre serveur : un pic d'écoute la consomme.
- Si `cartons` tombe, le flux tombe aussi.
- Les statistiques d'écoute sont celles d'Icecast, c'est-à-dire sommaires.

### Pour une autre radio

Un service payant est un bon choix si vous n'avez pas de serveur. Un conseil
dans ce cas : publiez l'adresse du flux sous **votre** domaine (une
redirection suffit), pour pouvoir changer de prestataire sans perdre vos
auditeurs. Si vous avez déjà un serveur, Icecast est léger et ne demande
presque rien.
