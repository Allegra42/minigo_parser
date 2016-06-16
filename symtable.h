#include <string.h>

typedef enum Type {
	INT,
	BOOL,
	CMD,
	CHAN
} Type;


struct symentry {
	char *name;
  	Type symtype;
	int scope;
	struct symentry *next;	
};


symentry *identifier;

symentry *sym_table = (symentry*) 0; // Pointer to sym table


symentry *putsym (int scope, char *sym_name, Type type) {
	
	symentry *ptr = (symentry *) malloc (sizeof(symentry));
	ptr->name = (char *) malloc (strlen(sym_name)+1);
	strcpy (ptr->name, sym_name);
	ptr->symtype = type;
	ptr->scope = scope;
	ptr->next = (struct symentry *)sym_table;
	sym_table = ptr;

	return ptr;
}


symentry *getsym (int scope, char *sym_name) {

	symentry *ptr;
	
	for (ptr = sym_table; ptr != NULL; ptr = (symentry *)ptr->next) {
		if (strcmp (ptr->name, sym_name) == 0 && (ptr->scope == scope)) {
			return ptr;
		}
	}	
	
	return 0;
}
