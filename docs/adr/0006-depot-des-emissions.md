# 6. Les animateurs déposent leurs émissions dans LibreTime

Date : 2025-08

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.
La façon de faire est à confirmer (voir « Ce que nous ne savons pas »).

## Contexte

Une émission enregistrée doit arriver jusqu'à l'antenne : l'animateur la
prépare chez lui, puis quelqu'un doit la mettre au bon créneau. Sans règle
claire, les fichiers circulent par mail, clé USB ou lien de téléchargement, et
une personne finit par tout faire à la main.

Le but : que chaque animateur puisse déposer son émission lui-même, **sans
accès au serveur**.

## Décision

Les animateurs déposent leurs fichiers par l'interface web de LibreTime
(`https://libretime.superlarsen.fr`), avec leur propre compte. LibreTime
analyse chaque fichier (durée, volume, métadonnées) avant qu'on puisse le
programmer.

Le serveur SFTP (`sftp://sftp.superlarsen.fr:2222`) **ne sert pas à cela** :
il ne donne accès qu'aux fichiers du site WordPress (voir
l'[ADR-0003](0003-site-web.md)).

## Ce que nous ne savons pas

- Si c'est bien ainsi que les animateurs font aujourd'hui, ou si une personne
  centralise encore les dépôts.
- Les consignes de format (MP3 ou WAV, volume, nommage des fichiers) : elles
  ne sont écrites nulle part.

## Conséquences

### Ce que nous gagnons

- Chaque animateur est autonome, et le fichier est vérifié par LibreTime avant
  la diffusion.
- Personne n'a besoin d'un accès au serveur pour faire de la radio.

### Ce que nous devons tenir

- Les comptes animateurs : en créer, en fermer quand quelqu'un part.
- Une fiche « déposer son émission », dans notre wiki (voir
  l'[ADR-0009](0009-documentation-des-benevoles.md)).

### Pour une autre radio

Sans logiciel d'automatisation, un dossier partagé (Nextcloud, un drive) avec
une règle de nommage simple (`date-nom-de-l-emission.mp3`) fait le même
travail. Ce qui compte : un seul endroit de dépôt, connu de tous.
