# 10. Les comptes : au nom de qui, et qui a les accès ?

Les mots techniques sont expliqués dans le [sommaire](README.md#mots-techniques).

## Statut

Question ouverte.

## Contexte

Une radio en ligne dépend d'une dizaine de comptes chez des fournisseurs : le
nom de domaine, le DNS, l'hébergeur du serveur, l'outil de déploiement, le
service de mail, les plateformes de podcasts. Chacun a été ouvert un jour par
une personne, souvent à son nom.

Chez Super Larsen, ces comptes sont :

| Service                               | À quoi il sert                                                                                               |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Registrar du domaine `superlarsen.fr` | le nom de domaine                                                                                            |
| Cloudflare                            | le DNS, et un stockage R2 (destination probable des sauvegardes, _à vérifier_)                               |
| Hetzner                               | le serveur `cartons` et son volume                                                                           |
| Terraform Cloud                       | l'état de l'infrastructure (voir [`infrastructure/terraform/`](../../infrastructure/terraform/terraform.tf)) |
| Cartons (Komodo)                      | le déploiement des stacks                                                                                    |
| Mail sortant (SMTP)                   | les mails des services                                                                                       |
| Spotify, Deezer, Podcast Index        | la diffusion des podcasts                                                                                    |
| GitHub                                | ce dépôt et la page d'état                                                                                   |

Le cas qui a fait poser la question : pour corriger l'adresse `superlarsen.fr`
sans `www` (voir l'[ADR-0003](0003-site-web.md)), il faut un accès à la zone
DNS chez Cloudflare, et on ne sait pas sur quel compte elle se trouve. Le
domaine, lui, est sur un compte OVH tiers.

## Ce que nous ne savons pas

- Au nom de qui est chaque compte : l'association, un bénévole, un tiers.
- Qui a les accès à chacun, et comment ils se transmettent quand quelqu'un
  part.
- Où sont rangés les mots de passe partagés, s'il y en a.
- Ce qui se passe si la seule personne qui a un accès n'est plus joignable.

## Réponses d'autres radios

Aucune pour l'instant.
