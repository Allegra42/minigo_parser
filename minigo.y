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


/*%union {
  int intval;
  bool boolval;
  char *stringval;
}
*/

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

%token INTS
%token BOOLS
%token LETTER
/*%token <intval> INTS
%token <boolval> BOOLS
%token <stringval> LETTER
*/

%left BROPEN BRCLOSE SEMICOLON GO ARROW DEF NEWCHAN ASSIGN WHILE PRINT NORMBROPEN NORMBRCLOSE
%left NOT

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
	| LETTER ARROW aexp {$$ = $3; }
	| ARROW LETTER {$$ = 1; }
	| LETTER DEF bexp {$$ = $3; }
	| LETTER DEF NEWCHAN {$$ = 1; } 
	| LETTER ASSIGN bexp {$$ = $3; }
	| WHILE bexp block {$$ = $2; }
	| PRINT aexp {$$ = $2; cout << "print: " << $2 << endl; }
	;
bexp: 
	| bexp BOOLAND cexp {$$ = ($1 && $3); } 
	| cexp {$$ = $1; }
	;
cexp:
	cterm EQUAL cterm {$$ = ($1 == $3); }
	| cterm {$$ = $1; }
	;
cterm:
	aexp GREATER aexp {$$ = ($1 > $3); }
	| aexp {$$ = $1; }
	;
aexp: 
	aexp PLUS term {$$ = $1 + $3; cout << "$$= " << $$ << endl;} 
	| aexp MINUS term {$$ = $1; }
	| term {$$ = $1; }
	;
term:
	factor {$$ = $1; }
	| term TIMES factor {$$ = $1 * $2; } 
	| term DIVIDE factor {$$ = $1 / $3; }  
	;
factor:
	INTS {$$ = $1; }
	| BOOLS {$$ = $1; } 
	| LETTER {$$ = $1; }
	| ARROW LETTER  {$$ = 1; } 
	| NOT factor {$$ = $1; }
	| NORMBROPEN bexp NORMBRCLOSE {$$ = $1; }
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
