# Introduction

Ce projet consistait à implémenter un simulateur de bataille navale en langage assembleur MIPS32. Le simulateur devait permettre de visualiser chaque étape de la partie, depuis l'initialisation de la grille jusqu'à la destruction de tous les navires. La difficulté principale résidait dans la gestion de la mémoire en assembleur et la production d'un affichage correct.

## Fonctions implémentées

### Fonction `addLineCount`

La fonction `addLineCount` affiche le numéro de la ligne en cours. Elle reçoit dans le registre `$a1` le numéro de ligne courant. La logique principale consiste à distinguer les numéros à un chiffre (1 à 9) des numéros à deux chiffres (ici uniquement 10). Pour les lignes 1 à 9, elle affiche un espace, puis le chiffre converti en caractère ASCII, et enfin un autre espace, produisant par exemple `" 3 "`. Pour la ligne 10, elle affiche directement la chaîne `"10 "` sans espace supplémentaire au début.

### Fonction `displayLettres`

Elle affiche les lettres de A à J, chacune suivie d'un espace, avec une marge de trois espaces au début pour l'alignement : `"   A B C D E F G H I J"`. Elle utilise une boucle qui part du caractère `'A'` (65 en ASCII) et l'incrémente progressivement jusqu'à `'J'` (74). L'affichage se fait caractère par caractère via l'appel système approprié.

### Fonction `placeHorizontale`

La fonction `placeHorizontale` place un navire horizontalement dans la grille. Elle commence par tirer au sort une ligne et une colonne de départ. La colonne est choisie pour que le navire ne dépasse pas du bord droit de la grille. Ensuite, elle vérifie si toutes les cases nécessaires sont vides en appelant `verifPlaceHorizontale`. Si la vérification échoue, le processus recommence. Si elle réussit, le navire est placé en remplissant horizontalement, depuis la colonne de départ, un nombre de cases égal à sa taille.

### Fonction `verifPlaceHorizontale`

La fonction `verifPlaceHorizontale` contrôle si un navire peut être placé horizontalement à un emplacement donné. Elle reçoit une ligne, une colonne de départ et la taille du navire. Elle parcourt chaque case que le navire occuperait, de la colonne de départ vers la droite. Pour chaque case, elle vérifie si elle est libre, c'est-à-dire si elle contient le caractère point (`.`) qui représente une case vide. Si une case est déjà occupée, la fonction retourne immédiatement une erreur. Si toutes les cases sont libres, elle autorise le placement.

### Fonction `placeVerticale`

La fonction `placeVerticale` place un navire verticalement dans la grille. Son fonctionnement est symétrique à `placeHorizontale`. Elle tire au sort une colonne et une ligne de départ, cette fois-ci calculée pour que le navire ne dépasse pas du bord inférieur de la grille. Elle utilise ensuite `verifPlaceVerticale` pour contrôler l'emplacement. Si le contrôle est positif, elle place le navire en remplissant verticalement, vers le bas, le nombre de cases correspondant à sa taille.

### Fonction `verifPlaceVerticale`

La fonction `verifPlaceVerticale` contrôle si un navire peut être placé verticalement à un emplacement donné. Elle fonctionne comme sa version horizontale, mais en parcourant les cases vers le bas. Elle vérifie que chaque case sur la même colonne, de la ligne de départ jusqu'à la ligne de départ plus la taille du navire, est bien vide. Elle signale un succès uniquement si la colonne verticale est entièrement libre sur la longueur requise.

### Fonction `simulationJeu`

La fonction `simulationJeu` simule une partie complète de bataille navale de manière automatique. Elle fonctionne en boucle jusqu'à ce que tous les navires soient coulés. À chaque tour, elle tire au hasard une coordonnée sur la grille (une ligne et une colonne entre 0 et 9). Elle appelle ensuite la fonction `traque` pour traiter ce tir. La simulation s'arrête uniquement lorsque le nombre de coups réussis atteint 17, ce qui correspond à la taille totale de tous les navires combinés.

### Fonction `traque`

Elle gère intelligemment chaque tentative. Elle reçoit des coordonnées (ligne, colonne) et vérifie d'abord si elles sont dans les limites de la grille (10×10). Si ce n'est pas le cas, elle retourne immédiatement. Ensuite, elle calcule l'adresse de la case correspondante et examine son contenu : si la case n'a pas déjà été visée, alors elle retourne également. Sinon, elle incrémente le compteur de coups. Si la case est vide, elle la marque comme tir manqué avec un tilde (`~`) et retourne. Si la case contient une lettre (navire), elle incrémente `nb_coups_but`, la marque comme touchée avec un `X`, puis s'appelle récursivement pour les quatre cases voisines (nord, sud, est, ouest). Ce qui permet de faire couler un navire une fois qu'une de ses cases est touchée.

---

**Pseudo-code :**

```text
fonction traque(case):
    si case == '~' OU case == 'X':
        retourner
    nb_coups++
    si case == '.':
        case = '~'
        retourner
    sinon (c'est une lettre):
        nb_coups_but++
        case = 'X'

        traque(ligne-1, colonne) : N
        traque(ligne+1, colonne) : S
        traque(ligne, colonne-1) : O
        traque(ligne, colonne+1) : E
```
