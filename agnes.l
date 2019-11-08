/*** Definition SECTION ***/
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <time.h>
	#include <string>
	#include "agnes.tab.h"

	using namespace std;
	int yyerror(char *);
	int yylex(void);
%}
%option yylineno

/*** Rules SECTION ***/
%%
[ \t\n]+											; // ignore all whitespace
\/[*]([^*]|([*][^/]))*[*]+\/ 	{ } // printf("%s\n", yytext); A rajouter si on veux afficher les commentaires
pi|PI|π												{ return PI; }
"cos"|"cosinus"								{ return COS; }
"sin"|"sinus"									{ return SIN; }
"tan"|"tangente"							{ return TAN; }
";"|"point virgule" 					{ return SEPARATOR; }
"+"|"plus"|"et" 							{ return PLUS; }
"-"|"moins"								   	{ return MINUS; }
"*"|"fois"|"multiplié par"		{ return MULTIPLY; }
"/"|"divisé par"							{ return DIVIDE; }
"("|"parenthèse gauche"				{ return LP; }
")"|"parenthèse droite"				{ return RP; }
"["|"crochet gauche"				{ return LC; }
"]"|"crochet droite"				{ return RC; }
"{"|"accolade gauche"				{ return LA; }
"}"|"accolade droite"				{ return RA; }
">>"|"afficher"								{ return PRINT; }
"="|"egal"|"égal"							{ return EQUAL; }
"nombre décimal entre"				{ return RANDD; }
"nombre entier entre"					{ return RANDE; }
"concatener"|"fusionner"		  { return CONCATENATION; }
"en randian"		  						{ return RAD; }
"en degré"|"°"		  					{ return DG; }
[a-zA-Z][a-zA-Z0-9]* 					{ strcpy(yylval.aString, yytext); return VARIABLE; }
[0-9]+(\.[0-9]+)? 						{ yylval.aNumber = atof(yytext); return NUMBER; }
. 														{ }
%%

int yyerror(char* str) {
	fprintf(stderr,"[Erreur][Ligne %d] %s\n",yylineno-1,str);
}

int yywrap(){}

int main(int num_args, char** args) {
	srand (time(NULL));
	if(num_args  != 2) {
		printf("[Erreur] Entrez la commande suivante: ./agnes.Ag nomFichier.a\n");
		exit (0);
	}
	FILE* file = fopen(args[1],"r");
	if(file == NULL) {
		printf("[Erreur] Impossible d'ouvrir le fichier %s\n", args [1]);
		exit (0);
	}
	yyin = file;   // now  flex  reads  from  file
	yyparse();
	fclose(file);
}
