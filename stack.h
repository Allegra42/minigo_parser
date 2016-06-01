#include <stdio.h>

#define STACKSIZE 30


struct my_stack{
	int stack[STACKSIZE];
	int top = -1;
}; 

//typedef struct stack Stack;

my_stack *stack = (my_stack *) malloc (sizeof(my_stack));

void push (int nr) {
	if (stack->top == (STACKSIZE -1)) {
		printf ("stack is full \n");
		return;
	}
	else {
		stack->top++;
		stack->stack[stack->top] = nr;
	}
}

int pop (void) {
	int num;
	if (stack->top == -1) {
		printf ("stack is empty \n");
		return -1;
	}
	else {
		num = stack->stack[stack->top];
		stack->top--;
	}
	return num;
}


