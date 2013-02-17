/****************************************
* Fichier de définition des structures 	*
* de données utilisées pour la gestion	*
* des variables, des scopes et des	*
* conditionelles.			*
****************************************/
#ifndef __DEF
#define __DEF

#include <stdio.h>
#include <string.h>

/*
L'énumération ltype nous permet de définir des macros
pour le type d'une variable : 0=int 1=string.
*/
enum ltype
{
    t_int,
    t_string
};

/*
Ce type permet de stocker la valeur de la variable : 
valeur entière ou en chaine de caractère.
*/
typedef union
{
    int i;
    char* s;
}value;

/*
Définition d'une liste de variables.
Cette structure contient les nom de la variable,
son type et sa valeur. La structure en liste doublement
chainée permet d'éviter la réallocation de mémoire à chaque
ajout de variables.
*/
typedef struct var
{
    char *nom;
    int type;
    value v;
    struct var* next;
    struct var* prev;
}Var;

/*
Définition d'une liste de scope.
Cette structure est une liste doublement chainée
qui nous permet de remonter dans les scope parent
afin de récupérer leurs listes de variables.
*/
typedef struct scope
{
   Var* varlist;
   struct scope* enfant;
   struct scope* parent;
}Scope;

/*
Cette structure est utilisée pour le format de retour d'
une expression dans le parseur.
*/
typedef struct
{
    int type;
    value val;
}Composed;

/* 
Définition d'une pile.
Cette structure est utilisée pour la gestion
des conditionelles.
*/
typedef struct stack
{
    int val;
    struct stack *below;
}Stack;

#endif
