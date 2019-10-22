/* scanner for a toy Pascal-like language */

%{

/* need this for the call to atof() below */
#include <math.h>

%}

%option noyywrap

NOMBRE    [0-9]
ID       [a-z][a-z0-9]*
FRACTION       [0-9]+"/"[0-9]

%%

{NOMBRE}+		{
					printf( "Un entier: %s (%d)\n",
              		yytext,atoi( yytext ) );
				}
{FRACTION}+		{
					printf( "Une fraction: %s (%d)\n",
				       		yytext,atoi( yytext ) );
				}

{NOMBRE}+"."{NOMBRE}*		{printf( "Un flottant: %s (%g)\n", yytext,atof( yytext ) );}

si|alors|debut|fin|fonction|sortir|continuer        {printf( "Un mot clé: %s\n", yytext );}
boucle|pour        {printf( "Une boucle: %s\n", yytext );}
afficher|retourner        {printf( "Valeur Retour: %s\n", yytext );}

{ID}				printf( "Un identificateur: %s\n", yytext );

"+"|"-"|"*"|"/"		printf( "Un opérateur: %s\n", yytext );
"="		printf( "Assignation: %s\n", yytext );
"sin"|"cos"|"tan"	printf( "Trigonométrie: %s\n", yytext );
";"	printf( "Fin de ligne: %s\n", yytext );
"(" | ")" | "[" | "]"	printf( "Parenthèse Crochet: %s\n", yytext );

"//"		printf( "Un commentaire: %s\n", yytext );

"{"[\^{}}\n]*"}"	/* eat up one-line comments */

[ \t\n]+			/* eat up whitespace */

.					printf( "Caractère non reconnu: %s\n", yytext );

%%

int main( int argc, char **argv )
{
	++argv, --argc;  /* skip over program name */
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		yyin = stdin;
	yylex();
}
