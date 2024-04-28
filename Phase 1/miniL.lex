   /* cs152-miniL phase1 */
   
%{   
   int currLine = 1;
   int currPos = 1;
%}

   /* some common rules */

DIGIT             [0-9]

%%
   /* specific operators */

"-"               {printf("SUB\n"); currPos++;}
"+"	            {printf("ADD\n"); currPos++;}
"*"	            {printf("MULT\n"); currPos++;}
"/"	            {printf("DIV\n"); currPos++;}
"%"	            {printf("MOD\n"); currPos++;}

   /* specific comparison operators */

"=="           	{printf("EQ\n"); currPos += yyleng;}
"<>"	            {printf("NEQ\n"); currPos += yyleng;}
"<"            	{printf("LT\n"); currPos++;}
">"	            {printf("GT\n"); currPos++;}
"<="	            {printf("LTE\n"); currPos += yyleng;}
">="	            {printf("GTE\n"); currPos += yyleng;}

   /* specific characters */

";"	            {printf("SEMICOLON\n"); currPos++;}
":"	            {printf("COLON\n"); currPos++;}
","	            {printf("COMMA\n"); currPos++;}
"("	            {printf("L_PAREN\n"); currPos++;}
")"	            {printf("R_PAREN\n"); currPos++;}
"["	            {printf("L_SQUARE_BRACKET\n"); currPos++;}
"]"	            {printf("R_SQUARE_BRACKET\n"); currPos++;}
":="	            {printf("ASSIGN\n"); currPos += yyleng;}

   /* specific strings */

"function"        {printf("FUNCTION\n"); currPos += yyleng;}
"beginparams"	   {printf("BEGIN_PARAMS\n"); currPos += yyleng;}
"endparams"	      {printf("END_PARAMS\n"); currPos += yyleng;}
"beginlocals"	   {printf("BEGIN_LOCALS\n"); currPos += yyleng;}
"endlocals"	      {printf("END_LOCALS\n"); currPos += yyleng;}
"beginbody"	      {printf("BEGIN_BODY\n"); currPos += yyleng;}
"endbody"	      {printf("END_BODY\n"); currPos += yyleng;}
"integer"	      {printf("INTEGER\n"); currPos += yyleng;}
"array"	         {printf("ARRAY\n"); currPos += yyleng;}
"of"	            {printf("OF\n"); currPos += yyleng;}
"if"	            {printf("IF\n"); currPos += yyleng;}
"then"	         {printf("THEN\n"); currPos += yyleng;}
"endif"	         {printf("ENDIF\n"); currPos += yyleng;}
"else"	         {printf("ELSE\n"); currPos += yyleng;}
"while"	         {printf("WHILE\n"); currPos += yyleng;}
"do"	            {printf("DO\n"); currPos += yyleng;}
"beginloop"	      {printf("BEGINLOOP\n"); currPos += yyleng;}
"endloop"	      {printf("ENDLOOP\n"); currPos += yyleng;}
"continue"	      {printf("CONTINUE\n"); currPos += yyleng;}
"break"	         {printf("BREAK\n"); currPos += yyleng;}
"read"	         {printf("READ\n"); currPos += yyleng;}
"write"	         {printf("WRITE\n"); currPos += yyleng;}
"not"	            {printf("NOT\n"); currPos += yyleng;}
"true"	         {printf("TRUE\n"); currPos += yyleng;}
"false"	         {printf("FALSE\n"); currPos += yyleng;}
"return"          {printf("RETURN\n"); currPos += yyleng;}

{DIGIT}+          {printf("NUMBER %s\n", yytext); currPos += yyleng;}

   /* tokens to ignore */

"##".*   {}
"\n"     {currLine++; currPos = 0;}
"\t"     {currPos += yyleng;}
" "      {currPos++;}

   /* ID and symbols error handling */

[a-zA-Z]+[a-zA-Z0-9_]*[_]    {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", 
                              currLine, 0, yytext); exit(1);}

{DIGIT}+[a-zA-Z0-9]+   {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", 
                        currLine, 0, yytext); exit(1);}

[_][a-zA-Z0-9]*        {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", 
                        currLine, 0, yytext); exit(1);}

[a-zA-Z0-9_]*[a-zA-Z0-9]*    {printf("IDENT %s\n", yytext); currPos += yyleng;}

.                      {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", 
                        currLine, 0, yytext); exit(1);}

%%
   /* C functions used in lexer */

int main(int argc, char ** argv)
{
   yylex();
}
