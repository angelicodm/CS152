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
%type <expression> bool_exp relation_and_exp relation_exp relation_exp_inv comp mult_exp term
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

declaration: identifiers COLON INTEGER
        {
          std::string temp;
          std::string ident = $1.place;
        }
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
        {

        }
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN
        {

        };

identifiers: ident
        {

        };

ident: IDENT
        {

        };

statements: statement SEMICOLON statements
        {

        }

statement: var ASSIGN expression
        {

        }

bool_exp: relation_and_exp OR bool_exp
        {

        }

relation_and_exp: relation_exp AND relation_and_exp
        {

        }

relation_exp_inv: NOT relation_exp_inv
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($2.code);
          temp += ". " + dst + "\n";
          temp += "! " + dst + "\n";
          temp.append($2.place);
          temp.append("\n");
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | relation_exp
        {
          $$.code = strdup($1.code);
          $$.code = strdup($1.place);
        }
relation_exp: expression comp expression
        {
          std::string dst = new_temp();
          std::string temp;
          temp.append($1.code);
          temp.append($3.code);
          temp = temp + ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
        }

comp: EQ
        {
          $$.code = strdup("");
          $$.place = strdup("== ");
        }
        | NEQ
        {
          $$.code = strdup("");
          $$.place = strdup("!= ");
        }
        | LT
        {
          $$.code = strdup("");
          $$.place = strdup("< ");
        }
        | LTE
        {
          $$.code = strdup("");
          $$.place = strdup("<= ");
        }
        | GT
        {
          $$.code = strdup("");
          $$.place = strdup("> ");
        }
        | GTE
        {
          $$.code = strdup("");
          $$.place = strdup(">= ");
        }


expression:  mult_exp
        {

        }

mult_exp: term
        {

        }
      
term: var
        {

        }

var: ident
        {

        }

vars: COMMA var vars
        {

        }

expressions: COMMA expression expressions
        {

        }
%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) 
{
  extern int yyline;
  extern char *yytext;

  printf("%s on line %d at char %d at symbol \"%s\"\n", msg, yylineno, currPos, yytext);
  exit(1);
}

std::string new_temp()
{
  std::string t = "t" + std::to_string(tempCount);
  tempCount++;
return t;
}

std::string new_label()
{
  std::string l = "L" + std::to_string(labelCount);
  labelCount++
  return l;
}