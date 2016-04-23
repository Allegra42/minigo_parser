%{
#include <cstdio>
#include <iostream>
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int linenr;

void yyerror (const char *s);
%}


%union {
  int intval;
  bool boolval;
  char *stringval;
}

%token BROPEN
%token BRCLOSE
%token SEMICOLON
%token GO
%token ARROW
%token DEF
%token NEWCHAN
%token ASSIGN
%token WHILE
%token PRINT
%token BOOLAND
%token EQUAL
%token GREATER
%token PLUS
%token MINUS
%token TIMES
%token DIVIDE
%token NOT
%token NORMBROPEN
%token NORMBRCLOSE

%token <intval> INTS
%token <boolval> BOOLS
%token <stringval> LETTER


%left BOOLAND
%left EQUAL
%left GREATER
%left PLUS MINUS
%left TIMES DIVIDE

%%

minigo:
	block   {cout << "done!" << endl; }
	;
block:
	BROPEN statement BRCLOSE
	;
statement:
	statement SEMICOLON statement
	| GO block
	| LETTER ARROW aexp
	| ARROW LETTER
	| LETTER DEF bexp 
	| LETTER DEF NEWCHAN
	| LETTER ASSIGN bexp
	| WHILE bexp block
	| PRINT aexp
	;
bexp: 
	| bexp BOOLAND cexp 
	| cexp
	;
cexp:
	cterm EQUAL cterm
	| cterm
	;
cterm:
	aexp GREATER aexp
	| aexp
	;
aexp: 
	aexp PLUS term {} 
	| aexp MINUS term {}
	| term {}
	;
term:
	factor
	| term TIMES factor {} 
	| term DIVIDE factor {}
	;
factor:
	INTS 
	| BOOLS 
	| LETTER 
	| ARROW LETTER {}
	| NOT factor {}
	| NORMBROPEN bexp NORMBRCLOSE {}
	;

%%

int main (int argc, char **argv) {
  FILE *myfile = fopen (argv[1], "r");
  if (!myfile) {
    cout << "No file specified or can't open file!" << endl;
    return -1;
  }
  yyin = myfile;

  do {
    yyparse();
  } while (!feof(yyin));
}

void yyerror (const char *s) {
  cout << "Parse error on line: " << linenr << "; Message: " << s << endl;
  exit (-1);
}
