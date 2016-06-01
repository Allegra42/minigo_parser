minigo.tab.c minigo.tab.h: minigo.y symtable.h stack.h
	bison -d minigo.y

lex.yy.c: minigo.l minigo.tab.h 
	flex minigo.l

minigo: lex.yy.c minigo.tab.c minigo.tab.h symtable.h stack.h
	g++ minigo.tab.c lex.yy.c -lfl -o minigo


