# 15. Conserver les programmes : quoi, et combien de temps ?

## Statut

Question ouverte.

## Contexte

Les émissions d'une radio associative sont une mémoire locale : des voix, des
lieux, des débats qu'on ne retrouve nulle part ailleurs. Mais chaque fichier
garde a un coût de stockage et de sauvegarde, et tout garder sans tri rend
l'archive inutilisable.

Chez Super Larsen, les programmes vivent à deux endroits :

- les fichiers de l'antenne, dans LibreTime
  (`/mnt/superlarsen/libretime/storage`, voir
  l'[ADR-0005](0005-automatisation-d-antenne.md)) ;
- les podcasts, dans Castopod (`/mnt/superlarsen/castopod/media`, voir
  l'[ADR-0001](0001-hebergement-des-podcasts.md)).

Les deux sont sauvegardés (voir l'[ADR-0011](0011-sauvegardes.md)), mais la
rétention des sauvegardes (3 ans au plus) n'est pas une politique de
conservation.

## Ce que nous ne savons pas

- Ce qu'on garde pour toujours, ce qu'on garde un temps, ce qu'on efface.
- Si une radio associative a l'obligation légale de conserver les
  enregistrements de son antenne, et pendant combien de temps _(à vérifier)_.
- Si un fonds d'archives (une médiathèque, les archives départementales, un
  dépôt public) pourrait accueillir les émissions qui méritent de durer.
- Combien pèsent les deux volumes aujourd'hui.

## Réponses d'autres radios

Aucune pour l'instant.
