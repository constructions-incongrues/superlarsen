---
title: Exigences de qualité
---

Les trois premiers scénarios répondent aux [objectifs de qualité](01-introduction-and-goals.md) ; les deux derniers s'y ajoutent.

| Qualité        | Situation          | Scénario                                           | Réponse attendue                                                                                                        | Tenu aujourd'hui                                                                       |
| -------------- | ------------------ | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Maintenabilité | marche normale     | une stack doit monter de version                   | une PR d'une ligne, qui change un tag d'image ; déployée au merge, sans geste sur le serveur                            | oui                                                                                    |
| Récupérabilité | serveur perdu      | le serveur `cartons` est perdu                     | au plus 24 heures de données perdues ; tout se reconstruit depuis le dépôt, R2 et le trousseau du mainteneur            | non vérifié : jamais exercé, délai inconnu ([risques](11-risks-and-technical-debt.md)) |
| Sobriété       | marche normale     | une application s'ajoute à la plateforme           | un répertoire sous `stacks/` et une entrée dans `resources.toml` ; aucun serveur de plus, aucune image construite ici   | oui                                                                                    |
| Sécurité       | attaque            | une rafale de « mot de passe oublié » vise le site | toute requête vers `wp-login.php` passe le défi Cloudflare ; un robot qui poste directement ne déclenche aucun e-mail   | oui, depuis le 2026-11-19                                                              |
| Disponibilité  | panne d'un service | un service ne répond plus                          | la page d'état (<https://status.superlarsen.fr>) le montre ; aucun délai de détection ni de rétablissement n'est promis | oui                                                                                    |
