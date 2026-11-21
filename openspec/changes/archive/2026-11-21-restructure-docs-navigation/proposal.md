Issue served: none

## Why

La barre latérale du site aligne cinq groupes au même niveau : Guides, Référence, Architecture (arc42), Décisions du dépôt, Décisions de gouvernance. Les décisions du dépôt sont séparées de la section 9 d'arc42, qui existe pourtant pour elles. Le site du modèle LikeC4 n'est accessible que par une note dans une page. Les ADR n'affichent que leur titre, alors qu'on les cite par leur numéro. Enfin, les pages « Stacks » et « Checks » de la Référence répètent arc42 (sections 5, 7 et 8).

## What Changes

- La barre latérale passe à deux groupes de premier niveau : **Guides** et **Plateforme**.
- **Plateforme > Architecture** regroupe les 12 sections arc42. La section 09 devient le groupe **Décisions** : sa page actuelle en tête, puis les ADR du dépôt. Ces ADR restent dans `docs/adr/local/`.
- **Plateforme > Model** est un lien vers `/superlarsen/model/`, ouvert dans un nouvel onglet.
- **Plateforme > Conventions > ontrack-engineering** liste les 26 ADR de gouvernance, dans un groupe plié.
- Les ADR s'affichent dans la barre latérale sous la forme « ADR-NNNN Titre ». Le libellé est calculé au build depuis le champ `adr` de leur frontmatter, sans modifier les fichiers.
- **BREAKING (adresses)** : les pages `reference/stacks/` et `reference/checks/` sont supprimées. Les liens du README et des guides renvoient vers les sections 05, 07 et 08 d'Architecture.
- Les liens Cartons par stack, qui n'existaient plus que dans la page Stacks, passent dans la section 07, dans un tableau « Stacks déployées ».

## Capabilities

### New Capabilities

- `docs-navigation` : l'arborescence de la barre latérale du site de documentation, les libellés des ADR et l'accès au site du modèle.

### Modified Capabilities

Aucune.

## Impact

- `astro.config.mjs` (sidebar), `src/content.config.ts` (libellés des ADR).
- `docs/reference/` supprimé ; `README.md`, `docs/how-to/*.md` et `docs/architecture/arc42/07-deployment-view.md` modifiés.
- Les adresses publiques `/superlarsen/reference/stacks/` et `/superlarsen/reference/checks/` cessent d'exister, une heure à peine après leur publication (#84).
