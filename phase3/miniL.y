/* cs152-miniL phase3 */

%{
  #define YY_NO_UNPUT
  #include <stdio.h>
  #include <stdlib.h>
  #include <map>
  #include <string.h>
  #include <set>

  int tempCount = 0;
  int labelCount = 0;
  extern char* yytext;
  extern int currPos;

  std::map<std::string, std::string> varTemp;
  std::map<std::string, int> arrSize;
  bool mainFunc = false;
  std::set<std::string> funcs;
  std::set<std::string> reserved {"NUMBER", "IDENT", "RETURN", "FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", 
    "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "FOR", "DO", "BEGINLOOP", "ENDLOOP",
    "CONTINUE", "READ", "WRITE", "TRUE", "FALSE", "SEMICOLON", "COLON", "COMMA", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", 
    "R_SQUARE_BRACKET", "ENUM", "ASSIGN", "OR", "AND", "NOT", "LT", "LTE", "GT", "GTE", "EQ", "NEQ", "ADD", "SUB", "MULT", "DIV", "MOD",
    "function", "declaration", "declarations", "identifiers", "ident", "statements", "statement", "bool_exp", "relation_and_exp",
    "relation_exp", "comp", "expression", "mult_exp", "term", "var", "varLoop", "expressions"};
void yyerror(const char *msg);
extern int yylex();

#include "lib.h"

%}

%union {
  int int_val;
}

%error-verbose

%token<int_val> DIGIT
%start program 

%% 

  /* write your rules here */
program: DIGIT {}

%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
}