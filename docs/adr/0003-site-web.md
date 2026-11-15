# 3. Un site WordPress, hébergé chez nous et fait par un prestataire

Date : 2025-08

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

Le site d'une radio sert à écouter le direct, retrouver les émissions,
connaître la grille et les événements. Il doit pouvoir être mis à jour par des
bénévoles qui ne sont pas développeurs.

Les options habituelles : un site clé en main (Wix, un service de création de
sites), un CMS libre comme WordPress, ou un site fait sur mesure. La question
qui compte autant que l'outil : **qui le maintient, et qui saura le reprendre ?**

## Décision

Notre site, `https://www.superlarsen.fr`, est un WordPress hébergé sur notre
serveur ([`stacks/wordpress/compose.yaml`](../../stacks/wordpress/compose.yaml),
avec MySQL 8.0). Le thème a été réalisé par un prestataire, crédité en pied de
page.

Les fichiers du site sont accessibles par SFTP
(`sftp://sftp.superlarsen.fr:2222`, voir
[`stacks/sftp/compose.yaml`](../../stacks/sftp/compose.yaml)), pour que le
prestataire puisse travailler sans accès au serveur.

## Ce que nous ne savons pas

- **L'adresse sans `www` ne répond pas** : `superlarsen.fr` n'a pas
  d'enregistrement DNS. Une redirection vers `www.superlarsen.fr` est à
  remettre en place.
- **La version de WordPress n'est pas fixée** : l'image `wordpress` n'a pas de
  numéro de version, donc chaque redéploiement peut changer de version sans
  qu'on l'ait décidé.
- Qui, au collectif, sait modifier le thème si le prestataire n'est plus
  disponible.

## Conséquences

### Ce que nous gagnons

- WordPress est connu de beaucoup de bénévoles : écrire un article ne demande
  aucune formation.
- Le site et ses données sont chez nous, sauvegardés comme le reste (voir
  l'[ADR-0011](0011-sauvegardes.md)).

### Ce que nous devons tenir

- Les mises à jour de WordPress et des extensions : un WordPress oublié est la
  porte d'entrée la plus courante sur un serveur.
- Le lien avec le prestataire, ou une personne qui connaît le thème.

### Pour une autre radio

Si personne chez vous ne veut s'occuper d'un serveur, un WordPress chez un
hébergeur mutualisé, ou même un site clé en main, fait très bien l'affaire.
Ce qui compte vraiment : que le nom de domaine et le compte d'administration
soient au nom de l'association, pas d'un bénévole (voir
l'[ADR-0010](0010-comptes-et-acces.md)).
