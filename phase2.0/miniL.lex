/* cs152-miniL phase1 */

%{   
   /* write your C code here for definitions of variables and including headers */
   #include "y.tab.h"
   int currLine = 1, currPos = 1;

%}

/* some common rules */
DIGIT    [0-9]+
VAR [a-zA-Z][a-zA-Z_0-9]*
/*ERR [_0-9]-DIGIT*/
COMMENT ##.*

/* specific lexer rules in regex */

%%

   /* Reserved Words */

"function"          {return FUNCTION; currPos += yyleng;}
"beginparams"       {return BEGIN_PARAMS; currPos += yyleng; }
"endparams"         {return END_PARAMS; currPos += yyleng; }
"beginlocals"       {return BEGIN_LOCALS; currPos += yyleng; }
"endlocals"         {return END_LOCALS; currPos += yyleng; }
"beginbody"         {return BEGIN_BODY; currPos += yyleng; }
"endbody"           {return END_BODY; currPos += yyleng; }
"integer"           {return INTEGER; currPos += yyleng; }
"array"             {return ARRAY; currPos += yyleng; }
"enum"              {return ENUM; currPos += yyleng; }
"of"                {return OF; currPos += yyleng; }
"if"                {return IF; currPos += yyleng; }
"then"              {return THEN; currPos += yyleng; }
"endif"             {return ENDIF; currPos += yyleng; } 
"else"              {return ELSE; currPos += yyleng; }
"for"               {return FOR; currPos += yyleng; }
"while"             {return WHILE; currPos += yyleng; }
"do"                {return DO; currPos += yyleng; }
"beginloop"         {return BEGINLOOP; currPos += yyleng; }
"endloop"           {return ENDLOOP; currPos += yyleng; }
"continue"          {return CONTINUE; currPos += yyleng; }
"read"              {return READ; currPos += yyleng; }
"write"             {return WRITE; currPos += yyleng; }
"and"               {return AND; currPos += yyleng; }
"or"                {return OR; currPos += yyleng; }
"not"               {return NOT; currPos += yyleng; }
"true"              {return TRUE; currPos += yyleng; }
"false"             {return FALSE; currPos += yyleng; }
"return"            {return RETURN; currPos += yyleng; }

   /* Arithmetic Operators */ 
"-"            {currPos += yyleng; return SUB;}
"+"            {currPos += yyleng; return ADD;}
"*"            {currPos += yyleng; return MULT;}
"/"            {currPos += yyleng; return DIV;}
"%"            {currPos += yyleng; return MOD;}

   /* Comparison Operators */ 
"=="           {currPos += yyleng; return EQ;}
"<>"           {currPos += yyleng; return NEQ;}
"<"            {currPos += yyleng; return LT;}
">"            {currPos += yyleng; return GT;}
"<="           {currPos += yyleng; return LTE;}
">="           {currPos += yyleng; return GTE;}

   /* Other Special Symbols */ 
";"           {currPos += yyleng; return SEMICOLON;}
":"           {currPos += yyleng; return COLON;}
","            {currPos += yyleng; return COMMA;}
"("            {currPos += yyleng; return L_PAREN;}
")"           {currPos += yyleng; return R_PAREN;}
"["           {currPos += yyleng; return L_SQUARE_BRACKET;}
"]"           {currPos += yyleng; return R_SQUARE_BRACKET;}
":="           {currPos += yyleng; return ASSIGN;}




   /* Identifiers and Numbers*/ 

{VAR}[_]+   {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0);}
[_0-9]+{VAR}+  {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);}
{VAR}+   {yylval.id_val = strdup(yytext); currPos += yyleng; return IDENT;}
{DIGIT} {yylval.num_val = atoi(yytext); currPos += yyleng; return NUMBER;}

 /*[a-zA-Z]([a-zA-Z0-9_]*[a-zA-Z0-9])*         {currPos += yyleng;}
 (\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)      {printf("NUMBER %s\n", yytext); currPos += yyleng;} //should accomodate for all instances of numbers
 */

[ \t]+         {/* ignore spaces */ currPos += yyleng;} 

"\n"           {currLine++; currPos = 1;} 

{COMMENT}      	{currLine++; currPos = 1;}





.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}  //Error 1: Unrecognized symbol

%%
	/* C functions used in lexer */

/*int main(int argc, char ** argv)
{
   if(argc >= 2)
   {
      yyin = fopen(argv[1], "r");
      if(yyin == NULL)
      {
         yyin = stdin;
      }
   }
   else
   {
      yyin = stdin;
   }
   yylex();
}*/
