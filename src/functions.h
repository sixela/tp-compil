/*
* enterScope:
*   @param Scope *s :       Le scope que l'on créé
*   @param Scope *parent:   Le scope parent
*   @return: Scope *s       Le scope créé
*
*   Créer une scope et le lie à son scope parent
*/
Scope* enterScope(Scope *s, Scope *parent)
{
    s = (Scope *)malloc(sizeof(Scope));
    if(parent)
    {
    	parent->enfant = s;
	    s->parent = parent;
    }
    else
    {
        s->parent = NULL;
    }
    s->varlist = NULL;
    s->enfant = NULL;
    return s;
}

/*
* detruireVarList:
*   @param Scope *s:    Le scope dont on veut détruire les variables
*   @return void
*
*   Détruit la liste des variables d'un scope
*/
void detruireVarList(Scope *s)
{
    if(s->varlist != NULL)
    {
	    Var *pos = s->varlist;
	    while(pos->next)
	    {
			pos = pos->next;
			free(pos->prev);
	    }
	    free(pos);
    }
}

/*
* exitScope:
*   @param Scope *s:    Le scope dont on sort
*   @return Scope *s:   Le scope parent de celui dont on est sorti
*
*   Détruit un scope dont on sort ainsi que ses variables
*/
Scope* exitScope(Scope *s)
{
    Scope *temp = s->parent;
    detruireVarList(s);
    free(s);
    temp->enfant = NULL;
    return temp;
}

/*
* declareVar:
*   @param Scope *s:    Le scope où l'on déclare la variable
*   @param char *name:  Le nom de la variable
*   @return Var*:       La variable crée
*
*   Enregistre une variable dans un scope donné. 
*   Créé la liste de variables du scope au besoin
*/
Var* declareVar(Scope *scope,int type,char *name)
{
    Var *pos, *pp;
    if(scope->varlist)
    {
        pos = scope->varlist;
        while(pos->next)
            pos = pos->next;
        pp = pos->next = (Var *)malloc(sizeof(Var));
    }
    else
    {
        scope->varlist = (Var *)malloc(sizeof(Var));
        pp = scope->varlist;
    }

    pp->type = type;
    pp->nom = strdup(name);
    pp->v.i = 0;
    pp->v.s = "";
    pp->next = NULL;

    return pp;
}

/*
* getVarFromScope:
*   @param Scope *s:    Le scope où l'ont souhaite trouver la variable
*   @param char *name:  Le nom de la variable recherchée
*   @return Var*:       La variable trouvée ou NULL
*
*   Cherche une variable dans un scope (et dans celui-ci seulement)
*/
Var* getVarFromScope(Scope *s, char *name)
{
	if (s->varlist == NULL)
		return NULL;
	Var *pos = s->varlist;
	while(pos)
    {
       	if(strcmp(pos->nom,name) == 0)
       	{
       	    return pos;
       	}
   	    pos = pos->next;
   	}
   	return NULL;
}

/*
* getVar:
*   @param Scope *s:    Le scope de départ
*   @param char *name:  Le nom de la variable recherchée
*   @return Var*:       La variable trouvée ou NULL
*   
*   Chercher une variable à partir d'un scope et remonte dans les scopes
*   si besoin
*/
Var* getVar(Scope *s, char* name)
{
    if(s == NULL)
        return NULL;

    if(s->varlist == NULL)
    {
        if(s->parent)
            s = s->parent;
        else
            return NULL;
    }

    Var *v = getVarFromScope(s,name);
    if(v)
        return v;
    else
    {
        while(s->parent)
        {
            s = s->parent;
            v = getVarFromScope(s,name);
            if(v)
                return v;
        }
    }
    return NULL;
}

/*
* push:
*   @param Stack *s:    La pile où poser un élément
*   @param int value:   La valeur de l'élément à poser
*   @return:            Un pointeur vers le haut de la pile
*
*   Pose un élément sur une pile
*/
Stack* push(Stack* s, int value)
{
    Stack *top;
    if(s == NULL)
    {
        s = (Stack*)malloc(sizeof(Stack));
        s->val = value;
        s->below = NULL;
        top = s;
    }
    else
    {
        top = (Stack*)malloc(sizeof(Stack));
        top->below = s;
        top->val = value;
    }

    return top;
}

/*
* pop:
*   @param Stack *s:    La pile d'où retirer un élément
*   @return int:        La valeur de l'élement dépilé
*
*   Dépile et renvoie un élément d'une pile
*/
int pop(Stack* s)
{
    if(s == NULL)
        exit(-1);

    int ret = s->val;
    if(s->below)
        s = s->below;
    else
    {
        free(s);
        s = NULL;
    }

    if(s==NULL)
        return -1;
    else
        return ret;
}

/*
* can_exectute:
*   @param Stack *s:    Une pile
*   @return int:        0 ou 1
*
*   Retourne la valeur du haut d'une pile
*   ou 0 si la pile n'existe pas
*/
int can_execute(Stack* s)
{
    if(s == NULL)
        return 0;
    else
        return s->val;
}
