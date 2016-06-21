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

int typerr = 0;
Type type = CMD;
Type cached_type1 = CMD;

/* install adds an identifier to symtab, if it is not defined in the actual scope, 
   if the identifier is already defined, install throws an error */
void install (int scope, char *sym_name, Type type) {
  symentry *s = getsym (scope, sym_name);
  if (s == NULL) {
    s == putsym (scope, sym_name, type);
   /* cout << "added "<< sym_name << " to symtable scope " << scope << " with type " << type << " at line nr " << linenr <<endl;*/
  }
  else {
    typerr++;
    cout << sym_name << " is already defined in scope " << scope <<" error on line nr "<<linenr<<endl;
  }
}

/* check_context checks if an identifies is defined in a certain scope */
void check_context (int scope, char *sym_name) {
  symentry *identifier = getsym (scope, sym_name);
  if (identifier == NULL || identifier->scope != scope) {
    typerr++;
    cout << sym_name << " is an undeclared identifier in scope " << scope << " at line nr "<<linenr<<endl;
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

/*%token INTS
%token BOOLS */
%token <stringval> LETTER
%token <intval> INTS
%token <boolval> BOOLS

%left BROPEN BRCLOSE SEMICOLON GO ARROW DEF NEWCHAN ASSIGN WHILE PRINT NORMBROPEN NORMBRCLOSE IF ELSE
%left NOT

%left BOOLAND
%left EQUAL
%left GREATER
%left PLUS MINUS
%left TIMES DIVIDE

%%

minigo:
	block  { cout << endl << "File parsed correctly!" << endl; 
                 cout << typerr << " Type Errors!" << endl; } 
    ;
block:
	BROPEN {push();} statement BRCLOSE { scope = pop();}
	;
statement:

	     /* Just CMD type */
	statement SEMICOLON statement { if ((type == CMD) && (cached_type1 == CMD)) {type = CMD;}}
	| GO  block                   { if ((type == CMD) && (cached_type1 == CMD)) {type = CMD;}}

	     /* First check LETTER if it is already defined in this scope in symtab.
		Get the type from symtable if available
	        and check if LETTER is a CHAN there and if aexp is an INT. 
                The type of aexp is passed through */
	| LETTER ARROW aexp           { check_context (scope, $1); symentry *entr = getsym(scope, $1); 
                                        if (entr != NULL) {cached_type1 = entr->symtype;} 
			                if ((cached_type1 == CHAN) && (type == INT)) {type = CMD;
					    /*cout << "correct chan op in line: " << linenr << endl;*/} 
			                else {cout << "incompatible chan op in line: " << linenr << endl;
                                             typerr++;}} 

	     /* Just check if LETTER is defined in latest scope */
	| ARROW LETTER                { check_context (scope, $2);} 

	     /* Check if last LETTER is defined in this scope, if not the whole statement is a typedesaster.
		If it is defined, check if the first is defined in this scope. If, it is an error, if not, 
		add it to symtab -> install check this itself*/
	| LETTER DEF ARROW LETTER     { check_context (scope, $4); symentry *entr = getsym(scope, $4);
				        if ((entr != NULL) && (entr->symtype == INT)) 
			                {  install (scope, $1, INT); 
					/*cout << "correct chan op: latest varname defined at line: " 
					<< linenr << endl;*/}
					else { cout << "second varname is undefined or not INT," << 
					"not possible to add the first varname to symtab complete " <<
					"statement is wrong at line: " << linenr << endl; typerr++;} }

	     /* Just test LETTER and install in symtab and scope if not defined. Install () do the rest */
	| LETTER DEF bexp             { install (scope, $1, type);}
	| LETTER DEF NEWCHAN          { install (scope, $1, CHAN); type = CMD;} 
           
	     /* Just get sure LETTER is already defined in this scope */
	| LETTER ASSIGN bexp          { check_context (scope, $1);}

	    /* For WHILE and IF check the passed trough type from bexp */	
	| WHILE bexp block            { if (cached_type1 == BOOL) 
                                        {/*cout << "correct while at line: " << linenr<<endl;*/}
                                        else { cout << "wrong while condition at line: " << linenr << endl;
					typerr++;}} 
        | IF bexp block ELSE block    { if (cached_type1 == BOOL) 
                                        {/*cout << "correct if at line: " << linenr << endl;*/}
					else { cout << "wrong if condition at line: " << linenr << endl;
					typerr++;}}
	| PRINT aexp 
	;

/* For a correct bexp, all types must be BOOLs -> it is not possible to check the type
   of them at the level of this rule. The types needs to be passed trough from lower levels
   in the parse tree.  */
bexp: 
	bexp BOOLAND cexp  { if ((type == BOOL) && (cached_type1 == BOOL)) {/*cout << "correct && at line: " 
		                << linenr << endl;*/ type = BOOL;}
			     else {cout << "not possible to compare something else than BOOLs at line: " 
			        << linenr << endl; type = CMD; typerr++;}}
	| cexp 
	;

/* For a corrext cexp and cterm, all types must be from the same type. 
   Here it is not possible to check the type, too.
   So the types are also passed trough. */
cexp:
	cterm EQUAL cterm  { if (type == cached_type1) {/* cout << "correct == at line: " << linenr << endl;*/
			        type = BOOL; }
			     else { cout << "not possible to compare incompatible types at line: " << linenr
			        << endl; type = CMD; typerr++;}}
	| cterm 
	;
cterm:
	aexp GREATER aexp  { if (type == cached_type1) {/* cout << "correct > at line: " << linenr << endl;*/ 
	                        type = BOOL;}
			     else { cout << "not possible to compare incompatible types at line: " << linenr 
	                        << endl; type = CMD; typerr++;}}
	| aexp
	;

/* For a correct aexp and term, all types must be INTs. Types needs to be passed trough. */
aexp: 
	aexp PLUS term     { if ((type == INT) && (cached_type1 == INT)) {type = INT; 
                                /*cout << "correct addition at line: " << linenr << endl;*/ } 
                             else { cout << "its not allowed to add something else than INTs at line: " 
                                << linenr << endl; typerr++;}}
	| aexp MINUS term  { if ((type == INT) && (cached_type1 == INT)) {type = INT; 
                                /*cout << "correct subtraction at line: " << linenr << endl;*/ } 
                             else { cout << "its not allowed to subtract something else than INTs at line: " 
                                 << linenr << endl; typerr++;}}
	| term               
	;
term:
	factor  
	| term TIMES factor  { if((type == INT) && (cached_type1 == INT)){type = INT;
			          /*cout << "correct multiplication at line: " << linenr << endl;*/}
                               else {cout << "it is not allowed to multiply something else than INTs at line: "
 		                << linenr << endl; typerr++;} }  
	| term DIVIDE factor { if((type == INT) && (cached_type1 == INT)){type = INT; 
                                  /*cout << "correct division at line: " << linenr << endl;*/} 
                               else {cout << "it is not allowed to divide something else than INTs at line: "
                                   <<linenr << endl; typerr++;} }   
	;

/* Here is one possible point to check the types in symtable. All passed trough types came from this point.
   INTS and BOOLS were found by the lexer. Just for variables, we need to check the symtable. */
factor:
	INTS       {cached_type1 = type; type = INT; } 
	| BOOLS    {cached_type1 = type; type = BOOL; }
	| LETTER   {symentry *entr = getsym(scope, $1); if (entr != NULL) 
                    {cached_type1 = type; type = entr->symtype;} 
                    else {cached_type1 = type; type = CMD; cout << $1 << " is not defined in scope " 
                    << scope << " at line: " << linenr << endl; typerr++;}} 
	| NOT factor 
	| NORMBROPEN bexp NORMBRCLOSE 
	;

%%

int main (int argc, char **argv) {
  memset (int_scope, 't', 50);

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
