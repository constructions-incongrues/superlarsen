# 5. Automatiser l'antenne avec LibreTime

Date : 2025-08

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

Diffuser 24 heures sur 24 avec des bénévoles demande un logiciel qui tient
l'antenne quand personne n'est au studio : il enchaîne les émissions
enregistrées, les playlists et les jingles selon une grille, et laisse la
place au direct quand un animateur se connecte.

Les options courantes :

1. **Un ordinateur au studio** avec un logiciel de lecture et une playlist.
   Simple au début, mais tout s'arrête quand l'ordinateur s'éteint.
2. **Un service payant en ligne** (par exemple Radioking) : grille, flux et
   statistiques fournis, avec un abonnement mensuel.
3. **Un logiciel libre sur un serveur** : [LibreTime](https://libretime.org)
   ou [AzuraCast](https://www.azuracast.com). Gratuit, mais il faut un serveur
   et quelqu'un pour le maintenir.

## Décision

Notre antenne est automatisée par LibreTime 4.5.0, sur
`https://libretime.superlarsen.fr`.

- La stack est dans
  [`stacks/libretime/compose.yaml`](../../stacks/libretime/compose.yaml) : les
  services de LibreTime, une base PostgreSQL 15, une file de messages RabbitMQ
  3.13, et le serveur de flux Icecast (voir l'[ADR-0002](0002-flux-en-direct.md)).
- La version est fixée dans
  [`infrastructure/resources.toml`](../../infrastructure/resources.toml)
  (`LIBRETIME_VERSION=4.5.0`).
- Avant chaque déploiement, une étape prépare la configuration et met à jour
  la base de données.
- Les fichiers audio sont dans `/mnt/superlarsen/libretime/storage`, sur le
  volume du serveur.

Pourquoi LibreTime plutôt qu'AzuraCast _(à confirmer)_ : LibreTime est pensé
pour une radio à grille, avec des créneaux d'émissions et des animateurs, plus
que pour un flux musical continu.

## Conséquences

### Ce que nous gagnons

- Une antenne qui tourne sans personne au studio, sans abonnement.
- Des comptes pour les animateurs, qui gèrent leurs propres créneaux.

### Ce que nous devons tenir

- C'est notre stack la plus lourde : six services LibreTime, une base et une
  file de messages. Une mise à jour demande de suivre les notes de version.
- La préparation avant déploiement est un point fragile : si elle échoue,
  l'antenne ne redémarre pas.

### Pour une autre radio

Si vous diffusez par créneaux, vous n'avez pas besoin d'automatisation :
un direct vers votre serveur de flux suffit. Si vous voulez passer en continu
sans serveur, un service payant est le plus court chemin. LibreTime ou
AzuraCast se justifient quand vous avez déjà un serveur et une personne pour
s'en occuper.
