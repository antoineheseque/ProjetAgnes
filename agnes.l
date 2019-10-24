/*** Definition SECTION ***/
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "agnes.tab.h"

	#define YY_DECL int yylex()
%}
%option noyywrap

/*** Rules SECTION ***/
%%
[ \t]	; // ignore all whitespace
[0-9]+\.[0-9]+ { yylval.aFloat = atof(yytext); return FLOAT;}
[0-9]+ { yylval.aInt = atoi(yytext); return INT;}
";" { return SEPARATOR; }
"+" { return PLUS; }
"-"	{ return MINUS; }
"*"	{ return MULTIPLY; }
"/"	{ return DIVIDE; }
"("	{ return LEFT; }
")"	{ return RIGHT; }
[a-zA-Z0-9]+ {  }
\n { } // Permet de ne pas prendre en compte les retour a la ligne en sortie
. ;
%%
