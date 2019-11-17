%{
#include <iostream>
#include <string>
#include <map>
#include <math.h>
#include <vector>

using namespace std;

// structure pour stocker les adresses pour les sauts condistionnels et autres...
typedef struct addr {
  int ic_goto;
  int ic_false;
} t_address;

// Stockage des variables
map<string,double> variable;
vector<pair<int,double>> instruction;
int ic = 0;   // compteur instruction
inline void ins(int c, double d) { instruction.push_back(make_pair(c, d)); ic++;};

extern FILE *yyin;
extern int yyerror(char *);
extern int yylex(void);
void Div0Error(void);
void UnknownVarError(string s);
%}

%union {
	double aNumber;
	char aString[256];
	t_address address;
}

/* Variable et adresses */
%token<aNumber> NUMBER
%token<aString> VARIABLE

/* CONDITIONS */
%token<address> IF
%token ELSE REPEAT JMP COND PRINT

/* Math */
%token PLUS MINUS MULTIPLY DIVIDE
%token EQUAL

/* Parentheses */
%token LP RP /* ( ) */
%token LA RA /* { } */

/* Autre ... */
%token SEPARATOR

/* Gestion de l'associativité */
%left PLUS MINUS
%left MULTIPLY DIVIDE

/* Gestion des types */
%type<aNumber> number
%type<aNumber> instruction

%start bloc

/*** GESTION DES REGLES A RESPECTER ***/
%%
bloc:
	bloc line
	| line
;

line:
PRINT number SEPARATOR 	  					{ ins (PRINT,0);   /* imprimer le résultat de l'expression */ }
  | IF LP instruction RP            { $1.ic_goto = ic; ins (COND,0); }
    LA bloc RA                      { $1.ic_false = ic; ins (JMP,0); instruction[$1.ic_goto].second = ic; }
    ELSE  LA bloc RA                { instruction[$1.ic_false].second = ic; }
  | VARIABLE EQUAL number SEPARATOR { variable[$1] = $3; }
;

number:
	NUMBER 														{ ins(NUMBER, $1); }
  | LP number RP 										{ }
	| instruction	   									{ }
	| VARIABLE												{ ins(NUMBER, variable[$1]); } /*if(!variable.count($1)) UnknownVarError($1); else $$ = variable[$1];*/
;

instruction:
	number PLUS number 						  	{ ins('+', 0); }
	| number MINUS number							{ ins('-', 0); }
	| number MULTIPLY number 					{ ins('*', 0); }
	| number DIVIDE number						{ ins('/', 0); }
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

double unstack(vector<double> &stack) {
  double t = stack[stack.size()-1];
  stack.pop_back();
  return t;
}

void start(){
  vector<double> stack;
  double x,y;

  cout << "Chargement de la pile ..." << endl;

  ic = 0;
  while ( ic < instruction.size() ){
    //cout << "Nbr instructions: " << instruction.size() << endl;
    auto ins = instruction[ic];

    switch(ins.first){
      case '+':
        x = unstack(stack);
        y = unstack(stack);
        stack.push_back(y+x);
        ic++;
        break;
      case '-':
        x = unstack(stack);
        y = unstack(stack);
        stack.push_back(y-x);
        ic++;
        break;
      case '*':
        x = unstack(stack);
        y = unstack(stack);
        stack.push_back(y*x);
        ic++;
        break;
        case '/':
          x = unstack(stack);
          y = unstack(stack);
          stack.push_back(x/y);
          ic++;
          break;
      case NUMBER :
        stack.push_back(ins.second);
        ic++;
        break;
      case JMP :
        ic = ins.second;
        break;
      case COND :
        x = unstack(stack);
        ic = ( x ? ic + 1 : ins.second);
        break;
      case PRINT :
        cout << unstack(stack) << endl;
        ic++;
        break;
    }
  }
}

int main(int argc, char **argv) {
  cout << "Démarrage du programme ..." << endl;
	srand (time(NULL));
	if(argc  != 2) {
    cout << "[Erreur] Entrez la commande suivante: ./agnes.Ag nomFichier.a" << endl;
    cout << "[Erreur] Passage en mode console." << endl;
		yyin = stdin;
	}
	FILE* file = fopen(argv[1],"r");
	if(file == NULL) {
    cout << "[Erreur] Aucun fichier " << argv[1] << " trouvé, passage en mode console." << endl;
		yyin = stdin;
	}
	else{
		yyin = file;   // now  flex  reads  from  file
	}
  yyparse();

  cout << "Fichier ouvert." << endl;

  start();
	fclose(file);
}
