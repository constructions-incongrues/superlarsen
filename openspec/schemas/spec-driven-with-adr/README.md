# spec-driven-with-adr

Schéma OpenSpec de ce dépôt (ADR-0016, `changes.schema`) : proposal → specs → design → adr → tasks.

## Provenance

Copié depuis [intent-driven-dev/openspec-schemas](https://github.com/intent-driven-dev/openspec-schemas/tree/4bb6de2f57c9275a18a4106341fe4632f5026ac6/openspec/schemas/spec-driven-with-adr), au commit `4bb6de2f57c9275a18a4106341fe4632f5026ac6`. Seuls `schema.yaml` et `templates/` sont repris : ni le guide d'installation ni `skills.txt` (ADR-0016, règle 3).

## Ajustements

Les trois écarts qu'ADR-0016 demande, dans les instructions `design` et `adr` et dans `templates/adr.md` :

1. les ADR se lisent dans `docs/adr/` et ses sous-répertoires, et ceux du dépôt s'écrivent dans `docs/adr/local/`, où `ontrack apply` les range, pas dans un `adr/` à la racine ;
2. ils suivent le format d'ADR-0001 : frontmatter avec `supersedes:` et sections Nygard, au lieu de MADR-short avec un champ `Supersedes:` dans le corps ;
3. ils se nomment `ADR-NNNN-slug.md`, au lieu de `NNNN-kebab-title.md`.

Mettre le schéma à jour, c'est le recopier à un autre commit, réappliquer ces ajustements et changer le commit ci-dessus, dans une PR.
