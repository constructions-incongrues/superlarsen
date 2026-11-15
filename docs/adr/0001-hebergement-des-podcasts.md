# 1. Héberger nos podcasts nous-mêmes, avec Castopod

Date : 2025-08

Les mots techniques sont expliqués dans le [sommaire](README.md#mots-techniques).

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

Une radio associative produit des émissions qui doivent rester écoutables
après leur diffusion : en replay, en podcast, dans les applications. La
question se pose dès la première émission enregistrée : **où vivent les
fichiers, et qui tient le flux RSS ?**

Il y a trois réponses possibles :

1. **Une plateforme gratuite**, comme un audioblog éditorial ou un service
   gratuit d'hébergement de podcasts. Il n'y a rien à maintenir, et la
   plateforme fait parfois office de vitrine. En échange, l'archive et le
   flux restent chez elle : si elle ferme, change ses conditions ou supprime
   un compte, la radio perd ses épisodes, ses abonnés et ses liens.
2. **Un hébergeur payant.** On ne maintient rien non plus, l'archive est
   exportable et le flux souvent redirigeable. C'est un abonnement annuel,
   sur un budget associatif.
3. **L'auto-hébergement.** La radio garde l'archive et le flux. En échange,
   elle doit faire les mises à jour, les sauvegardes et la surveillance, et
   le savoir-faire repose sur une ou deux personnes.

Quand cette décision a été prise, Super Larsen avait déjà un serveur
(`cartons`, chez Hetzner) qui hébergeait le site WordPress et LibreTime,
déployés depuis ce dépôt. Un service de plus sur ce serveur ne coûtait
presque rien de plus.

## Décision

Nous hébergeons nos podcasts nous-mêmes avec
[Castopod](https://castopod.org), sur `https://castopod.superlarsen.fr`.

- La stack est dans [`stacks/castopod/`](../../stacks/castopod/compose.yaml) :
  Castopod, MariaDB et Redis, sur le même serveur que le reste.
- Les fichiers audio sont dans `/mnt/superlarsen/castopod/media`, sur le
  volume Hetzner géré par Terraform.
- Le flux RSS de Castopod est **la seule source**. Spotify, Deezer et
  Podcast Index le lisent, et nous ne téléversons rien à la main sur chaque
  plateforme.

Ce qui nous a fait choisir Castopod plutôt qu'un autre outil auto-hébergé
_(à confirmer)_ : c'est un logiciel libre fait pour le podcast, il produit un
flux RSS standard, publie aussi sur le fédivers (ActivityPub), et tourne dans
un conteneur Docker comme nos autres services.

## Ce que nous ne savons pas

- L'endroit exact où partent les sauvegardes : l'adresse du dépôt restic
  (`RESTIC_REPOSITORY`) est injectée au déploiement par Cartons et n'apparaît
  pas dans ce dépôt. Le bucket R2 `superlarsen-backups` déclaré dans
  [Terraform](../../infrastructure/terraform/cloudflare.tf) est le candidat
  probable.

## Conséquences

### Ce que nous gagnons

- L'archive nous appartient. Changer d'outil plus tard veut dire exporter des
  fichiers et rediriger un flux, pas reconstruire une audience.
- Une seule mise en ligne par épisode, diffusée partout par le flux.
- Pas d'abonnement : le coût est celui du serveur, qui est déjà payé.

### Ce que nous devons tenir

- **Les sauvegardes sont à nous.** La stack sauvegarde la base et les médias
  chaque nuit avec restic (via stack-back), vers un dépôt hors du serveur. On
  garde 7 sauvegardes quotidiennes, 4 hebdomadaires, 12 mensuelles et 3
  annuelles. Une sauvegarde jamais restaurée n'est qu'une hypothèse : il faut
  tester une restauration au moins une fois par an.
- **Les mises à jour sont à nous.** La version de Castopod est figée dans
  `compose.yaml` (1.15.0 au 2026-03-29). Personne ne la monte à notre place.
- **Un seul serveur.** Si `cartons` tombe, les podcasts tombent avec le site
  et l'antenne.
- **Le savoir-faire tient à peu de monde.** Ce dépôt et cet ADR existent pour
  qu'une autre personne puisse reprendre.

### Pour une autre radio

Notre réponse ne convient pas à tout le monde. Une plateforme gratuite reste
le bon choix si votre radio n'a ni serveur ni personne pour s'en occuper :
les épisodes y sont en ligne dès aujourd'hui, et c'est ce qui compte au
début. Dans ce cas, deux précautions :

- gardez une copie de chaque fichier audio, chez vous ;
- vérifiez que la plateforme permet d'exporter les épisodes et de rediriger
  le flux RSS. C'est ce qui vous permettra de changer d'avis plus tard sans
  perdre vos abonnés.

Passer à l'auto-hébergement se justifie le jour où vous avez déjà un serveur
pour autre chose, ou le jour où perdre l'archive deviendrait grave.
