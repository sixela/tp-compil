/* Option pour obtenir des erreurs de bison plus verbeuses */
%error-verbose
%defines
%{
#include <stdio.h>
#include <stdlib.h>
#include "definitions.h"
#include "functions.h"
    int yylex(void);
    void yyerror(int*,char const *);
    extern int yylineno;

    /* Variable pour la gestion des scopes */
    Scope *current_scope = NULL;

    /* Variable pour la gestion des If/Else */
    Stack *can_do = NULL;
%}

%union{
    int iVal;
    char* sVal;
    Var vVal;
    Composed cVal;
}

/* Utiliser yyparse avec un paramètre pour lui passer le code retour */
%parse-param {int *return_value}

%start program

%token  <iVal> NUM 
%token  <sVal> TYPE_I TYPE_S VARIABLE LITERAL
%token  PLUS MOINS MUL DIV EGAL PAR_G PAR_D PRINT POINT_VIRGULE RAND IF ELSE EQ NE GT GE LT LE SCOPE_E SCOPE_S CONCAT

%type   <cVal> affectation expr
%type   <iVal> condition

/* Associativité à gauche */
%left   PLUS MOINS
%left   MUL DIV

/* Associativité non définie */
%nonassoc EQ NE GT LT LE GE CONCAT
%nonassoc ELSE

%%

program:
    lignes
    ;

lignes:
    ligne
    | lignes ligne
    | lignes scope
    ;

scope:
    SCOPE_E {  
            if(current_scope == NULL)
                current_scope = enterScope(current_scope,NULL);
            else
                current_scope = enterScope(current_scope->enfant,current_scope);
        } lignes SCOPE_S { 
            current_scope = exitScope(current_scope);
        }
    ;
    

ligne:
    expr POINT_VIRGULE              { 
            if($1.type == t_int)
            {
                *return_value = $1.val.i;
            }
        }  
    | declaration POINT_VIRGULE         
    | affectation POINT_VIRGULE
    | affichage POINT_VIRGULE
    | condition scope { 
            if(pop(can_do)==-1) 
                can_do = NULL; 
        }
    | condition scope { 
            if(can_execute(can_do) == 0)
            {
                if(pop(can_do) == -1)
                    can_do = NULL;
                can_do = push(can_do,1);
            }
            else
            {
                if(pop(can_do) == -1)
                    can_do = NULL;
                can_do = push(can_do,0);
            }
        } ELSE scope { 
            if(pop(can_do)==-1)
                can_do = NULL;
        }
    ;

condition:
    IF PAR_G expr PAR_D             { /* Une string sera toujours évaluée à FAUX */
            if($3.type == t_int)
                $$ = $3.val.i;
            else
                $$ = 1;
            can_do = push(can_do,$$);
        }
    ;

affichage: 
    PRINT PAR_G expr PAR_D          {
            if(can_execute(can_do) == 0)
            {
                if($3.type == t_int)
                    printf("%d",$3.val.i);
                else
                { 
                    Var* v = getVar(current_scope,$3.val.s);
                    if(v)
                    {
                        if(v->type == t_int)
                            printf("%d",v->v.i);
                        else
                            printf("%s",v->v.s);
                    }
                    else
                        printf("%s\n",$3.val.s);
                }
            }
        }

    ;

declaration:
    {
        if(can_execute(can_do) == 0)
        {
            if(current_scope == NULL)
                current_scope = enterScope(current_scope,NULL);
        }
    }
    TYPE_I VARIABLE                 { 
            if(can_execute(can_do) == 0)
            {
                //printList(current_scope->varlist);
                if(getVarFromScope(current_scope,$3) == NULL)
                {
                    declareVar(current_scope,t_int,$3);
                }
                else
                    yyerror(0,"Variable déjà déclarée");
            }
        }
    | TYPE_S VARIABLE               { 
            if(can_execute(can_do) == 0)
            {
                if(getVarFromScope(current_scope,$2) == NULL)
                {
                    declareVar(current_scope,t_string,$2);
                }
                else
                    yyerror(0,"Variable déjà déclarée");
            }
        }
    ;

affectation:
    VARIABLE EGAL expr            
    { 
            if(can_execute(can_do) == 0)
            {
                Var *v = getVar(current_scope,$1);
                if(v==NULL)
                    yyerror(0,"Variable non déclarée");
                else
                {
                    if(v->type != $3.type)
                        yyerror(0,"Types différents");
                    
                    $$.type = v->type;

                    if(v->type == t_int)
                        $$.val.i = v->v.i = $3.val.i;
                    else
                        $$.val.s = v->v.s = strdup($3.val.s);
                }
            }
        } 
    ;

expr:
    NUM                             { if(can_execute(can_do) == 0) { $$.type = t_int; $$.val.i = $1; } }
    | LITERAL                       { if(can_execute(can_do) == 0) { $$.type = t_string; $$.val.s = strndup($1+1, strlen($1)-2); } }
    | RAND                          { if(can_execute(can_do) == 0) { $$.type = t_int; $$.val.i = rand()%2; /*RANDOM*/ } }
    | VARIABLE                      { 
            if(can_execute(can_do) == 0)
            {
                Var *v = getVar(current_scope, $1);
                if(v)
                {
                    $$.type = v->type;
                    if(v->type == t_int)
                        $$.val.i = v->v.i;
                    else
                        $$.val.s = strdup(v->v.s);
                }
            }
        }
    | expr PLUS expr                { 
            if(can_execute(can_do) == 0)
            {
                if($1.type == t_int && $1.type == $3.type)
                    $$.val.i = $1.val.i + $3.val.i;
                else
                    yyerror(0,"Opération invalide");
            }
        }
    | expr MOINS expr               { 
            if(can_execute(can_do) == 0)
            {
                if($1.type == t_int && $1.type == $3.type)
                    $$.val.i = $1.val.i - $3.val.i;
                else
                    yyerror(0,"Opération invalide");
            }
        }
    | expr MUL expr                 { 
            if(can_execute(can_do) == 0)
            {
                if($1.type == t_int && $1.type == $3.type)
                    $$.val.i = $1.val.i * $3.val.i;
                else
                    yyerror(0,"Opération invalide");
            }
        }
    | expr DIV expr                 {
            if(can_execute(can_do) == 0)
            {
                if($1.type == t_int && $1.type == $3.type)
                {
                    if($3.val.i == 0)
                        yyerror(0,"Division par zéro !");
                    $$.val.i = $1.val.i / $3.val.i;
                }
                else
                    yyerror(0,"Opération invalide");
            }
        } 
    | expr CONCAT expr              {
            if(can_execute(can_do) == 0)
            {
                if($1.type == t_string && $3.type == t_string)
                {
                    $$.type = t_string;
                    $$.val.s = strdup($1.val.s);
                    strcat($$.val.s,$3.val.s);
                }
                else
                    yyerror(0,"Concaténation sur les chaînes seulement");
            }
        }
    | expr EQ expr                  {
            if(can_execute(can_do) == 0)
            {
                $$.type = t_int;
                if($1.type == t_int && $3.type == t_int)
                {
                    if($1.val.i == $3.val.i)
                        $$.val.i = 0;
                    else
                        $$.val.i = 1;
                }
                else if($1.type == t_string && $3.type == t_string)
                    $$.val.i = strcmp($1.val.s,$3.val.s);
                else
                    yyerror(0,"Comparaison sur des types différents");
            }
        }
    | expr NE expr                  {
            if(can_execute(can_do) == 0)
            {
                $$.type = t_int;
                if($1.type == t_int && $3.type == t_int)
                {
                    if($1.val.i != $3.val.i)
                        $$.val.i = 0;
                    else
                        $$.val.i = 1;
                }
                else if($1.type == t_string && $3.type == t_string)
                {
                    if(strcmp($1.val.s,$3.val.s))
                        $$.val.i = 1;
                    else
                        $$.val.i = 0;
                }
                else
                    yyerror(0,"Comparaison sur des types différents");
            }
        }
    | expr LT expr                  {
            if(can_execute(can_do) == 0)
            {
                $$.type = t_int;
                if($1.type == t_int && $3.type == t_int)
                {
                    if($1.val.i < $3.val.i)
                        $$.val.i = 0;
                    else
                        $$.val.i = 1;
                }
                else
                    yyerror(0,"< Opérateur disponible sur les nombres seulement");
            }
    }
    | expr LE expr                  {
            if(can_execute(can_do) == 0)
            {
                $$.type = t_int;
                if($1.type == t_int && $3.type == t_int)
                {
                    if($1.val.i <= $3.val.i)
                        $$.val.i = 0;
                    else
                        $$.val.i = 1;
                }
                else
                    yyerror(0,"<= Opérateur disponible sur les nombres seulement");
            }
    }
    | expr GT expr                  {
            if(can_execute(can_do) == 0)
            {
                $$.type = t_int;
                if($1.type == t_int && $3.type == t_int)
                {
                    if($1.val.i > $3.val.i)
                        $$.val.i = 0;
                    else
                        $$.val.i = 1;
                }
                else
                    yyerror(0,"> Opérateur disponible sur les nombres seulement");
            }
    }
    | expr GE expr                  {
            if(can_execute(can_do) == 0)
            {
                $$.type = t_int;
                if($1.type == t_int && $3.type == t_int)
                {
                    if($1.val.i >= $3.val.i)
                        $$.val.i = 0;
                    else
                        $$.val.i = 1;
                }
                else
                    yyerror(0,">= Opérateur disponible sur les nombres seulement");
            }
    }
    ;
    
%%

void yyerror(int* r,char const *s)
{
    fprintf(stderr, "Erreur @ %d: %s\n",yylineno,s);
    exit(-1);
}

int yywrap(void)
{
    return 1;
}
