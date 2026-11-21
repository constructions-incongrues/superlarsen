## 1. Prérequis

- [x] 1.1 Vérifier que #47 (`audit.yml`, job `zizmor`) est mergée sur `main`, sinon s'arrêter
- [x] 1.2 Relever la protection actuelle de `main` (`gh api repos/{owner}/{repo}/branches/main/protection`), pour pouvoir revenir en arrière

## 2. Dépôt

- [x] 2.1 Ajouter `merge_group:` au `on:` de `.github/workflows/lint.yml` et `.github/workflows/audit.yml`, avec un groupe `concurrency` qui retombe sur `github.ref` quand `github.head_ref` est vide
- [x] 2.2 Écrire `.github/rulesets/main.json` : `pull_request` (0 approbation, résolution des conversations, squash seul), `required_status_checks` (`trunk check`, `zizmor`, sans mode strict), `merge_queue` (SQUASH, ALLGREEN, groupe de 1, délai de 30 min), `non_fast_forward`, `deletion`, `required_linear_history`, `bypass_actors: []`
- [x] 2.3 Ajouter `permissions.deny: ["Bash(gh pr merge:*)", "Bash(gh pr review:*)"]` à `.claude/settings.json`
- [x] 2.4 Passer `managed = false` dans le `resource_sync` de `infrastructure/resources.toml`
- [x] 2.5 Dans AGENTS.md, écrire qu'un changement atteint `main` par la merge queue, que le mainteneur met en file et que l'agent ne merge pas, et que l'interface de Cartons n'écrit plus dans le dépôt
- [x] 2.6 Faire accepter les artefacts de ce change à markdownlint, que la CI bloque. Dans `.trunk/configs/.markdownlint.yaml`, mettre `MD025: { front_matter_title: "" }`, pour qu'un ADR puisse avoir à la fois un `title:` et un `#`. Dans `.trunk/trunk.yaml`, exclure `openspec/changes/**` de markdownlint, puisque les artefacts OpenSpec ne commencent pas par un titre. Trunk ne sait pas exclure une seule règle par chemin : c'est tout markdownlint qui est exclu sur ces fichiers
- [x] 2.7 Lancer `trunk check` et `npx ontrack check`. Ouvrir la PR ; elle est mergée par l'ancienne protection, une dernière fois

## 3. Forge (le mainteneur, après le merge de la PR)

- [ ] 3.1 Créer le ruleset depuis `.github/rulesets/main.json` avec `gh api -X POST repos/{owner}/{repo}/rulesets --input .github/rulesets/main.json`
- [ ] 3.2 Mettre en file une PR de test et vérifier que `trunk check` et `zizmor` tournent sur `merge_group` et que la PR est mergée en squash
- [ ] 3.3 Supprimer la protection de branche classique de `main` (`gh api -X DELETE repos/{owner}/{repo}/branches/main/protection`)
- [ ] 3.4 Vérifier qu'un push direct sur `main` et qu'un `gh pr merge --admin` sont refusés

## 4. Clôture

- [ ] 4.1 Vérifier dans Cartons que la synchronisation tourne toujours depuis `main` après `managed = false`
- [ ] 4.2 Archiver le change (`openspec archive ruleset-main-merge-queue`) dans la PR qui coche la dernière tâche, et fermer #36
