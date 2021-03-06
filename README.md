# ProjetAgnes
Développement d'un langage de programmation

## I - Particularité du language

Ce langage est un langage mathématique, il vous permet de pouvoir automatiser certaine opération facilement et dans la langue de Molière !

### Quelques petites choses à connaitre : ###

* A la fin d'une instruction, veillez à mettre un `;`
* Pour ajouter un commentaire, rien de plus simple, `/* commentaire */`.

## II - Arithmétique
* Nombre `1 2.5 3.9 ...`
* Nombre négatif `-1 -2.5 -3.9...`
* Addition
  * `+` `Nombre + Nombre`
  * `plus` `Nombre plus Nombre`
* Soustraction
  * `-` `Nombre - Nombre`
  * `moins` `Nombre moins Nombre`
* Division
  * `/` `Nombre / Nombre`
  * `divise` `Nombre divise Nombre`
* Multiplication
  * `*` `Nombre * Nombre`
  * `fois` `Nombre fois Nombre`
* Gestion de priorité
  * `()` `Nombre * (Nombre + Nombre)`
  * `parenthèse gauche parenthèse droite` `Nombre fois parenthèse gauche Nombre + Nombre parenthèse droite`

*L'opération situé dans les parenthèses sera prioritaire*

## III - Gestion des variables
* Déclaration de variable
  * `=` `var =`
  * `egal` `var egal`
* Déclaration d'une variable comme opération de deux autres `a=a+b;`
  * `var = var + var`
  * `var egal var plus var`

## IV - Fonctions de base
### Arithmétique

* Fonction exponentielle _bientot_
  * `exp()` `exp(Nombre)`
  * `exponentielle()` `exponentielle(Nombre)`
* Nombre pi `pi` _bientot_
* Nombre aléatoire _bientot_
  * `rand` `rand(Nombre)`
  * `aleatoire` `aleatoire(Nombre)`
* Fonction factoriel 
  * `!` `Nombre!`
  * `factoriel` `factoriel(Nombre)`

### Géometrique
* Fonction sinus _bientot_
  * `sin` `sin(Nombre)`
  * `sinus` `sinus(Nombre)`
* Fonction cosinus _bientot_
  * `cos` `cos(Nombre)`
  * `cosinus` `cosinus(Nombre)`

### Affichage

* Pour afficher une variable, un texte ou même un nombre :
  * `>>`
  * `afficher`
  
* Pour demander une entrée utilisateur :
  * `<<`

## V - Conditions (IF)
### Conditions
* Est diffèrent de
  * `a!=b`
  * `a different de b`
* Est égal à
  * `a==b`
  * `a égal à b`
* Est supérieur ou égal à
  * `a>=b`
  * `a supérieur ou égal à b`
* Est inférieur ou égal à
  * `a<=b`
  * `a inférieur ou égal à b`
* Est strictement inférieur à
  * `a<b`
  * `a inférieur à b`
* Est strictement supérieur à
  * `a>b`
  * `a supérieur à b`

### Forme
* Si, sinon
```
  Si(condition){
    /* Instruction */
  }
  Sinon{ /* (facultatif) */
    /* Instruction */
  }
```

## VI - Boucles
* Boucle Pour (FOR)
```
Pour(itérateur=0;itérateur<valeur;itérateur=équation){
  /* Instruction */
}

```

* Boucle Tant que (WHILE)
```
Tant que(a<b){
  /* Instruction */
}
```

## V - Fonction Spéciale

* Bitcoin
```
afficher btc;
```
