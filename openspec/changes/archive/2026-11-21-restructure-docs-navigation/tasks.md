## 1. Barre latérale

- [x] 1.1 Réécrire `sidebar` dans `astro.config.mjs` : Guides (`docs/how-to`), Plateforme > Architecture (liste explicite des sections, groupe Décisions à la place de la 09 avec la page 09 puis `docs/adr/local`), Model (lien `/superlarsen/model/`, nouvel onglet), Conventions > ontrack-engineering (`docs/adr/engineering`, replié)
- [x] 1.2 Ajouter `sidebar: { label: "À propos" }` au frontmatter de `docs/architecture/arc42/09-architecture-decisions.md`
- [x] 1.3 Ajouter `src/routeData.ts` (route middleware) qui préfixe le libellé des liens d'ADR par leur numéro, et le déclarer dans la configuration Starlight

## 2. Suppression de la Référence

- [x] 2.1 Ajouter à `docs/architecture/arc42/07-deployment-view.md` un tableau « Stacks déployées » : stack, adresse, lien Cartons
- [x] 2.2 Réorienter les liens vers `reference/stacks.md` (README, guides) vers les sections 05 et 07, et le lien vers `reference/checks.md` vers la section 08, qui reprend le tableau des checks de la page supprimée
- [x] 2.3 Supprimer `docs/reference/`

## 3. Vérification

- [x] 3.1 `npm run docs:build` passe ; la garde des liens ne trouve aucun lien cassé
- [x] 3.2 Dans l'aperçu du build : deux groupes de premier niveau, Décisions sous Architecture avec « À propos » en tête, libellés « ADR-NNNN Titre », Model ouvre `/superlarsen/model/` dans un nouvel onglet, ontrack-engineering replié
- [x] 3.3 `trunk check` ne signale rien ; ouvrir la PR, et archiver le change dans la PR qui coche la dernière tâche
