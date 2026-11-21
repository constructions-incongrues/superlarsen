## 1. Ruleset

- [x] 1.1 Ajouter `checkov` et `docs build` aux `required_status_checks` de `.github/rulesets/main.json`
- [ ] 1.2 Appliquer le ruleset depuis cette branche : `gh api -X PUT repos/constructions-incongrues/superlarsen/rulesets/27807281 --input .github/rulesets/main.json` (le mainteneur)
- [ ] 1.3 Vérifier avec `gh api repos/constructions-incongrues/superlarsen/rules/branches/main` que les quatre checks sont requis

## 2. Clôture

- [ ] 2.1 Archiver le change dans cette PR
