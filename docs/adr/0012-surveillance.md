# 12. Savoir quand quelque chose est en panne, avec une page d'état publique

Date : 2025-10

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.

## Contexte

Une radio en ligne peut s'arrêter sans bruit : le flux coupe la nuit, le site
renvoie une erreur, et on l'apprend par un auditeur trois jours plus tard.
Il faut quelque chose qui vérifie à notre place, et qui prévienne.

## Décision

Nous surveillons nos services avec [Upptime](https://upptime.js.org), dans le
dépôt
[`constructions-incongrues/superlarsen-status`](https://github.com/constructions-incongrues/superlarsen-status).
La page d'état est publique, sur `https://status.superlarsen.fr`.

- Les adresses surveillées : LibreTime, Icecast, Castopod, le wiki et le site.
- Upptime tourne gratuitement sur GitHub : il ne dépend pas de notre serveur,
  donc il voit la panne même quand `cartons` est tombé.
- Une panne ouvre un ticket sur GitHub, assigné à une seule personne.

## Ce que nous ne savons pas

- Si la surveillance d'Icecast vérifie que **le son passe**, ou seulement que
  la page du serveur répond. Un flux silencieux peut paraître en bonne santé.

## Conséquences

### Ce que nous gagnons

- Les pannes sont vues vite, et la page d'état répond aux auditeurs qui se
  demandent si c'est chez eux ou chez nous.
- Un historique de disponibilité, sans coût.

### Ce que nous devons tenir

- La personne prévenue : une seule aujourd'hui. Si elle est absente, la panne
  attend.
- Un compte GitHub, pour l'outil et pour recevoir les alertes.

### Pour une autre radio

Un service gratuit de surveillance d'adresse (il en existe plusieurs) qui vous
envoie un mail quand votre flux ne répond plus suffit au début. Ce qui compte
le plus : que l'alerte arrive à plusieurs personnes.
