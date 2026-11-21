## MODIFIED Requirements

### Requirement: Les checks requis tournent dans la file

Les checks requis SHALL être `trunk check`, `zizmor`, `checkov` et `docs build`, et leurs workflows SHALL se déclencher sur `pull_request` et sur `merge_group`. Les checks des apps GitHub (GitGuardian, Trunk Check) SHALL NOT être requis. `grype` SHALL NOT être requis (ADR local 0003).

#### Scenario: Groupe de merge queue

- **WHEN** une PR entre dans la merge queue
- **THEN** `trunk check`, `zizmor`, `checkov` et `docs build` tournent sur l'événement `merge_group` et rendent un verdict

#### Scenario: Site cassé

- **WHEN** une PR fait échouer `docs build`
- **THEN** la PR ne peut pas entrer dans la merge queue
