# 11. Sauvegarder chaque nuit, hors du serveur, avec restic

Date : 2025-11

Les mots techniques sont expliqués dans le [sommaire](README.md#mots-techniques).

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.
Aucune restauration n'a été testée (voir « Ce que nous ne savons pas »).

## Contexte

Ce qui ne se régénère pas, ce sont les données : les émissions, les podcasts,
les articles du site, le wiki, et les bases qui les décrivent. Le code et la
configuration sont dans ce dépôt, mais un disque qui meurt emporte tout le
reste.

Une sauvegarde utile répond à trois questions : **quoi** (quelles données),
**où** (hors du serveur, sinon elle meurt avec lui) et **combien de temps**
(pour retrouver un fichier effacé il y a un mois).

## Décision

Chaque stack qui garde des données a un service `backup`
([stack-back](https://github.com/lawndoc/stack-back) v1.4.5, qui utilise
[restic](https://restic.net)) : Castopod, LibreTime, WordPress et BookStack.

- **Quoi** : toutes les bases de données, et les fichiers de Castopod, de
  WordPress et de BookStack. Les fichiers de l'antenne LibreTime n'en font
  probablement pas partie (voir « Ce que nous ne savons pas »).
- **Quand** : chaque nuit à 1 h (`CRON_SCHEDULE="0 1 * * *"` dans
  [`infrastructure/resources.toml`](../../infrastructure/resources.toml)).
- **Combien de temps** : 7 sauvegardes quotidiennes, 4 hebdomadaires, 12
  mensuelles et 3 annuelles.
- **Où** : un dépôt restic hors du serveur, chiffré par un mot de passe. Un
  bucket R2 `superlarsen-backups` est déclaré pour cela dans
  [Terraform](../../infrastructure/terraform/cloudflare.tf).
- **Qui est prévenu** : un rapport part par mail, à une seule personne.

## Ce que nous ne savons pas

- **Si les fichiers de l'antenne sont sauvegardés.** Les émissions et la
  musique de LibreTime (`/mnt/superlarsen/libretime/storage`) ne semblent
  pas l'être : aucun des services qui les utilisent ne porte l'étiquette de
  sauvegarde dans
  [`stacks/libretime/compose.yaml`](../../stacks/libretime/compose.yaml), et
  l'un d'eux l'exclut explicitement _(à vérifier)_.
- **Si une restauration marche.** Aucune n'a été testée. Une sauvegarde
  jamais restaurée n'est qu'une hypothèse.
- L'adresse exacte du dépôt restic : elle est injectée au déploiement et
  n'apparaît pas dans ce dépôt.
- Où est gardé le mot de passe de chiffrement. Sans lui, les sauvegardes sont
  illisibles, y compris pour nous.

## Conséquences

### Ce que nous gagnons

- Pour ce qui est sauvegardé, une perte de serveur coûte au plus une journée
  de données, si la restauration marche.
- Un fichier effacé peut se retrouver jusqu'à trois ans en arrière.

### Ce que nous devons tenir

- Un test de restauration au moins une fois par an, écrit dans le wiki (voir
  l'[ADR-0009](0009-documentation-des-benevoles.md)).
- Le mot de passe de chiffrement, connu d'au moins deux personnes (voir
  l'[ADR-0010](0010-comptes-et-acces.md)).
- Le rapport par mail : s'il n'arrive plus, il faut que quelqu'un s'en rende
  compte.

### Pour une autre radio

Sans serveur, la règle reste la même : trois copies, sur deux supports, dont
une hors de vos locaux. Un disque externe au studio et un stockage en ligne
pour les fichiers audio, c'est déjà une vraie sauvegarde.
