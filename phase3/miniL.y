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

std::string new_temp();
std::string new_label();

#include "lib.h"

%}

%union {
  int int_val;
  char* ident;
  struct S 
  {
    char* code;
  } statement;
  struct E 
  {
    char* place;
    char* code;
    bool arr;
  } expression;
}

%error-verbose

%start program 

%token <int_val> NUMBER
%token <ident> IDENT
%type <expression> function declarations declaration vars var expressions expression identifiers ident
%type <expression> bool_exp relation_and_exp relation_exp comp mult_exp term
%type <statement> statement statements

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET RETURN
%token ENUM
%left ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

%% 

  /* write your rules here */
program: %empty
        {
          if(!mainFunc)
          {
            printf("No main function declared!\n");
          }
        }
        | function program 
        { 
        }
        ;
function: FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
        {
          std::string temp = "func ";
          temp.append($2.place);
          temp.append("\n");
          std::string s = $2.place;
          if(s == "main")
          {
            mainFunc = true;
          }
          temp.append($5.code);
          std::string decs = $5.code;
          int decNum = 0;

          while(decs.find(".") != std::string::npos)
          {
            int pos = decs.find(".");
            decs.replace(pos, 1, "=");
            std::string part = ", $" + std::to_string(decNum) + "\n";
            decNum++;
            decs.replace(decs.find("\n", pos), 1, part);
          }

          temp.append(decs);
          temp.append($8.code);

          std::string statements = $11.code;

          if(statements.find("continue") != std::string::npos)
          {
            printf("ERROR: Continue outside loop in function %s\n", $2.place);
          }

          temp.append(statements);
          temp.append("endfunc\n\n");
        };

declarations: declaration SEMICOLON declarations
        {
          std::string temp;
          temp.append($1.code);
          temp.append($3.code);

          $$.code = strdup(temp.c_str());
          $$.place = strdup("");
        }
        | %empty
        {
          $$.code = strdup("");
          $$.place = strdup("");
        };

%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
}