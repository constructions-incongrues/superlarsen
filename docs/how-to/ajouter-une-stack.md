---
title: Ajouter une stack ou un service web
description: Déclarer une nouvelle application, l'exposer et la sauvegarder.
---

Ce guide ajoute une application, l'expose sur un sous-domaine et l'inscrit aux sauvegardes.

## Avant de commencer

- Le sous-domaine voulu, par exemple `outil.superlarsen.fr`.
- L'image publiée de l'application, avec un tag fixe.

## 1. Écrire la stack

Créez `stacks/<nom>/compose.yaml`. Gardez la première ligne de schéma des autres stacks, et épinglez l'image.

Pour exposer un service web, ajoutez-le au réseau `caddy` avec les labels Caddy :

```yaml
services:
  app:
    image: editeur/outil:1.2.3@sha256:…
    networks: [caddy, default]
    labels:
      caddy: outil.superlarsen.fr
      caddy.reverse_proxy: "{{upstreams 8080}}"
      stack-back.volumes: true

networks:
  caddy:
    external: true
```

Pour envoyer des e-mails, ajoutez aussi le réseau externe `smtp`.

## 2. L'inscrire aux sauvegardes

Ajoutez le service `backup` en reprenant celui d'une autre stack (`ghcr.io/lawndoc/stack-back`). Marquez ensuite ce qu'il faut sauvegarder :

- `stack-back.volumes: true` sur un service dont les volumes doivent être sauvegardés ;
- `stack-back.mysql: true` ou `stack-back.postgres: true` sur un service de base, pour un dump.

Les données persistantes vont sous `/mnt/superlarsen/<nom>/`.

## 3. Déclarer la stack dans Cartons

Ajoutez un bloc `[[stack]]` à `infrastructure/resources.toml`, sur le modèle des autres : `run_directory = "stacks/<nom>"`, l'étiquette `superlarsen`, et l'environnement, dont les secrets s'écrivent `[[NOM]]`. Créez ensuite les valeurs de ces secrets dans Cartons.

## 4. Créer l'entrée DNS

Ajoutez le sous-domaine à `cname_records` dans `infrastructure/terraform/cloudflare.tf`, puis appliquez-le : voir [appliquer un changement Terraform](appliquer-terraform.md).

## 5. Merger et vérifier

Ouvrez la PR et suivez [modifier une stack](modifier-une-stack.md), étapes 2 à 4. Ajoutez la stack à [la référence des stacks](../reference/stacks.md) dans la même PR.
