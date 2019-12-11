%{
#include <SFML/Window.hpp>
#include <SFML/Graphics.hpp>
#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <math.h>
#include <regex>
#include <vector>
#include "libraries/mplib/matplotlibcpp.h"
#include <curl/curl.h>
#include <jsoncpp/json/json.h>
#include <cstdint>
#include <memory>

namespace plt = matplotlibcpp;

using namespace std;

// structure pour stocker les adresses pour les sauts condistionnels et autres...
typedef struct addr {
  int ic_goto;
  int ic_cond;
  int ic_false;
} t_address;

typedef struct type_ {
  double aDouble = 0;
  char aString[256] = "";
  bool aBool;
} type;

// Stockage des variables
map<string,type> variable;
vector<pair<int,type>> instruction;
int ic = 0;   // compteur instruction
inline void ins(int c, type d) { instruction.push_back(make_pair(c, d)); ic++;};

extern FILE *yyin;
extern int yyerror(char *);
extern int yylex(void);
void Div0Error(void);
int GetJSON(string);
int GetGraph(string);
void UnknownVarError(string s);
%}

%union {
	double aDouble;
	char aString[256];
	t_address address;
}

/* Variable et adresses */
%token<aDouble> NUMBER
%token<aString> VARIABLE
%token<aString> TEXT

/* CONDITIONS */
%token<address> IF WHILE FOR
%token ELSE REPEAT JMP COND PRINT REGVAR GETVAR INPUT
%token INF SUP INFOREQUAL SUPOREQUAL IFEQUAL IFDIFFERENT
%token FOR2 FOR3

/* Math */
%token PLUS MINUS MULTIPLY DIVIDE
%token EQUAL PI
%token COS SIN TAN
%token FACT

/* WEB */
%token BTC URL HTML JSON LAUNCH GRAPH

/* Parentheses */
%token LP RP /* ( ) */
%token LA RA /* { } */

/* Autre ... */
%token SEPARATOR

/* Gestion de l'associativité */
%left PLUS MINUS
%left MULTIPLY DIVIDE
%right EXP
%precedence NEG   /* negation--unary minus */

/* Gestion des types */
%type<aDouble> number
%type<aDouble> instruction
%type<aDouble> functions

%start bloc

/*** GESTION DES REGLES A RESPECTER ***/
%%
bloc:
	bloc line
	| line
;

line:
  PRINT print SEPARATOR             { }
  | web SEPARATOR                   { }
  | INPUT VARIABLE SEPARATOR 	  		{ type t; strcpy(t.aString,$2); ins(INPUT,t); }
  | VARIABLE EQUAL number SEPARATOR { type t; strcpy(t.aString,$1); ins(REGVAR,t); }
  | IF LP condition RP              { $1.ic_goto = ic; type t; t.aDouble=0; ins(COND,t); }
    LA bloc RA                      { $1.ic_false = ic; type t; t.aDouble=0; ins(JMP,t); instruction[$1.ic_goto].second.aDouble = ic; }
    elsecond                        { instruction[$1.ic_false].second.aDouble = ic; }

  | WHILE { $1.ic_goto = ic; }
    LP condition RP                 { $1.ic_cond = ic; type t; t.aDouble=0; ins(COND,t); }
    LA bloc RA                      { $1.ic_false = ic;
                                      instruction[$1.ic_cond].second.aDouble = $1.ic_false+1;
                                      type t;
                                      t.aDouble=$1.ic_goto;
                                      ins(JMP,t);
                                    }
  | FOR LP VARIABLE EQUAL number SEPARATOR { type t; strcpy(t.aString,$3); ins(REGVAR,t); $1.ic_goto = ic; }
    condition SEPARATOR             { $1.ic_cond = ic; type t; t.aDouble=0; ins(COND,t); }
    VARIABLE EQUAL number RP        { type t; strcpy(t.aString,$3); ins(REGVAR,t); }
    LA bloc RA                      { $1.ic_false = ic;
                                      instruction[$1.ic_cond].second.aDouble = $1.ic_false+1;
                                      type t;
                                      t.aDouble=$1.ic_goto;
                                      ins(JMP,t);
                                    }
;

elsecond:
  | ELSE LA bloc RA                 { }
;

web:
  LAUNCH LP TEXT RP                 { type t; strcpy(t.aString,$3); ins(LAUNCH,t); }
  | PRINT HTML LP TEXT RP           { type t; strcpy(t.aString,$4); ins(URL,t); }
  | PRINT JSON LP BTC RP            { type t; strcpy(t.aString,"\"https://api.blockchain.info/charts/market-price?format=json\""); ins(URL,t); }
;

print:
  BTC                               { type t; strcpy(t.aString,"\"https://api.blockchain.info/charts/market-price?format=json\""); ins(GRAPH,t); }
  | number  	  				            { type t; t.aDouble=0; ins(PRINT,t); }
  | TEXT              	  			    { type t; strcpy(t.aString,$1); ins(TEXT,t); }
;

number:
	NUMBER 														{ type t; t.aDouble=$1; ins(NUMBER, t); }
  | PI                              { type t; t.aDouble=M_PI; ins(NUMBER, t); }
  | MINUS NUMBER %prec NEG 					{ type t; t.aDouble=-$2; ins(NUMBER, t); }
  | LP number RP 										{ }
	| instruction	   									{ }
  | functions                       { }
	| VARIABLE												{ type t; strcpy(t.aString,$1); ins(GETVAR, t); } /*if(!variable.count($1)) UnknownVarError($1); else $$ = variable[$1];*/
;

condition:
  number INF number 						  	{ type t; t.aDouble=0; ins('<', t); }
  | number SUP number						   	{ type t; t.aDouble=0; ins('>', t); }
  | number INFOREQUAL number 				{ type t; t.aDouble=0; ins('<=', t); }
  | number SUPOREQUAL number				{ type t; t.aDouble=0; ins('>=', t); }
  | number IFEQUAL number				    { type t; t.aDouble=0; ins('==', t); }
  | number IFDIFFERENT number				{ type t; t.aDouble=0; ins('!=', t); }
;

instruction:
	number PLUS number 						  	{ type t; t.aDouble=0; ins('+', t); }
	| number MINUS number							{ type t; t.aDouble=0; ins('-', t); }
	| number MULTIPLY number 					{ type t; t.aDouble=0; ins('*', t); }
	| number DIVIDE number						{ type t; t.aDouble=0; ins('/', t); }
;

functions:
	COS LP number RP 			  					{ type t; t.aDouble=0; ins(COS, t); }
	| SIN LP number RP 								{ type t; t.aDouble=0; ins(SIN, t); }
	| TAN LP number RP 								{ type t; t.aDouble=0; ins(TAN, t); }
  | FACT LP number RP		            { type t; t.aDouble=0; ins(FACT, t); }
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

type unstack(vector<type> &stack) {
  type t = stack[stack.size()-1];
  stack.pop_back();
  return t;
}

string convertText(string text){
  string str = text;
  str = str.substr(1, str.size() - 2);
  return str;
}

void openWebsite(string url){
  string str = "firefox " + convertText(url);
  system(str.c_str());
}

void start(){
  vector<type> stack;
  //type x,y;

  cout << "Chargement de la pile ..." << endl;

  ic = 0;
  while ( ic < instruction.size() ){
    //cout << "Nbr instructions: " << instruction.size() << endl;
    auto ins = instruction[ic];

    type x,y,z; // Initialiser un nouveau type a chaque fois pour le résultat z;
    switch(ins.first){
      case '+':
        x = unstack(stack);
        y = unstack(stack);
        z.aDouble = y.aDouble + x.aDouble;
        stack.push_back(z);
        ic++;
        break;
      case '-':
        x = unstack(stack);
        y = unstack(stack);
        z.aDouble = y.aDouble - x.aDouble;
        stack.push_back(z);
        ic++;
        break;
      case '*':
        x = unstack(stack);
        y = unstack(stack);
        z.aDouble = x.aDouble*y.aDouble;
        stack.push_back(z);
        ic++;
        break;
      case '/':
        x = unstack(stack);
        y = unstack(stack);
        z.aDouble = y.aDouble/x.aDouble;
        stack.push_back(z);
        ic++;
        break;
      case '>':
        x = unstack(stack);
        y = unstack(stack);
        z.aBool = y.aDouble > x.aDouble ? true : false;
        stack.push_back(z);
        ic++;
        break;
      case '<':
        x = unstack(stack);
        y = unstack(stack);
        z.aBool = y.aDouble < x.aDouble ? true : false;
        stack.push_back(z);
        ic++;
        break;
      case '>=':
        x = unstack(stack);
        y = unstack(stack);
        z.aBool = y.aDouble >= x.aDouble ? true : false;
        stack.push_back(z);
        ic++;
        break;
      case '<=':
        x = unstack(stack);
        y = unstack(stack);
        z.aBool = y.aDouble <= x.aDouble ? true : false;
        stack.push_back(z);
        ic++;
        break;
      case '==':
        x = unstack(stack);
        y = unstack(stack);
        z.aBool = y.aDouble == x.aDouble ? true : false;
        stack.push_back(z);
        ic++;
        break;
      case '!=':
        x = unstack(stack);
        y = unstack(stack);
        z.aBool = y.aDouble != x.aDouble ? true : false;
        stack.push_back(z);
        ic++;
        break;
      case NUMBER:
        stack.push_back(ins.second);
        ic++;
        break;
      case GETVAR: // Récupérer la valeur de la VARIABLE
        z.aDouble=variable[ins.second.aString].aDouble;
        stack.push_back(z);
        ic++;
        break;
      case REGVAR: // Enregistrer la VARIABLE
        x = unstack(stack);
        variable[ins.second.aString]=x;
        ic++;
        break;
      case JMP:
        ic = ins.second.aDouble;
        break;
      case COND:
        x = unstack(stack);
        ic = ( x.aBool==true ? ic + 1 : ins.second.aDouble);
        break;
      case PRINT:
        x = unstack(stack);
        cout << x.aDouble << endl;
        ic++;
        break;
      case FACT:
        x = unstack(stack);
        z.aDouble = 1.0;
        for(double i = x.aDouble; i > 1.0; i=i-1.0){
          z.aDouble *= i;
        }
        stack.push_back(z);
        ic++;
        break;
      case COS:
        x = unstack(stack);
        z.aDouble = cos(x.aDouble);
        stack.push_back(z);
        ic++;
        break;
      case SIN:
        x = unstack(stack);
        z.aDouble = sin(x.aDouble);
        stack.push_back(z);
        ic++;
        break;
      case TAN:
        x = unstack(stack);
        z.aDouble = tan(x.aDouble);
        stack.push_back(z);
        ic++;
        break;
      case TEXT:
        cout << convertText(ins.second.aString) << endl;
        ic++;
        break;
      case GRAPH:
        GetGraph(convertText(ins.second.aString));
        ic++;
        break;
      case URL:
        GetJSON(convertText(ins.second.aString));
        ic++;
        break;
      case LAUNCH:
        openWebsite(ins.second.aString);
        ic++;
      case INPUT:
        string str = "";
        getline(cin, str);
        const char *str2 = str.c_str();
        regex number("[0-9]+(.[0-9]+)?");
        if(regex_match(str, number)){
          z.aDouble = stod(str);
        }
        else{
          cout << "Le texte entré n'est pas un nombre. 0 a été entré." << endl;
          z.aDouble = 0;
        }
        variable[ins.second.aString]=z;
        ic++;
        break;
    }
  }
}

string nom(int instruction){
  switch (instruction){
   case '+'     : return "ADDITIO";
   case '*'     : return "MULTIPL";
   case '/'     : return "DIVIDE";
   case '=='    : return "EQUAL";
   case '!='    : return "DIFFERENT";
   case COND    : return "CONDITION";
   case INPUT   : return "INPUT";
   case TEXT    : return "TEXT";
   case GETVAR  : return "GETVAR";
   case COS     : return "COS";
   case SIN     : return "SIN";
   case TAN     : return "TAN";
   case PRINT   : return "PRINT";
   case REGVAR  : return "SETVAR";
   case FACT    : return "FACT";
   case NUMBER  : return "NUM";
   case JMP     : return "JMP";   // Unconditional Jump
   default      : return to_string (instruction);
   }
}

void print_program(){
  system("clear");
  cout << "==== CODE GENERE ====" << endl;
  int i = 0;
  for (auto ins : instruction )
    cout << i++ << '\t' << nom(ins.first) << "\t" << ins.second.aDouble << "\t |\t " << ins.second.aString << endl;
  cout << "=====================" << endl;
}

namespace
{
    size_t callback(
            const char* in,
            size_t size,
            size_t num,
            string* out)
    {
        const size_t totalBytes(size * num);
        out->append(in, totalBytes);
        return totalBytes;
    }
}

int GetGraph(string url)
{
  CURL* curl = curl_easy_init();
  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
  curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
  int httpCode(0);
  std::string* httpData(new std::string());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, callback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, httpData);
  curl_easy_perform(curl);
  curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
  if (httpCode == 200)
  {
      Json::Value jsonData;
      Json::Reader jsonReader;

      if (jsonReader.parse(*httpData, jsonData))
      {
          //cout << jsonData.toStyledString() << endl;
          const string name(jsonData["name"].asString());

          if(name=="Market Price (USD)"){
            // BITCOIN
            vector<double> x, y;
            for(auto i : jsonData["values"]){
              x.push_back(i["x"].asDouble());
              y.push_back(i["y"].asDouble());
              //cout << i["x"] << " | " << i["y"] << endl;
            }
            plt::xkcd();
            plt::figure_size(1200, 780);
            plt::plot(y);
            plt::xlabel("Jours de l'annee derniere jusqu'a aujourd'hui");
            plt::ylabel("Prix en $");
            plt::grid(true);
            plt::title("Courbe du Bitcoin sur 365 Jours (jusqu'a aujourd'hui)");
            plt::show();
          }
          /*const std::string dateString(jsonData["date"].asString());
          const std::size_t unixTimeMs(jsonData["milliseconds_since_epoch"].asUInt64());
          const std::string timeString(jsonData["time"].asString());

          std::cout << "Natively parsed:" << std::endl;
          std::cout << "\tDate string: " << dateString << std::endl;
          std::cout << "\tUnix timeMs: " << unixTimeMs << std::endl;
          std::cout << "\tTime string: " << timeString << std::endl;*/
          cout << endl;
      }
      else
      {
          return 1;
      }
  }
  else
  {
      return 1;
  }

  return 0;
}

int GetJSON(string url)
{
  CURL* curl = curl_easy_init();
  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
  curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
  int httpCode(0);
  std::string* httpData(new std::string());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, callback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, httpData);
  curl_easy_perform(curl);
  curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
  if (httpCode == 200)
  {
      Json::Value jsonData;
      Json::Reader jsonReader;

      if (jsonReader.parse(*httpData, jsonData))
      {
          cout << jsonData.toStyledString() << endl;
      }
      else
      {
          cout << *httpData << endl;
          return 1;
      }
  }
  else
  {
      std::cout << "Impossible de récupérer depuis l'url: " << url << std::endl;
      return 1;
  }

  return 0;
}

int main(int argc, char **argv) {
  cout << "Démarrage du programme ..." << endl;
	srand (time(NULL));
  FILE* file;
	if(argc == 2) {
    file = fopen(argv[1],"r");
  	if(file == NULL) {
      cout << "[Erreur] Aucun fichier " << argv[1] << " trouvé, passage en mode console." << endl << endl;

  		yyin = stdin;
  	}
  	else{
  		yyin = file;   // now  flex  reads  from  file
  	}
	}
  else{
    cout << "[Erreur] Entrez la commande suivante: ./agnes.Ag nomFichier.a" << endl;
    cout << "[Erreur] Passage en mode console." << endl;
		yyin = stdin;
  }
  yyparse();
  //sf::RenderWindow window(sf::VideoMode(800, 600), "My window");

  print_program();
  start();

  fclose(file);


  /*sf::CircleShape shape(100.f);
  shape.setFillColor(sf::Color::Green);

  while (window.isOpen())
  {
      sf::Event event;
      while (window.pollEvent(event))
      {
          if (event.type == sf::Event::Closed)
              window.close();
      }

      window.clear();
      window.draw(shape);
      window.display();
  }*/
  return 0;
}
