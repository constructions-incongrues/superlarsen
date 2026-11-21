---
title: Glossaire
---

| Terme        | Définition                                                                           |
| ------------ | ------------------------------------------------------------------------------------ |
| Cartons      | l'instance Komodo de pastis-hosting qui déploie les stacks ; aussi le nom du serveur |
| Komodo       | l'outil de déploiement de stacks Docker sur lequel repose Cartons                    |
| Stack        | une application et ses services, définie par un `compose.yaml` sous `stacks/`        |
| `stack-back` | le service de sauvegarde Restic de chaque stack                                      |
| R2           | le stockage objet de Cloudflare, cible des sauvegardes                               |
| Caddy        | le reverse proxy du serveur, configuré par labels Docker                             |
| Trunk        | l'outil qui lance les linters du dépôt                                               |
