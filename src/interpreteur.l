%option yylineno
%option nounput
%option noinput
%{
#include <stdlib.h>
#include "definitions.h"
#include "parser.h"
extern void yyerror(int*,char*);
%}

espace                      [ \t]+
lettre                      [a-zA-Z]
chiffre                     [0-9]

type_i                      [iI][nN][tT]
type_s                      [sS][tT][rR][iI][nN][gG] 
variable                    {lettre}({lettre}|{chiffre})*
if                          [iI][fF]
else                        [eE][lL][sS][eE]

commentaire                 \/\/.*$
chaine                      \".*\"
literal                     {chaine}({espace}*{chaine})*
const_num                   {chiffre}+

rand                        rand\(\)

%%

{espace}        { }
"\n"            { }
";"             { return POINT_VIRGULE; }
{commentaire}   { /*printf("Commentaire: %s\n",yytext);*/ }

"+"             { return PLUS; }
"-"             { return MOINS; }
"\*"            { return MUL; }
"\/"            { return DIV; }
"="             { return EGAL; }
"print"         { return PRINT; }
"("		        { return PAR_G; }
")"             { return PAR_D; }

"{"				{ return SCOPE_E; }
"}"				{ return SCOPE_S; }

"=="			{ return EQ; }
"!="			{ return NE; }
"<"				{ return LT; }
"<="			{ return LE; }
">"				{ return GT; }
">="			{ return GE; }

","             { return CONCAT; }
{type_i}        { return TYPE_I; } 

{type_s}        { return TYPE_S; }

{rand}          { return RAND; }

{if}            { return IF; }

{else}          { return ELSE; }

{literal}          {
        yylval.sVal = yytext; 
        return LITERAL; 
}

{variable}      { 
        yylval.sVal = strdup(yytext);
        return VARIABLE; 
}

{const_num}     { 
        yylval.iVal = atoi(yytext); 
        return NUM; 
}

.               {
        char s[] = "Caractère inconnu: ";
        strcat(s, yytext);
        yyerror(0,s);
}
