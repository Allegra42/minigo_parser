#include <stdio.h>
#include <string.h>

#define STACKSIZE 50

char int_scope [STACKSIZE];
int scope = 0;

struct my_stack{
	int stack[STACKSIZE];
	int top = -1;
}; 


my_stack *stack = (my_stack *) malloc (sizeof(my_stack));

void push (void) {
	while (int_scope[scope] == 'f' || int_scope[scope] == 'c') {
		if (scope < STACKSIZE) {
			scope++;
		} else {
			printf ("1. stack is full \n ");
			return;
		}
	}
	if (stack->top >= (STACKSIZE -1)) {
		printf ("stack is full \n");
		return;
	}
	else {
		stack->top++;
		stack->stack[stack->top] = scope;
		int_scope[scope] = 'f';
	}
}

int pop (void) {
	int num;
	if (stack->top == -1) {
		printf ("stack is empty \n");
		return -1;
	}
	else {
		int_scope[scope] = 'c';
		stack->top--;
		num = stack->stack[stack->top];
	}
	return num;
}


