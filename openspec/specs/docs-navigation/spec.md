# docs-navigation Specification

## Purpose

L'arborescence de la barre latérale du site de documentation (Starlight), le libellé des ADR et l'accès au site du modèle LikeC4 (ADR-0008, ADR-0010).

## Requirements

### Requirement: Deux groupes de premier niveau

La barre latérale du site SHALL avoir exactement deux groupes de premier niveau, dans cet ordre : « Guides » puis « Plateforme ».

#### Scenario: Ouverture du site

- **WHEN** un visiteur ouvre une page du site
- **THEN** la barre latérale affiche « Guides » puis « Plateforme », et aucun autre groupe de premier niveau

### Requirement: Les guides

Le groupe « Guides » SHALL lister chaque page de `docs/how-to/`.

#### Scenario: Nouveau guide

- **WHEN** une page est ajoutée sous `docs/how-to/`
- **THEN** elle apparaît dans « Guides » sans modifier la configuration

### Requirement: La plateforme

Le groupe « Plateforme » SHALL contenir, dans cet ordre : « Architecture », « Model » et « Conventions ».

#### Scenario: Contenu de Plateforme

- **WHEN** un visiteur déplie « Plateforme »
- **THEN** il voit « Architecture », « Model » et « Conventions »

### Requirement: Architecture et ses décisions

« Architecture » SHALL lister les sections arc42 de `docs/architecture/arc42/` dans l'ordre de leur numéro. La section 09 SHALL être un groupe « Décisions », placé à son rang, qui contient en premier la page de la section 09 sous le libellé « À propos », puis chaque ADR de `docs/adr/local/`.

#### Scenario: Décisions du dépôt

- **WHEN** un visiteur déplie « Architecture > Décisions »
- **THEN** il voit la page de la section 09, puis les ADR du dépôt dans l'ordre de leur numéro

#### Scenario: Nouvel ADR du dépôt

- **WHEN** un ADR est ajouté sous `docs/adr/local/`
- **THEN** il apparaît dans « Décisions » sans modifier la configuration

### Requirement: Accès au modèle

« Model » SHALL être un lien vers `/superlarsen/model/`, qui s'ouvre dans un nouvel onglet.

#### Scenario: Ouvrir le modèle

- **WHEN** un visiteur clique sur « Model »
- **THEN** le site LikeC4 du modèle s'ouvre dans un nouvel onglet

### Requirement: Conventions

« Conventions » SHALL contenir un groupe « ontrack-engineering », replié par défaut, qui liste chaque ADR de `docs/adr/engineering/`.

#### Scenario: Conventions repliées

- **WHEN** un visiteur ouvre une page hors de `docs/adr/engineering/`
- **THEN** le groupe « ontrack-engineering » est replié

### Requirement: Numéro des ADR

Dans la barre latérale, une page dont le frontmatter porte un champ `adr` SHALL avoir pour libellé `<adr> <title>`, par exemple « ADR-0006 Commits ». Les fichiers d'ADR SHALL NOT être modifiés pour cela.

#### Scenario: ADR de gouvernance

- **WHEN** la barre latérale liste `docs/adr/engineering/ADR-0006-commits.md`
- **THEN** son libellé est « ADR-0006 Commits »

#### Scenario: Page sans champ adr

- **WHEN** la barre latérale liste une page arc42 ou un guide
- **THEN** son libellé est son titre, sans préfixe

### Requirement: Aucun lien cassé

Après la restructuration, chaque lien interne du site SHALL mener à une page ou un fichier existant. Le build SHALL échouer sinon.

#### Scenario: Ancienne page de référence

- **WHEN** une page renvoie encore vers `reference/stacks.md` ou `reference/checks.md`
- **THEN** `docs build` échoue et nomme le lien
