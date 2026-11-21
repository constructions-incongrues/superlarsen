---
title: Glossaire
---

| Terme           | Définition                                                                                                            |
| --------------- | --------------------------------------------------------------------------------------------------------------------- |
| Superlarsen     | le collectif dont ce dépôt héberge les services ; aussi le nom de la plateforme et du volume                          |
| pastis-hosting  | l'hébergeur qui exploite le serveur `cartons`, son Caddy et Cartons, pour plusieurs projets                           |
| Cartons         | l'instance Komodo de pastis-hosting qui déploie les stacks ; écrit `cartons`, c'est le serveur sur lequel elle tourne |
| Komodo          | l'outil de déploiement de stacks Docker sur lequel repose Cartons                                                     |
| Stack           | une application et ses services, définie par un `compose.yaml` sous `stacks/`                                         |
| `stack-back`    | le service de sauvegarde de chaque stack, qui pilote Restic                                                           |
| Restic          | l'outil de sauvegarde chiffrée et dédupliquée que `stack-back` lance ; son dépôt est sur R2                           |
| R2              | le stockage objet de Cloudflare, cible des sauvegardes                                                                |
| Caddy           | le reverse proxy du serveur, configuré par labels Docker                                                              |
| WAF             | _web application firewall_ : ici, la règle Cloudflare qui impose un défi sur `wp-login.php`                           |
| Défi            | la vérification que Cloudflare impose à un navigateur avant de laisser passer sa requête                              |
| Terraform Cloud | le service qui garde l'état de Terraform et exécute ses plans pour ce dépôt                                           |
| GitOps          | `main` décrit l'état voulu, et un outil, ici Cartons, l'applique                                                      |
| PR              | _pull request_ : la seule voie d'un changement vers `main`                                                            |
| Merge queue     | la file de GitHub qui teste chaque PR sur le `main` où elle va atterrir, avant de la merger                           |
| ADR             | _architecture decision record_ : une décision, son contexte et ses conséquences, dans `docs/adr/`                     |
| mu-plugin       | une extension WordPress toujours active, chargée depuis `stacks/wordpress/mu-plugins/`                                |
| Icecast         | le serveur qui diffuse le flux radio aux auditeurs                                                                    |
| Liquidsoap      | le moteur audio de LibreTime, qui assemble le flux et reçoit les directs                                              |
| Trunk           | l'outil qui lance les linters du dépôt                                                                                |
| zizmor          | l'auditeur de sécurité des workflows GitHub                                                                           |
| checkov         | l'analyseur de sécurité de Terraform et des workflows                                                                 |
| grype           | le scanner de vulnérabilités des images Docker                                                                        |
