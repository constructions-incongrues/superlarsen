# 13. Une seule infrastructure pour deux associations

Date : 2025-08

## Statut

Proposé. À valider par le collectif Super Larsen avant diffusion à d'autres radios.
La gouvernance n'est pas écrite (voir « Ce que nous ne savons pas »).

## Contexte

Super Larsen réunit deux associations, La Calligramme et Radio Supeyres, avec
deux studios, à Ambert et à Brioude. Chacune aurait pu monter sa propre
antenne, son propre site et ses propres podcasts.

## Décision

Les deux associations partagent une seule infrastructure : un serveur, un
flux, un site, un hébergement de podcasts et un wiki, tous décrits dans ce
dépôt.

## Ce que nous ne savons pas

- **Qui décide** d'un changement technique qui touche les deux associations.
- **Qui paie** le serveur et les services, et selon quelle répartition.
- **À qui appartiennent** le domaine, les comptes et les données (voir
  l'[ADR-0010](0010-comptes-et-acces.md)).
- **Ce qui se passe si une association s'en va** : ce qu'elle emporte, ce qui
  reste.

## Conséquences

### Ce que nous gagnons

- Un seul ensemble de services à maintenir, au lieu de deux.
- Une antenne commune, plus riche que deux grilles séparées.

### Ce que nous devons tenir

- Une règle écrite, même courte, qui réponde aux quatre questions ci-dessus.
  Elle n'existe pas encore.

### Pour une autre radio

Partager une infrastructure avec une radio voisine divise le travail et les
coûts. Écrivez avant de commencer qui paie, qui décide et qui part avec quoi :
c'est plus facile tant que tout va bien.

Si les deux radios n'ont ni les mêmes besoins ni le même rythme (l'une en FM,
l'autre en ligne, ou des budgets très différents), deux installations séparées
évitent de devoir décider à deux pour tout.
