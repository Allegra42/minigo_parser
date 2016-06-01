%{
#include <cstdio>
#include <iostream>

#include "symtable.h"
#include "stack.h"

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int linenr;

int scope = 0;
Type type = CMD;

void install (int scope, char *sym_name, Type type) {
  symentry *s = getsym (scope, sym_name);
  if (s == NULL) {
    s == putsym (scope, sym_name, type);
    printf ("added %s to symtable scope %d  with type %d at line nr %d \n", sym_name, scope, type, linenr);
  }
  else {
    printf ("%s is already defined in scope %d, error on line nr %d \n", sym_name, scope, linenr);
  }
}

void check_context (int scope, char *sym_name) {
  symentry *identifier = getsym (scope, sym_name);
  if (identifier == NULL || identifier->scope != scope) {
    printf ("%s is an undeclared identifier in scope %d at line nr %d \n", sym_name, scope, linenr);
  }
}

void yyerror (const char *s);
%}


%union {
/*  int intval;
  bool boolval;*/ 
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
%token IF
%token ELSE
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

%token INTS
%token BOOLS
%token <stringval> LETTER
/*%token <intval> INTS
%token <boolval> BOOLS
%token <stringval> LETTER
*/

%left BROPEN BRCLOSE SEMICOLON GO ARROW DEF NEWCHAN ASSIGN WHILE PRINT NORMBROPEN NORMBRCLOSE IF ELSE
%left NOT

%left BOOLAND
%left EQUAL
%left GREATER
%left PLUS MINUS
%left TIMES DIVIDE

%%

minigo:
	block  { cout << "File parsed correctly!" << endl; } 
	;
block:
	BROPEN {push(++scope);} statement BRCLOSE { scope = (pop() - 1);/*scope = mainscope; */}
	;
statement:
	statement SEMICOLON statement
	| GO  block              
	| LETTER ARROW aexp           { check_context (scope, $1);} 
	| ARROW LETTER                { check_context (scope, $2);} 
	| LETTER DEF ARROW LETTER     { install (scope, $1, INT);}
	| LETTER DEF bexp             { install (scope, $1, type);}
	| LETTER DEF NEWCHAN          { install (scope, $1, CHAN);} 
	| LETTER ASSIGN bexp          { check_context (scope, $1);}
	| WHILE bexp block 
        | IF bexp block ELSE block 
	| PRINT aexp 
	;

bexp: 
	bexp BOOLAND cexp  
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
	aexp PLUS term  
	| aexp MINUS term 
	| term 
	;
term:
	factor 
	| term TIMES factor  
	| term DIVIDE factor   
	;
factor:
	INTS       {type = INT; } 
	| BOOLS    {type = BOOL; }
	| LETTER   {symentry *entr = getsym(scope, $1); if (entr != NULL) {type = entr->symtype;} else {type = UD; cout << $1 << " is not defined in scope " << scope << " at line: " << linenr << endl;}} 
	| NOT factor 
	| NORMBROPEN bexp NORMBRCLOSE 
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
