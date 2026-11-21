---
title: Exigences de qualité
---

| Qualité        | Scénario                                           | Réponse attendue                                                       |
| -------------- | -------------------------------------------------- | ---------------------------------------------------------------------- |
| Récupérabilité | le serveur `cartons` est perdu                     | les données se restaurent depuis la sauvegarde R2 de la veille au plus |
| Maintenabilité | une stack doit monter de version                   | une PR qui change un tag d'image, déployée au merge                    |
| Sécurité       | une rafale de « mot de passe oublié » vise le site | le défi Cloudflare sur `wp-login.php` arrête les robots                |
| Disponibilité  | un service tombe                                   | la page d'état le signale (<https://status.superlarsen.fr>)            |
