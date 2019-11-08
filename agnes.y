%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <map>
#include <math.h>
using namespace std;

// Stockage des variables
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

/* Variable et adresses */
%token<aNumber> NUMBER
%token<aString> VARIABLE

/* Math */
%token COS SIN TAN
%token PLUS MINUS MULTIPLY DIVIDE
%token EQUAL PI
%token RANDD RANDE
%token CONCAT
%token RAD DEG
%token ENT DEC

/* Parentheses */
%token LP RP /* ( ) */
%token LC RC /* [ ] */
%token LA RA /* { } */

/* Autre ... */
%token SEPARATOR PRINT BETWEEN

/* Gestion de l'associativité */
%left PLUS MINUS
%left MULTIPLY DIVIDE
%left BETWEEN

/* Gestion des types */
%type<aNumber> number
%type<aNumber> instructions
%type<aNumber> functions

%start lines

/*** GESTION DES REGLES A RESPECTER ***/
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
	NUMBER 														{ $$ = $1; }
	| PI 															{ $$ = M_PI; }
  | LP number RP 										{ $$ = $2; }
	| RANDE number BETWEEN number			{ int m = $4-$2; $$ = rand() % m + $2; }
	| ENT LC number BETWEEN number RC { int m = $5-$3; $$ = rand() % m + $3; }
	| instructions										{ $$ = $1; }
	| functions												{ $$ = $1; }
	| VARIABLE												{ if(!variable.count($1)) UnknownVarError($1); else $$ = variable[$1]; }
;

instructions:
	number PLUS number 						  	{ $$ = $1 + $3; }
	| number MINUS number							{ $$ = $1 - $3; }
	| number MULTIPLY number 					{ $$ = $1 * $3; }
	| number DIVIDE number						{ $$ = $1 / $3; }
;

functions:
	COS LP number RP 			  					{ $$ = cos($3); }
	| SIN LP number RP 								{ $$ = sin($3); }
	| TAN LP number RP 								{ $$ = tan($3); }
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
