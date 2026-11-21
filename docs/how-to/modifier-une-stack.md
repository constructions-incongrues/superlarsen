---
title: Modifier ou mettre à jour une stack
description: Changer une image, une variable ou un service, de la PR à la production.
---

Ce guide fait passer un changement sur une stack (version d'image, variable, service) jusqu'à la production.

## Avant de commencer

- Un clone du dépôt, avec les outils installés par `mise install --locked`.
- Chaque merge sur `main` est déployé en production par Cartons : il n'y a pas de staging.

## 1. Faire le changement sur une branche

Créez une branche nommée `<type>/<description>`, avec un type parmi `feat`, `fix`, `docs` et `chore` :

```bash
git switch -c chore/bookstack-26.10
```

Modifiez `stacks/<stack>/compose.yaml`, ou l'environnement de la stack dans `infrastructure/resources.toml`. Une variable secrète s'écrit `[[NOM]]` : sa valeur se règle dans Cartons, jamais dans le dépôt.

Pour une image, gardez un tag fixe, et si possible son digest : `image: nom:1.2.3@sha256:…`.

## 2. Vérifier avant la PR

```bash
docker compose -f stacks/<stack>/compose.yaml config --quiet
trunk check
```

Pour une image, regardez ce que grype en dit :

```bash
mise exec -- grype registry:nom:1.2.3 --platform linux/amd64 --only-fixed
```

## 3. Ouvrir la PR et la mettre en file

Ouvrez la PR, puis, une fois relue :

```bash
gh pr merge <numéro> --squash
```

La PR entre dans la file d'attente quand les checks requis sont verts, puis elle est mergée en squash. Voir [la qualité des changements](../architecture/arc42/08-cross-cutting-concepts.md).

## 4. Vérifier le déploiement

- Dans Cartons, la stack s'est redéployée sans erreur.
- Le service répond : voir [les stacks déployées](../architecture/arc42/07-deployment-view.md).

Une modification faite dans l'interface de Cartons est écrasée à la synchronisation suivante : passez toujours par le dépôt.

Pour revenir en arrière, il suffit d'une PR qui rétablit l'état précédent, sauf après une montée de base qui ne se défait pas : voir [restaurer une sauvegarde](restaurer-une-sauvegarde.md).
