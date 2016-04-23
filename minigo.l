%{ 
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
#include "minigo.tab.h" 

int linenr = 1;
%}

%%

"{"            { return BROPEN; }
"}"            { return BRCLOSE; }
";"	       { return SEMICOLON; }
"go"	       { return GO; }
"<-"           { return ARROW; }
":="           { return DEF; }
"newChannel"   { return NEWCHAN; }
"="            { return ASSIGN; }
"while"        { return WHILE; }
"print"        { return PRINT; }
"&&"           { return BOOLAND; }
"=="           { return EQUAL; }
">"            { return GREATER; }
"+"            { return PLUS; }
"-"            { return MINUS; }
"*"            { return TIMES; }
"/"            { return DIVIDE; }
"!"            { return NOT; }
"("            { return NORMBROPEN; }
")"            { return NORMBRCLOSE; }
[ \t]          ;
\n             { ++linenr;}
"true"         { yylval = 1; return BOOLS; }
"false"        { yylval = 0; return BOOLS; }
[a-z]+[0-9]*[a-z]*  { /*yylval = atoi (yytext);*/ return LETTER; }
[0-9]+         { yylval = atoi (yytext); return INTS; }

%%

/*int main (int, char**) {
  FILE *myfile = fopen ("file.minigo", "r");
  if (!myfile) {
    cout << "cant open file" << endl;
    return -1;
  }
  yyin = myfile;

  yylex();
}
*/
