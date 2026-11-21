## Context

La barre latérale est définie dans `astro.config.mjs` (Starlight 0.43.1). La collection `docs` lit `docs/` avec le loader `glob`, et l'identifiant d'une page vient de son chemin en minuscules, par exemple `adr/engineering/adr-0006-commits` (#61). Pour classer les pages, `autogenerate.directory` doit commencer par `docs/` (#72). Le build réécrit les liens `.md` et échoue sur un lien interne cassé ou une barre latérale vide (`scripts/docs-links.mjs`, #72 et #85).

ADR en vigueur : ADR-0008 (site Starlight, `docs/`, public), ADR-0010 (arc42 à `docs/architecture/arc42/`, hors Diátaxis), ADR-0001 (corps des ADR gelé une fois tranché ; les ADR de gouvernance sont importés par ontrack).

## Goals / Non-Goals

**Goals:**

- Une barre latérale à deux niveaux : Guides, Plateforme (Architecture, Model, Conventions).
- Les ADR du dépôt rangés sous la section 09 d'arc42, et le numéro de chaque ADR affiché.
- Ne garder aucun doublon d'arc42.

**Non-Goals:**

- Déplacer des fichiers : les ADR restent dans `docs/adr/local/` et `docs/adr/engineering/`, là où ontrack les attend.
- Modifier les ADR de gouvernance.
- Rediriger les anciennes adresses `reference/…` : GitHub Pages ne sert pas de redirection, et ces pages ont vécu une heure.

## Decisions

### Architecture : une liste explicite autour d'un groupe

`autogenerate` ne permet pas d'insérer un groupe au milieu d'un dossier. « Architecture » liste donc explicitement les sections par leur identifiant (`architecture/arc42/01-introduction-and-goals`, …), avec à la place de la 09 un groupe :

```js
{ label: "Décisions", items: [
    "architecture/arc42/09-architecture-decisions",
    { autogenerate: { directory: "docs/adr/local" } },
] }
```

La page 09 prend le libellé « À propos » par `sidebar.label` dans son frontmatter. C'est un fichier du dépôt, pas un ADR.
Alternative écartée : déplacer les ADR locaux sous `docs/architecture/arc42/09-…/`. Ce serait sortir de l'emplacement où ontrack les range (`docs/adr/local/`).

Ajouter une section arc42 demandera d'éditer cette liste. Les 12 sections sont fixes (ADR-0010), donc le coût est nul en pratique. La garde du build empêche par ailleurs un identifiant faux de passer inaperçu, car Starlight échoue sur un slug inconnu.

### Model : un lien externe

`{ label: "Model", link: "/model/", attrs: { target: "_blank", rel: "noopener" } }`. Starlight ajoute la base aux liens de la barre latérale : le lien s'écrit `/model/` (vérifié au build ; avec la base écrite en dur, il devenait `/superlarsen/superlarsen/model/`).

### Numéro des ADR : un route middleware

Un `routeMiddleware` Starlight (`src/routeData.ts`) parcourt `starlightRoute.sidebar`. Pour chaque lien dont l'adresse contient `/adr-NNNN-`, il préfixe le libellé par `ADR-NNNN`. Le numéro vient donc du nom de fichier, qu'ADR-0001 impose égal au champ `adr`, et aucun fichier n'est touché.
Alternative écartée : un `sidebar.label` dans chaque ADR. Il faudrait modifier 26 fichiers importés et gelés, et la prochaine révision ontrack pourrait les réécrire.
Autre alternative écartée : transformer le schéma de la collection (`docsSchema(…).transform`). Starlight attend un objet Zod, et une transformation risque de casser la fusion du schéma.

### Suppression de la Référence

`docs/reference/` est supprimé. Les liens deviennent :

- les stacks : Architecture 05 (briques) pour les services, Architecture 07 (déploiement) pour les adresses et Cartons ;
- les checks : Architecture 08 (concepts transversaux, « Qualité des changements »).

Les liens Cartons par stack forment un tableau « Stacks déployées » dans la section 07.

## Risks / Trade-offs

- [Des adresses publiques disparaissent (`reference/stacks/`, `reference/checks/`)] → elles ont été publiées une heure avant ce changement, et la 404 de Starlight reste navigable.
- [Le lien « Model » ne prend pas la base ou s'ouvre mal] → vérifié dans le build et dans l'aperçu avant la PR.
- [Le middleware ne réécrit pas les libellés partout, par exemple dans le fil « Précédent / Suivant »] → seule la barre latérale est exigée par la spec. Les liens de pagination gardent le titre.
