   /* cs152-miniL phase2 */
   
%{   
   #include "y.tab.h"
   int currLine = 1;
   int currPos = 1;
%}

   /* some common rules */

DIGIT             [0-9]

%%
   /* specific operators */

"-"               {currPos++; return SUB;}
"+"	            {currPos++; return ADD;}
"*"	            {currPos++; return MULT;}
"/"	            {currPos++; return DIV;}
"%"	            {currPos++; return MOD;}

   /* specific comparison operators */

"=="           	{currPos += yyleng; return EQ;}
"<>"	            {currPos += yyleng; return NEQ;}
"<"            	{currPos++; return LT;}
">"	            {currPos++; return GT;}
"<="	            {currPos += yyleng; return LTE;}
">="	            {currPos += yyleng; return GTE;}

   /* specific characters */

";"	            {currPos++; return SEMICOLON;}
":"	            {currPos++; return COLON;}
","	            {currPos++; return COMMA;}
"("	            {currPos++; return OPEN_PAR;}
")"	            {currPos++; return CLOSE_PAR;}
"["	            {currPos++; return OPEN_BRACKET;}
"]"	            {currPos++; return CLOSE_BRACKET;}
":="	            {currPos += yyleng; return ASSIGN;}

   /* specific strings */

"function"        {currPos += yyleng; return FUNCTION;}
"beginparams"	   {currPos += yyleng; return BEGINPARAMS;}
"endparams"	      {currPos += yyleng; return ENDPARAMS;}
"beginlocals"	   {currPos += yyleng; return BEGINLOCALS;}
"endlocals"	      {currPos += yyleng; return ENDLOCALS;}
"beginbody"	      {currPos += yyleng; return BEGINBODY;}
"endbody"	      {currPos += yyleng; return ENDBODY;}
"integer"	      {currPos += yyleng; return INTEGER;}
"array"	         {currPos += yyleng; return ARRAY;}
"of"	            {currPos += yyleng; return OF;}
"if"	            {currPos += yyleng; return IF;}
"then"	         {currPos += yyleng; return THEN;}
"endif"	         {currPos += yyleng; return ENDIF;}
"else"	         {currPos += yyleng; return ELSE;}
"while"	         {currPos += yyleng; return WHILE;}
"do"	            {currPos += yyleng; return DO;}
"beginloop"	      {currPos += yyleng; return BEGINLOOP;}
"endloop"	      {currPos += yyleng; return ENDLOOP;}
"continue"	      {currPos += yyleng; return CONTINUE;}
"break"	         {currPos += yyleng; return BREAK;}
"read"	         {currPos += yyleng; return READ;}
"write"	         {currPos += yyleng; return WRITE;}
"not"	            {currPos += yyleng; return NOT;}
"return"          {currPos += yyleng; return RETURN;}

{DIGIT}+            {yylval.ival = atoi(yytext); currPos += yyleng; return NUMBER;}

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

[a-zA-Z0-9_]*[a-zA-Z0-9]*    {yylval.idVal = strdup(yytext); currPos += yyleng; return ID;} 

.                      {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", 
                        currLine, 0, yytext); exit(1);}

%%
   /* C functions used in lexer */
