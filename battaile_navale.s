# ===== Section donnees =====
.data 
    grille:     .space 100 #Grille de char de 10x10 soit 100 octet
    nb_coups: .word 0 #Compteur du nombre total tirs
    nb_coups_but: .word 0 #Compteur du nombre de coups de but
    
# ===== Section code =====  
.text

# ----- Main ----- 
main:
    jal initPartie
    jal displayGrille
    jal simulationJeu
    j   exit 

# ----- Fonctions -----

# ----- Fonction initPartie -----
# Objectif : Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1

initPartie:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    jal initGrille
    li  $a0, 5
    li  $a1, 65 # 'A' pour Aircraft Carrier (Porte-Avion)
    jal setShip
    li  $a0, 4  
    li  $a1, 66 # 'B' pour Battleship (Cuirassé)
    jal setShip
    li  $a0, 3
    li  $a1, 67 # 'C' pour Cruiser (Croiseur)
    jal setShip
    li  $a0, 3
    li  $a1, 83 # 'S' pour Submarine (Sous-marin)
    jal setShip
    li  $a0, 2
    li  $a1, 68 # 'D' pour Destroyer (Torpilleur)
    jal setShip

    lw      $ra, 0($sp)                 # On recharge la reference 
    add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]

initGrille:
    la      $t0, grille     # Chargement de l'adresse de la grille
    li      $t1, 0          # Initialisation du compteur de boucle dans $t1
    li      $t3, 46         # Charge la valeur ASCII de '.'
    boucle_initGrille:
        bge     $t1, 100, end_initGrille # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$t3, 0($t2)		# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
        j boucle_initGrille
    end_initGrille:
        jr $ra

# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    add     $sp, $sp, -4       # Sauvegarde de la reference du dernier jump 
    sw      $ra, 0($sp)
    
    jal addNewLine          # retour chariot
    jal displayLettres      # on affiche le grille de base
    jal addNewLine          # retour chariot
    
    la      $t0, grille     # charge l'adresse de la grille dans $t0
    li      $t1, 0          # initialise le compteur de boucle dans $t1
    
    boucle_displayGrille:    
        bge     $t1, 100, end_displayGrille     # si $t1 est plus grand ou egal a 100 alors branchement a end_displayGrille
        
            move $a0, $t1                  # argument pour getModulo
            li $a1, 10                     # base de la grille (0-9)
            jal getModulo

            beq $v0, $zero, displayGrille_newline      # Si le modulo est 0, retour à la ligne
            
    afficher_case:
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, 0($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 11                 # code pour l'affichage d'un caractère (char)
            syscall
            
            li $v0, 11			# charge l'appel systeme 11: print_char
            li $a0, 32			# 32 = ' '
            syscall			# ajoute un espace entre chaque case
            
            addi    $t1, $t1, 1            # $t1++;
        j boucle_displayGrille
        
    
    displayGrille_newline:
    	beq $t1, $zero, displayGrille_line		 # Si index==0, ne pas faire newline avant	
	jal addNewLine			 # Affiche '\n'
	
    displayGrille_line:
	addi $a1, $v1, 1			# $a1 = quotient + 1 (ligne 1..10)
	jal addLineCount			# Affiche le numéro de la ligne
	
	j afficher_case	 # Continue en imprimant la case 
	
    end_displayGrille:
        jal addNewLine          # retour chariot
        lw      $ra, 0($sp)                  # On recharge la reference 
        addi     $sp, $sp, 4                 # du dernier jump
    jr $ra
    
    

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t0, ($t1,)$v0, $a0

displayLettres:
    li $v0, 11			# charge l'appel systeme 11: print_char
    li $a0, 32			# 32 = ' '
    syscall				# Affiche 1 espaces (1/3)
    syscall				# (2/3)
    syscall				# (3/3) pour ếtre bien aligné.
    
    li $t0, 65			# 65 = 'A'
    boucle_displayLettres:
	li $v0, 11          # charge l'appel systeme 11: print_char
	move $a0, $t0	    # caractère à afficher -> $t0
	syscall
	
	li $v0, 11      # charge l'appel systeme 11: print_char
        li $a0, 32		# 32 = ' '
	syscall
	
    	
	addi $t0, $t0, 1	 # $t0+1 pour avoir la lettre d'après => 65:'A' -> 66:'B'
	ble $t0, 74, boucle_displayLettres
	jr $ra

# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    li      $v0, 11         # Chargement appel systeme 11 (Affichage d'un char)
    li      $a0, 10         # Chargement chaine à afficher -> '\n'
    syscall
    
    jr $ra

# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : res du modulo + 1)

addLineCount:	
    li $t2, 10		#Constant 10
    bge $a1, $t2, addLineCount_print10 #Si ligne >= 10, afficher "10"
    
        li $v0, 11		 # print char
    	li $a0, 32       	# ASCII pour espace
    	syscall		#Un espace avant le chiffre
	
    	li $v0, 11       		# print char
    	addi $a0, $a1, 48	#convertir int en char
    	syscall			# Affiche chiffre
	
    j addLineCount_end	#Aller a la fin
	
    addLineCount_print10:
	li $v0, 11       	# print char
	li $a0, 49		# 1 en char et affichage
	syscall		# Affiche '1'
	
	li $v0, 11      	# print char
	li $a0, 48		# 0 en char et affichage
	syscall		# Affiche '0'
	
    addLineCount_end:
	li $v0, 11       # print char
	li $a0, 32       # ASCII pour espace
	syscall	      # un espace et affichage
	
    jr $ra	      #return

# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans : $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $a1

getModulo: 
    li $v1, 0
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt $a0, $a1, end_getModulo
        addi $v1, $v1, 1
        sub $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra

# ----- Fonction getAleatoire ----- 
# Objectif : Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0

getAleatoire:
    li $v0, 42
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caraètre pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]

setShip:
    addi     $sp, $sp, -4
    sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

    move 	$s0, $a0		# On recopie la taille dans $s0
    move    $s4, $a1        # On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li      $a1, 2          # Définition de la borne surpérieur (Resultat possbile : 0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move 	$s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement

    end_setShip:
        lw      $ra, 0($sp)
        add     $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
    
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
# 	Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeHorizontale:
    # ligne aléatoire (0-9)
    li $a1, 10         # base
    jal getAleatoire
    move $s2, $a0        # $s2 = ligne

    # colonne aléatoire (0 à 9 - taille du navire)
    move $a1, $s0
    li $t0, 10
    sub $a1, $t0, $a1   # 10 - taille
    jal getAleatoire
    move $s3, $a0        # $s3 = colonne

    # vérifier placement possible
    jal verifPlaceHorizontale
    bnez $v0, try_setShip  # si pas possible, réessayer

    # Placer le navire
    la $t0, grille
    li $t1, 0          # compteur
place_horizontal_loop:
    beq $t1, $s0, end_place_horizontal
    
    #calcul index: ligne*10 + colonne + i
    mul $t2, $s2, 10    # ligne * 10
    add $t2, $t2, $s3   # +colonne
    add $t2, $t2, $t1   # +i
    add $t3, $t0, $t2   # adresse dans la grille
    sb $s4, 0($t3)     # placer le caractère du navire
    addi $t1, $t1, 1
    j place_horizontal_loop
    
end_place_horizontal:
    j end_setShip

# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceHorizontale:
    la $t0, grille
    li $t1, 0          # compteur
    verif_horizontal_loop:
    	beq $t1, $s0, verif_horizontal_ok
    	# ligne*10+colonne+i
    	mul $t2, $s2, 10    # ligne * 10
    	add $t2, $t2, $s3   # + colonne
    	add $t2, $t2, $t1   # + i
    	add $t3, $t0, $t2   # adresse dans la grille
    	lb $t4, 0($t3)      # charger le caractère

    	# si la case n'est pas vide ('.')
    	li $t5, 46         # '.'
    	bne $t4, $t5, verif_horizontal_non

    	addi $t1, $t1, 1
    	j verif_horizontal_loop

verif_horizontal_ok:
    li $v0, 0          # placement OK
    jr $ra

verif_horizontal_non:
    li $v0, 1          # placement pas OK
    jr $ra


# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
# Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeVerticale:
    # ligne aléatoire (0 à 9 - taille du navire)
    move $a1, $s0
    li $t0, 10
    sub $a1, $t0, $a1   # 10 - taille
    jal getAleatoire
    move $s2, $a0        # $s2 = ligne

    # colonne aléatoire (0-9)
    li $a1, 10
    jal getAleatoire
    move $s3, $a0        # $s3 = colonne

    # vérifier placement possible
    jal verifPlaceVerticale
    bnez $v0, try_setShip  # si pas possible, réessayer

    # Placer le navire
    la $t0, grille
    li $t1, 0          # compteur
    place_vertical_loop:
    	beq $t1, $s0, end_place_vertical
    	# calcul index: (ligne + i) * 10 + colonne
    	add $t2, $s2, $t1   # ligne + i
    	mul $t2, $t2, 10    # * 10
    	add $t2, $t2, $s3   # + colonne
    	add $t3, $t0, $t2   # adresse dans la grille
    	sb $s4, 0($t3)     # placer le caractère du navire
    	addi $t1, $t1, 1
    	j place_vertical_loop
    
end_place_vertical:
    j end_setShip

# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceVerticale:
    la $t0, grille
    li $t1, 0          # compteur
    verif_vertical_loop:
    	beq $t1, $s0, verif_vertical_ok
    	# (ligne + i) * 10 + colonne
    	add $t2, $s2, $t1   # ligne + i
    	mul $t2, $t2, 10    # * 10
    	add $t2, $t2, $s3   # + colonne
    	add $t3, $t0, $t2   # adresse dans la grille
    	lb $t4, 0($t3)     # charger le caractère

    	# si la case n'est pas vide ('.')
    	li $t5, 46         # '.'
    	bne $t4, $t5, verif_vertical_non

    	addi $t1, $t1, 1
    j verif_vertical_loop

verif_vertical_ok:
    li $v0, 0          # placement OK
    jr $ra

verif_vertical_non:
    li $v0, 1          # placement pas OK
    jr $ra

# ----- Fonction simulationJeu -----
# Objectif : Simule une partie avec une grille déjà généré.
# Registres utilises : $s[0-3]
simulationJeu:
    addi $sp, $sp, -4       	#on réserve la place pour 4 registres
    sw $ra, 0($sp)          	# on sauvegarde l'adresse de retour
    
    simulationJeu_loop:
    	lw $t1, nb_coups_but		# charge nb_coups
    	li $t2, 17               		# nb total de navires
    	bge $t1,$t2, simulationJeu_end    	# si tout les navires sont touchés, FIN

    	li $a1, 10          # borne (0-9)
    	jal getAleatoire    # on tire une ligne aleatoire
    	move $s0, $a0    	# $s0 = ligne
    
    	li $a1, 10          # borne (0-9)
    	jal getAleatoire    # on tire une colonne aleatoire
    	move $s1, $a0    	# $s1 = colonne
    
    	la $a0, grille      # $a0 = adresse de la grille
    	move $a1, $s0    	# $a1 = ligne
    	move $a2, $s1    	# $a2 = colonne
    	jal traque       	 # appele traque  avec ces coordonnes
    
    j simulationJeu_loop    	#on recommence
    
simulationJeu_end:
    lw $ra, 0($sp)      # on récupère $ra 
    addi $sp, $sp, 4    # onlibère la pile
    jr $ra            	# retour au  main

# ----- Fontion traque -----     
# Objectif : Vérifie la présence d'un navire et le traque de manière récursive
# Registres utilises : $t[8-9], $s[0-3]
traque:
    addi $sp, $sp, -16		#Reserver 16 octets pour sauvgarder contexte
    sw $ra, 12($sp)		#Sauvgarder $ra
    sw $s0, 8($sp)		#Sauvgarder $s0
    sw $s1, 4($sp)		#Sauvgarder $s1
    sw $s2, 0($sp)		#Sauvgarder $s2
    
    move $s0, $a1		# $s0 = ligne
    move $s1, $a2		# $s1 = colonne
    move $s2, $a0		# $s2 = adresse de la grille
    
    bltz $s0, traque_fin	#Si ligne < 0, sortir
    li $t0, 10							# t0=10
    bge $s0, $t0, traque_fin	#Si ligne >= 10, sortir
    
    bltz $s1, traque_fin	#Si colonne < 0, sortir
    li $t0, 10							# t0=10
    bge $s1, $t0, traque_fin	#Si colonne >= 10, sortir
    
    li $t0, 10			#Nombre de colonnes
    mul $t1, $s0, $t0	# $t1 = ligne * 10
    add $t1, $t1, $s1	#$t1 = index dans la grille
    add $t1, $s2, $t1	#$t1 = adresse de la case (grille + index)
    lb $t2, 0($t1)		#$t2 = contenu de la cese
	
    li $t3, 126				# 126 = '~', (tir manqué)
    beq $t2, $t3, traque_fin	# si la case == '~', sortir 

    li $t3, 88				# 88 = 'X', (case deja touché)
    beq $t2, $t3, traque_fin	# si la case =='X', sortir

    lw $t5, nb_coups		# charge nb_coups
    addi $t5, $t5, 1		# nb_coups++
    sw $t5, nb_coups		# on sauvgarde nb_coups
    	 
    li $t3, 46			# 46 =  '.'
    bne $t2, $t3, traqueHit 	# si ce N'est PAS '.' c'est une lettre (un bateau yess!)
	 
    li $t6, 126                	# 126 =  '~'
    sb $t6, 0($t1)	       	# marquer la case comme tir manqué
    jal displayGrille	       	# affiche la grille après le tir
    j traque_fin       # on restaure et sort
    
    traqueHit:
    	lw $t5, nb_coups_but 	# on charge la valeur de nb_coups_but
    	addi $t5, $t5, 1		# nb_coups_but++
    	sw $t5, nb_coups_but 	# sauvgarder nb_coups_but
    	li $t6, 88			# 88 = 'X'
    	sb $t6, 0($t1)		# on remplace de 'X'
    
    	#après coup au but fait un affichage
    	jal displayGrille	
	
    	#nord: (ligne-1,colonne)
    	move $a0, $s2		# $a0 = adresse grille
    	addi $a1, $s0, -1		# $a1 = ligne -1
    	move $a2, $s1		# a2 = colonne
    	jal traque			# appel récursif haut
    
    	#sud: (ligne+1,colonne)	
    	move $a0, $s2		# $a0 = adresse grille
    	addi $a1, $s0, 1		# $a1 = ligne + 1
    	move $a2, $s1		# a2 = colonne
    	jal traque			# appel récursif bas
    
    	#ouest: (ligne,colonne-1)
    	move $a0, $s2		# $a0 = adresse grille
    	move $a1, $s0		# $a1 = ligne
    	addi $a2, $s1, -1		# a2 = colonne -1
    	jal traque			# appel récursif gauche
    
   	 #est: (ligne,colonne+1)
    	move $a0, $s2		# $a0 = adresse grille
   	move $a1, $s0		# $a1 = ligne
   	addi $a2, $s1, 1		# a2 = colonne +1
   	jal traque			# appel récursif droite
	
traque_fin:
    lw $s2, 0($sp)		# on récupère $s2
    lw $s1, 4($sp)		# on récupère $s1
    lw $s0, 8($sp)		# on récupère $s0
    lw $ra, 12($sp)		# on récupère $ra
    addi $sp, $sp, 16		# onlibère la pile
    jr $ra


# The End
exit:
    li $v0, 10      #Chargement appel systeme 10 (Sortie)
    syscall
