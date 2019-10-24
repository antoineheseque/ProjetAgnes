%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%union {
	int aInt;
	float aFloat;
}

%token<aInt> INT
%token<aFloat> FLOAT
%token PLUS MINUS MULTIPLY DIVIDE LEFT RIGHT
%token NEWLINE
%left PLUS MINUS
%left MULTIPLY DIVIDE

%type<aInt> intLine
%type<aFloat> floatLine

%start rules

/*** PARTIE DEUX ***/
%%
rules:
	   | rules line
;

line: NEWLINE
    | floatLine NEWLINE { printf("\tResult: %f\n", $1); }
    | intLine NEWLINE { printf("\tResult: %i\n", $1); }
;

floatLine:
		FLOAT { $$ = $1; }
	  | floatLine PLUS floatLine { $$ = $1 + $3; }
	  | floatLine MINUS floatLine { $$ = $1 - $3; }
	  | floatLine MULTIPLY floatLine { $$ = $1 * $3; }
	  | floatLine DIVIDE floatLine { $$ = $1 / $3; }
	  | LEFT floatLine RIGHT { $$ = $2; }
	  | intLine PLUS floatLine { $$ = $1 + $3; }
	  | intLine MINUS floatLine { $$ = $1 - $3; }
	  | intLine MULTIPLY floatLine { $$ = $1 * $3; }
	  | intLine DIVIDE floatLine { $$ = $1 / $3; }
	  | floatLine PLUS intLine { $$ = $1 + $3; }
	  | floatLine MINUS intLine { $$ = $1 - $3; }
	  | floatLine MULTIPLY intLine { $$ = $1 * $3; }
	  | floatLine DIVIDE intLine { $$ = $1 / $3; }
	  | intLine DIVIDE intLine { $$ = $1 / (float)$3; }
;

intLine: INT { $$ = $1; }
	  | intLine PLUS intLine { $$ = $1 + $3; }
	  | intLine MINUS intLine { $$ = $1 - $3; }
	  | intLine MULTIPLY intLine { $$ = $1 * $3; }
	  | LEFT intLine RIGHT { $$ = $2; }
;
%%

/*** PARTIE TROIS ***/
/*int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}*/
int main() {
  // open a file handle to a particular file:
  FILE *myfile = fopen("example/test.a", "r");
  // make sure it's valid:
  if (!myfile) {
    return -1;
  }
  // set lex to read from it instead of defaulting to STDIN:
  yyin = myfile;

  // lex through the input:
	do {
		yyparse();
	} while(!feof(yyin));

	//return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
