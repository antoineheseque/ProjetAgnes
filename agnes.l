/*** Definition SECTION ***/
%{
	#include <string>
	#include "agnes.y.hpp"

	using namespace std;
%}
%option noyywrap
%option yylineno

/*** Rules SECTION ***/
%%
[ \t\n]+											; // ignore all whitespace
\/[*]([^*]|([*][^/]))*[*]+\/ 	{ } // printf("%s\n", yytext); A rajouter si on veux afficher les commentaires
";"|"point virgule" 					{ return SEPARATOR; }
"+"|"plus"			 							{ return PLUS; }
"-"|"moins"								   	{ return MINUS; }
"*"|"fois"|"multiplié par"		{ return MULTIPLY; }
"/"|"divisé par"							{ return DIVIDE; }
"("|"parenthèse gauche"				{ return LP; }
")"|"parenthèse droite"				{ return RP; }
"{"|"accolade gauche"					{ return LA; }
"}"|"accolade droite"					{ return RA; }
">>"|"afficher"								{ return PRINT; }
"="|"egal"|"égal"							{ return EQUAL; }
"répéter"|"réitérer" 					{ return REPEAT; }
"si"|"SI"|"Si" 								{return IF;}
"Sinon"|"sinon"|"SINON"				{return ELSE;}
[a-zA-Z][a-zA-Z0-9]* 					{ strcpy(yylval.aString, yytext); return VARIABLE; }
[0-9]+(\.[0-9]+)? 						{ yylval.aNumber = atof(yytext); return NUMBER; }
. 														{ }
%%

int yyerror(char* str) {
	fprintf(stderr,"[Erreur][Ligne %d] %s\n",yylineno-1,str);
}
