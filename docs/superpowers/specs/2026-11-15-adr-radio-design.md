# Les questions d'une radio associative, en ADR

## Intention

Partager avec d'autres radios associatives (Les Pieds dans le Plateau, LYL,
Radio Libertaire) les arbitrages pris par Super Larsen. Ce n'est pas une leçon,
c'est un commun : des questions partagées, la réponse de Super Larsen quand
elle existe, et une place pour celle des autres radios.

## Objectifs

- Un ADR par question, 15 au total, y compris celles que Super Larsen n'a pas
  tranchées.
- Une question ouverte se repère au premier coup d'œil.
- Le tout peut s'envoyer tel quel au premier contact.

## Non-objectifs

- Le paquet ontrack, la vérification par mdschema. On les fera quand une
  deuxième radio aura répondu.
- Les choix d'IaC de Super Larsen (Terraform, Komodo) : c'est son « comment »,
  pas une question de radio.

## Anti-objectifs

- Un ADR qui pousse la stack de Super Larsen comme seule bonne réponse.
- Une raison inventée et présentée comme un fait.

## Approches

- **A. Un index unique**, avec des fichiers seulement pour les questions déjà
  tranchées. C'est le plus léger, mais une question ouverte n'a aucun endroit
  où recevoir une réponse.
- **B. Un fichier par question, ouvertes comprises.** _Choisi par Tristan._
  Chaque question a sa place pour des réponses. Le prix : des fichiers en
  partie vides au départ.
- **C. Un index et une issue GitHub par question ouverte.** Écarté : il faut
  un compte GitHub pour répondre.

## Conception

- **Emplacement** : `docs/adr/NNNN-<sujet>.md`. Les numéros suivent la liste
  ci-dessous ; `0001-hebergement-des-podcasts.md` existe déjà.
- **Format** : Nygard, en français, comme l'ADR-0001. Le titre reprend la
  question.
- **Deux statuts** :
  - **Proposé** : Super Larsen a tranché, et l'ADR attend la validation du
    collectif.
  - **Question ouverte** : ce statut n'est pas dans Nygard, l'index l'explique.
    Le fichier contient le contexte, une section « Ce que nous ne savons pas »
    et une section « Réponses d'autres radios » (« Aucune pour l'instant. »).
- **Questions mixtes** (0011 sauvegardes, 0013 infra partagée) : statut
  Proposé, avec la partie encore ouverte nommée dans « Ce que nous ne savons
  pas ».
- **Chaque ADR finit par « Pour une autre radio »**, comme l'ADR-0001.
- **Les faits viennent du dépôt** (stacks, `resources.toml`, Terraform). Une
  raison déduite plutôt que recueillie porte la mention _(à confirmer)_.
- **Index** : `docs/adr/README.md`, avec un tableau des 15 questions rangées
  par étape, leur statut et un lien vers chaque fichier.

## La liste

| N°                           | Question                                            | Statut                            |
| ---------------------------- | --------------------------------------------------- | --------------------------------- |
| **Diffuser**                 |                                                     |                                   |
| 0001                         | Podcasts : plateforme ou auto-hébergement ?         | Proposé (écrit)                   |
| 0002                         | Le flux en direct : quel serveur, quelle adresse ?  | Proposé                           |
| 0003                         | Le site : quel outil, et qui le maintient ?         | Proposé                           |
| 0004                         | Passer en direct depuis un autre lieu               | Proposé (usage non documenté)     |
| **Tourner en continu**       |                                                     |                                   |
| 0005                         | L'automatisation d'antenne : quel logiciel ?        | Proposé                           |
| 0006                         | Le dépôt des émissions par les animateurs           | Proposé (à confirmer)             |
| 0007                         | Afficher ce qui passe et les derniers titres        | Proposé                           |
| 0008                         | La grille : qui la tient, dans quel outil ?         | Question ouverte                  |
| **Tenir avec des bénévoles** |                                                     |                                   |
| 0009                         | Où vit la documentation des bénévoles ?             | Proposé                           |
| 0010                         | Les comptes : au nom de qui, qui a les accès ?      | Question ouverte                  |
| 0011                         | Les sauvegardes : quoi, où, combien de temps ?      | Proposé (restauration non testée) |
| 0012                         | Savoir quand quelque chose est en panne             | Proposé                           |
| 0013                         | Une infra partagée entre deux associations          | Proposé (gouvernance non écrite)  |
| **Propre à la radio**        |                                                     |                                   |
| 0014                         | Les droits musicaux : déclarations et relevés       | Question ouverte                  |
| 0015                         | Conserver les programmes : quoi, combien de temps ? | Question ouverte                  |

## Laissé à qui rédige

L'ordre des paragraphes dans chaque section, la formulation exacte des titres,
et le niveau de détail technique, qui doit rester lisible par un bénévole non
développeur.
