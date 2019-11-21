/*** Definition SECTION ***/
%{
	#include <string>
	// structure pour stocker les adresses pour les sauts condistionnels et autres...
	typedef struct addr {
	  int ic_goto;
	  int ic_false;
	} t_address;

	typedef struct type_ {
	  double aDouble;
	  char aString[256];
		bool aBool;
	} t_type;

	#include "agnes.y.hpp"

	using namespace std;
%}
%option noyywrap
%option yylineno

/*** Rules SECTION ***/
%%
[ \t\n]+																					; // ignore all whitespace
\/[*]([^*]|([*][^/]))*[*]+\/ 											{ } // printf("%s\n", yytext); A rajouter si on veux afficher les commentaires
\"(.*?)\"																					{ strcpy(yylval.aString, yytext); return TEXT; }
pi|PI|π																						{ return PI; }
"cos"|"cosinus"																		{ return COS; }
"sin"|"sinus"																			{ return SIN; }
"tan"|"tangente"																	{ return TAN; }
";"|"point virgule" 															{ return SEPARATOR; }
"+"|"plus"			 																	{ return PLUS; }
"-"|"moins"								   											{ return MINUS; }
"*"|"fois"|"multiplié par"												{ return MULTIPLY; }
"/"|"divisé par"																	{ return DIVIDE; }
"("|"parenthèse gauche"														{ return LP; }
")"|"parenthèse droite"														{ return RP; }
"{"|"accolade gauche"															{ return LA; }
"}"|"accolade droite"															{ return RA; }
">>"|"afficher"																		{ return PRINT; }
"<<"|"entrer"																			{ return INPUT; }
"=="|"egal a"|"égal à"														{ return IFEQUAL; }
"!="|"different de"|"différent de"								{ return IFDIFFERENT; }
"="|"egal"|"égal"																	{ return EQUAL; }
"répéter"|"réitérer" 															{ return REPEAT; }
"tant que"|"Tant que" 														{ return WHILE; }
"si"|"SI"|"Si" 																		{ return IF; }
"Sinon"|"sinon"|"SINON"														{ return ELSE; }
"inférieur à"|"<"|"inferieur a"										{ return INF; }
"supérieur à"|">"|"superieur a"										{ return SUP; }
"inférieur ou égal à"|"<="|"inferieur ou egal a"	{ return INFOREQUAL; }
"supérieur ou égal à"|">="|"superieur ou egal a"	{ return SUPOREQUAL; }
[a-zA-Z][a-zA-Z0-9]* 															{ strcpy(yylval.aString, yytext); return VARIABLE; }
[0-9]+(\.[0-9]+)? 																{ yylval.aDouble = atof(yytext); return NUMBER; }
. 																								{ }
%%

int yyerror(char* str) {
	fprintf(stderr,"[Erreur][Ligne %d] %s\n",yylineno-1,str);
}
