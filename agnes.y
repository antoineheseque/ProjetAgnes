%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <map>
using namespace std;
map<string,double> variable;

extern int yyerror(char *);
extern int yylex(void);
void Div0Error(void);
void UnknownVarError(string s);
%}

%union {
	double aNumber;
	char aString[256];
}

%token<aNumber> NUMBER
%token<aString> VARIABLE
%token PLUS MINUS MULTIPLY DIVIDE LEFT RIGHT
%token SEPARATOR PRINT EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE

%type<aNumber> number

%start lines
/*** PARTIE DEUX ***/
%%
lines:
	lines line
	| line
;

line:
	PRINT number SEPARATOR 						{ printf("%g\n", $2); }
  | VARIABLE EQUAL number SEPARATOR { variable[$1] = $3; }
;

number:
		NUMBER 													{ $$ = $1; }
	  | number PLUS number 						{ $$ = $1 + $3; }
	  | number MINUS number						{ $$ = $1 - $3; }
	  | number MULTIPLY number 				{ $$ = $1 * $3; }
	  | number DIVIDE number					{ $$ = $1 / $3; }
	  | LEFT number RIGHT 						{ $$ = $2; }
		| VARIABLE											{ if(!variable.count($1)) UnknownVarError($1); else $$ = variable[$1]; }
;
%%

void  Div0Error(void) {
	printf("[Erreur] Division par zero impossible\n");
	exit (0);
}
void  UnknownVarError(string s) {
	printf("[Erreur] La variable %s n'existe pas.\n", s.c_str ());
	exit (0);
}
