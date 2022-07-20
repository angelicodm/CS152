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
          $$.code = strdup("");
          $$.place = strdup($1.place)
        }
        | ident COMMA identifiers
        {
          std::string temp;
          temp.append($1.place);
          temp.append(".| \n"); //NEED TO REMOVE NEWLINE??
          temp.append($3.place);

          $$.code = strdup("");
          $$.place = strdup(temp.c_str());
        }
        ;

ident: IDENT
        {
          $$.code = strdup("");
          $$.place = strdup($1.place)
        };

statements: statement SEMICOLON statements
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
        }
        ;

statement: var ASSIGN expression
        {

        }

bool_exp: relation_and_exp OR bool_exp
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp += ". " + dst + "\n";
          temp += "|| " + dst + ", ";
          temp.append($1.place);
          temp.append(", ");
          temp.append($3.place);
          temp.append("\n");
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | relation_and_exp
        {
          $$.code = strdup($1.code);
          $$.place = strdup($1.place);
        }
        ;

relation_and_exp: relation_exp AND relation_and_exp
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp += ". " + dst + "\n";
          temp += "&& " + dst + ", ";
          temp.append($1.place);
          temp.append(", ");
          temp.append($3.place);
          temp.append("\n");
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | relation_exp_inv
        {
          $$.code = strdup($1.code);
          $$.place = strdup($1.place);
        }
        ;

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
        ;

relation_exp: expression comp expression
        {
          std::string dst = new_temp();
          std::string temp;
          temp.append($1.code);
          temp.append($3.code);
          temp = temp + ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(temp.c_str());
        }
        | TRUE
        {
          std::string temp;
          temp.append("1");
          $$.code = strdup("");
          $$.place = strdup(temp.c_str());
        }
        | FALSE
        {
          std::string temp;
          temp.append("0");
          $$.code = strdup("");
          $$.place = strdup(temp.c_str());
        }
        | L_PAREN bool_exp R_PAREN
        {
          $$.code = strdup($2.code);
          $$.place = strdup($2.place);
        }
        ;

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
        ;


expression:  mult_exp ADD expression
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp += ". " + dst + "\n";
          temp += "+ " + dst + ", ";
          temp.append($1.place);
          temp += ", ";
          temp.append($3.place);
          temp += "\n";
          $$.code = strdup(temp.c_str);
          $$.place = strdup(dst.c_str);
        }
        | mult_exp SUB expression
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp += ". " + dst +"\n";
          temp += "- " + dst + ", ";
          temp.append($1.place);
          temp += ", ";
          temp.append($3.place);
          temp += "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | mult_exp
        {
          $$.code = strdup($1.code);
          $$.place = strdup($1.place);
        }
        ;

mult_exp: term
        {
          $$.code = strdup($1.code);
          $$.place = strdup($1.place);
        }
        | term MULT mult_exp
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp.append(". ");
          temp.append(dst);
          temp.append("\n");
          temp += "* " + dst + ", ";
          temp.append($1.place);
          temp += ", ";
          temp.append($3.place);
          temp += "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | term DIV mult_exp
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp.append(". ");
          temp.append(dst);
          temp.append("\n");
          temp += "/ " + dst + ", ";
          temp.append($1.place);
          temp += ", ";
          temp.append($3.place);
          temp += "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | term MOD mult_exp
        {
          std::string temp;
          std::string dst = new_temp();
          temp.append($1.code);
          temp.append($3.code);
          temp.append(". ");
          temp.append(dst);
          temp.append("\n");
          temp += "% " + dst + ", ";
          temp.append($1.place);
          temp += ", ";
          temp.append($3.place);
          temp += "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        ;
      
term: var
        {
          std::string dst = new_temp();
          std::string temp;
          if($1.arr)
          {
            temp.append($1.code);
            temp.append(", ");
            temp.append(dst);
            temp.append("\n");
            temp += "=[] " + dst + ", ";
            temp.append($1.place);
            temp.append("\n");
          }
          else
          {
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp = temp + "= " + dst + ", ";
            temp.append($1.place);
            temp.append("\n");
            temp.append($1.code);
          }
          if(varTemp.find($1.place) != varTemp.end())
          {
            varTemp[$1.place] = dst;
          }
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | NUMBER
        {
          std::string dst = new_temp();
          std::string temp;
          temp.append(". ");
          temp.append(dst);
          temp.append("\n");
          temp = temp + "= " + dst + ", " + std::to_string($1) + "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | L_PAREN expression R_PAREN
        {
          $$.code = strdup($2.code);
          $$.place = strdup($2.place);
        }
        | SUB var
        {
          std::string dst = new_temp();
          std::string temp;
          if($2.arr)
          {
            temp.append($2.code);
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp += "=[] " + dst + ", ";
            temp.append($2.place);
            temp.append("\n");
          }
          else
          {
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp = temp + "= " + dst + ", ";
            temp.append($2.place);
            temp.append("\n");
            temp.append($2.code);
          }
          if(varTemp.find($2.place) != varTemp.end())
          {
            varTemp[$2.place] = dst;
          }
          temp += "* " + dst + ", " + dst + ", -1\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | SUB NUMBER
        {
          std::string dst = new_temp();
          std::string temp;
          temp.append(". ");
          temp.append(dst);
          temp.append("\n");
          temp = temp + "= " + dst + ", -" + std::to_string($2) + "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        | SUB L_PAREN expression R_PAREN
        {
          std::string temp;
          temp.append($3.code);
          temp.append("* ");
          temp.append($3.place);
          temp.append(", ");
          temp.append($3.place);
          temp.append(", -1\n");
          $$.code = strdup(temp.c_str());
          $$.place = strdup($3.place);
        }
        | ident L_PAREN expressions R_PAREN
        {
          std::string temp;
          std::string func = $1.place;
          if(funcs.find(func) == finc.end())
          {
            printf("Calling undeclared function %s.\n", func.c_str());
          }
          std::string dst = new_temp();
          temp.append($3.code);
          temp += ". " + dst + "\ncall";
          temp.append($1.place);
          temp += ", " + dst + "\n";
          $$.code = strdup(temp.c_str());
          $$.place = strdup(dst.c_str());
        }
        ;

var: ident
        {
          std::string temp;
          std::string ident = $1.place;
          if(funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end())
          {
            printf("Identifier %s is not declared.\n", ident.c_str());
          }
          else if(arrSize[ident] > 1)
          {
            printf("Did not provide index for array Identifier %s.\n", ident.c_str());
          }
          $$.code = strdup("");
          $$.place = strdup(ident.c_str());
          $$.arr = false;
        }
        | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
        {
          std::string temp;
          std::string ident = $1.place;
          if(funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end())
          {
            printf("Identifier %s not declared.\n", ident.c_str());
          }
          else if(arrSize[ident] == 1)
          {
            printf("Provided index for non-array Identifier %s.\n", ident.c_str());
          }
          temp.append($1.place);
          temp.append(", ");
          temp.append($3.place);
          $$.code = strdup($3.code);
          $$.place = strdup(temp.c_str());
          $$.arr = true;
        }
        ;

vars: var COMMA vars
        {
          std::string temp;
          temp.append($1.code);
          if($1.arr)
          {
            temp.append(".[]| ");
          }
          else
          {
            temp.append(".| ");
          }
          temp.append($1.place);
          temp.append("\n");
          temp.append($3.code);
          $$.code = strdup(temp.c_str());
          $$.place = strdup("");
        }
        | var
        {
          std::string temp;
          temp.append($1.code);
          if($1.arr)
          {
            temp.append(".[]| ");
          }
          else
          {
            temp.append(".| ");
          }
          temp.append($1.place);
          temp.append("\n");
          $$.code = strdup(temp.c_str());
          $$.place = strdup("");
        }
        ;

expressions: expression COMMA expressions
        {
          std::string temp;
          temp.append($1.code);
          temp.append("param");
          temp.append($1.place);
          temp.append("\n");
          temp.append($3.code);
          $$.code = strdup(temp.c_str());
          $$.place = strdup("");
        }
        | expression
        {
          std::string temp;
          temp.append($1.code);
          temp.append("param ");
          temp.append($1.place);
          temp.append("\n");
          $$.code = strdup(temp.c_str());
          $$.place = strdup("");
        }
        ;
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