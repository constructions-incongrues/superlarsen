# 4. Passer en direct depuis un autre lieu, par les entrées de LibreTime

Date : 2025-08

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.
L'usage réel n'est pas documenté (voir « Ce que nous ne savons pas »).

## Contexte

Une radio associative a souvent plusieurs lieux : deux studios, une salle de
concert, un marché, un café. Pour passer à l'antenne depuis ailleurs que le
studio principal, il faut pouvoir envoyer un son au serveur, qui le diffuse à
la place de la programmation automatique.

## Décision

Nous utilisons les deux entrées en direct que LibreTime ouvre (on les appelle
_harbor_), réglées dans
[`stacks/libretime/config.template.yml`](../../stacks/libretime/config.template.yml) :

- l'entrée **`main`**, sur le port 8001 : elle prend la main sur toute
  l'antenne ;
- l'entrée **`show`**, sur le port 8002 : elle sert pendant le créneau d'une
  émission.

Depuis n'importe quel lieu avec une connexion internet, un logiciel d'envoi de
flux (par exemple [BUTT](https://danielnoethen.de/butt/), libre et gratuit)
peut s'y connecter.

## Ce que nous ne savons pas

- **Si ces entrées servent vraiment**, et pour quelles émissions.
- **Quel logiciel** utilisent les animateurs, et avec quels réglages.
- **Qui a les identifiants** de connexion.
- Ces deux entrées **ne sont pas chiffrées** (`secure: false`) : le mot de
  passe de connexion passe en clair sur le réseau. Pour une radio, le risque
  est qu'un tiers récupère le mot de passe et prenne l'antenne.

## Conséquences

### Ce que nous gagnons

- Un direct depuis n'importe où, sans matériel dédié : un ordinateur, une
  carte son et une connexion suffisent.
- Le retour à la programmation automatique se fait tout seul à la fin du
  direct.

### Ce que nous devons tenir

- Les identifiants, à transmettre aux animateurs et à changer quand quelqu'un
  part.
- Une fiche pas à pas pour les animateurs, dans notre wiki (voir
  l'[ADR-0009](0009-documentation-des-benevoles.md)).

### Pour une autre radio

Si vous diffusez par créneaux, sans programmation automatique, un logiciel
comme BUTT envoyé directement vers votre serveur Icecast suffit : pas besoin
de LibreTime pour faire un direct. Les entrées de LibreTime deviennent utiles
le jour où vous diffusez en continu (voir
l'[ADR-0005](0005-automatisation-d-antenne.md)).
