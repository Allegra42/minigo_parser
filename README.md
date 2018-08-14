# Parser and Typechecker for **minigo** language, written in Flex/Bison and C/C++
## Grammar for the language is located in **GRAMMAR**

LIMITATIONS:
- typechecker is just able to check 2 arguments at all operations.
  e.g. 3+foo     -> will be checked correctly
  but  3+foo*bar -> to much arguments
  => limitation from bison; it is not possible to check types from each variable at al locations
     in the parse tree. So the types are manually passed trough and I decided that 2 args are enough here.

- as my design decision, multiple declare a variable is not allowed.
- scopes are limited to 50, can be changed in source code.

