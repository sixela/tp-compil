#include <stdio.h>
#include <stdlib.h>
#include <time.h>
extern int yyparse();
extern FILE *yyin;

int main(int argc, char** argv)
{
    srand(time(NULL));

    if(argc < 2)
    {
        fprintf(stderr, "Missing file argument\n");
        exit(EXIT_FAILURE);
    }

    FILE *finput = fopen(argv[1],"r");

    if(!finput)
    {
        fprintf(stderr, "Error opening the file\n");
        exit(EXIT_FAILURE);
    }
    
    // On redirige la lecture du yyparse vers notre ficher en redéfinissant yyin
    yyin = finput;
    int ret = 0;

    // On passe un argument à la fonction pour savoir quoi retourner comme code de fin
    // d'exécution
    yyparse(&ret);

    fclose(finput);

    return ret;
}
