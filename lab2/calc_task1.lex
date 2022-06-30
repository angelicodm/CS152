/* cs152-calculator */

%{
   /* write your C code here for defination of variables and including headers */
#include "y.tab.h"
int currLine = 1, currPos = 1;
int numNumbers = 0;
int NumOperators = 0;
int NumParens = 0;
int NumEquals = 0;
%}


/* some common rules, for example DIGIT */
DIGIT    [0-9]

%%
"+"            {currPos += yyleng; NumOperators++; return PLUS;}
"-"            {currPos += yyleng; NumOperators++; return MINUS;}
"*"            {currPos += yyleng; NumOperators++; return MULT;}
"/"            {currPos += yyleng; NumOperators++; return DIV;}
"="            {currPos += yyleng; NumEquals++; return EQUAL;}
"("            {currPos += yyleng; NumParens++; return L_PAREN;}
")"            {currPos += yyleng; NumParens++; return R_PAREN;}

(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)   {currPos += yyleng; yylval.dval = atof(yytext); numNumbers++; return NUMBER;}

[ \t]+         {currPos += yyleng;}

"\n"           {currLine++; currPos = 1; return END;}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yyleng); exit(0);}
%%
	/* C functions used in lexer */
   /* remove your original main function */
