---
title: Restaurer une stack depuis une sauvegarde
description: Récupérer une base ou des fichiers depuis les sauvegardes Restic de R2.
---

Ce guide restaure une base de données ou des fichiers d'une stack depuis les sauvegardes que `stack-back` envoie chaque nuit sur Cloudflare R2.

## Avant de commencer

- Un accès au terminal du serveur `cartons` (Cartons → **Terminals**), dans le dossier de la stack.
- Le service `backup` de la stack tourne : il porte les identifiants Restic et R2, injectés par Cartons.

## 1. Repérer l'instantané

Listez les instantanés de la stack :

```bash
docker compose exec backup restic snapshots
```

Chaque ligne donne un identifiant, une date et un chemin. Les dumps de base sont sous `/databases/<service>/…`, les fichiers sous `/volumes/<service>/…`. Notez l'identifiant voulu, ou utilisez `latest`.

Pour voir le contenu exact d'un instantané :

```bash
docker compose exec backup restic ls <id>
```

## 2. Restaurer une base de données

Arrêtez d'abord le service qui écrit dans la base, pour qu'aucune écriture n'arrive pendant la restauration :

```bash
docker compose stop wordpress
```

Puis rejouez le dump dans la base (MySQL ou MariaDB), avec l'utilisateur de la stack, en remplaçant le chemin par celui relevé à l'étape 1. Le mot de passe root de WordPress est aléatoire et n'est connu de personne :

```bash
docker compose exec -T backup restic dump <id> /databases/db/all_databases.sql \
  | docker compose exec -T db sh -c 'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

Pour PostgreSQL (LibreTime), rejouez le dump avec `psql -U "$POSTGRES_USER"` dans le service `postgres`.

Relancez ensuite le service :

```bash
docker compose start wordpress
```

:::caution
Après une montée de version de base qui ne se défait pas, comme MySQL 8.0 → 8.4, le dump se rejoue dans **la nouvelle version**. Pour revenir à l'ancienne image, il faut d'abord vider son dossier de données (`/mnt/superlarsen/<stack>/db`), puis rejouer le dump dans l'ancienne version.
:::

## 3. Restaurer des fichiers

Restaurez dans un dossier à part, pour comparer avant d'écraser :

```bash
docker compose run --rm -v /mnt/superlarsen/restauration:/restauration backup \
  restic restore <id> --target /restauration --include /volumes/<service>
```

Les fichiers arrivent dans `/mnt/superlarsen/restauration/volumes/<service>/`. Copiez ceux dont vous avez besoin vers le dossier de la stack, puis supprimez `/mnt/superlarsen/restauration`.

## 4. Vérifier

- Le service répond : voir [les stacks](../reference/stacks.md).
- La sauvegarde de la nuit suivante réussit : son rapport arrive par e-mail.

Voir aussi la [vue d'exécution](../architecture/arc42/06-runtime-view.md) pour le déroulé d'une sauvegarde.
