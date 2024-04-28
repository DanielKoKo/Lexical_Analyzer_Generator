    /* cs152-miniL phase2 */
%{
  #include <stdio.h>
  #include <stdlib.h>
  void yyerror(const char *msg);
  int yylex();
%}

%union{
  /* put your types here */
  int ival;
  char* idVal;
}

%error-verbose
%locations

%start program
%token FUNCTION SEMICOLON BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY COLON ARRAY OPEN_BRACKET CLOSE_BRACKET OF ASSIGN READ WRITE CONTINUE BREAK RETURN IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP NOT EQ NEQ LT GT LTE GTE ADD SUB MULT DIV MOD OPEN_PAR CLOSE_PAR COMMA INTEGER
%token <ival> NUMBER
%token <idVal> ID
%% 

  /* write your rules here */
program:          functions 
                  {printf("program -> functions\n");}  
                  ;        

functions:        /* epsilon */
                  {printf("functions -> epsilon\n");}
                  | function functions
                  {printf("functions -> function functions\n");}
                  ;

function:         FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                  {printf("function -> FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY\n");}
                  ;

ident:            ID
                  {printf("ident -> ID %s\n", $1);}
                  ;

number:           NUMBER
                  {printf("number -> NUMBER %d\n", $1);}
                  ;

declarations:     /* epsilon */
                  {printf("declarations -> epsilon\n");}
                  | declaration SEMICOLON declarations
                  {printf("declarations -> declaration SEMICOLON declarations\n");}
                  ;

declaration:      ident COLON array INTEGER 
                  {printf("declaration -> ident COLON array INTEGER SEMICOLON\n");}
                  | ident COLON INTEGER
                  {printf("declaration -> ident COLON INTEGER SEMICOLON\n");}
                  ;

array:            ARRAY OPEN_BRACKET number CLOSE_BRACKET OF
                  {printf("array -> ARRAY OPEN_BRACKET number CLOSE_BRACKET OF\n");}
                  ;

statements:       /* epsilon */
                  {printf("statements -> epsilon\n");}
                  | statement SEMICOLON statements
                  {printf("statements -> statement SEMICOLON statements\n");}
                  ;

statement:        var ASSIGN expression
                  {printf("statement -> var COLON_EQ expressions\n");}
                  | if 
                  {printf("statement -> if SEMICOLON\n");}
                  | while 
                  {printf("statement -> while SEMICOLON\n");}
                  | do 
                  {printf("statement -> do SEMICOLON\n");}
                  | READ var 
                  {printf("statement-> READ var SEMICOLON\n");}
                  | WRITE var 
                  {printf("statement-> WRITE var SEMICOLON\n");}
                  | CONTINUE 
                  {printf("statement -> CONTINUE SEMICOLON\n");}
                  | BREAK 
                  {printf("statement -> BREAK SEMICOLON\n");}
                  | RETURN expression 
                  {printf("statement -> RETURN expressions SEMICOLON\n");}
                  ;

if:               IF bool_exp THEN statements ENDIF
                  {printf("if -> IF bool-exp THEN statements ENDIF\n");}
                  | IF bool_exp THEN statements ELSE statements ENDIF
                  {printf("if -> IF bool_exp THEN statements ELSE statements ENDIF\n");}
                  ;

while:            WHILE bool_exp BEGINLOOP statements ENDLOOP
                  {printf("while -> WHILE bool-exp BEGINLOOP statements ENDLOOP\n");}
                  ;

do:               DO BEGINLOOP statements ENDLOOP WHILE bool_exp
                  {printf("do -> DO BEGINLOOP statements ENDLOOP WHILE bool-exp\n");}
                  ;

bool_exp:         not expression comp expression
                  {printf("bool_exp -> not expression comp expression\n");}
                  ;

not:              /* epsilon */
                  {printf("not -> epsilon\n");}
                  | not NOT
                  {printf("not -> not NOT\n");}
                  ;

comp:             EQ
                  {printf("comp -> EQ\n");}
                  | NEQ
                  {printf("comp -> NEQ\n");}
                  | LT
                  {printf("comp -> LT\n");}
                  | GT
                  {printf("comp -> GT\n");}
                  | LTE
                  {printf("comp -> LTE\n");}
                  | GTE 
                  {printf("comp -> GTE\n");}
                  ;

expression:       multiplicative_expr 
                  {printf("expression -> multiplicative_expr expression\n");}
                  | multiplicative_expr ADD multiplicative_expr
                  {printf("expression -> multiplicative_expr ADD multiplicative_expr");}
                  | multiplicative_expr SUB multiplicative_expr
                  {printf("expression -> multiplicative_expr SUB multiplicative_expr");}
                  ;

multiplicative_expr:      term 
                          {printf("multiplicative_expr -> term multiplicative-terms\n");}
                          | term MULT term
                          {printf("multiplicative_expr -> term MULT term\n");}
                          | term DIV term
                          {printf("multiplicative_expr -> term DIV term\n");}
                          | term MOD term
                          {printf("multiplicative_expr -> term MOD term\n");}
                          ;

term:             var 
                  {printf("term -> var\n");}
                  | number
                  {printf("term -> number\n");}
                  | OPEN_PAR expression CLOSE_PAR
                  {printf("term -> OPEN_PAR expression CLOSE_PAR\n");}
                  | ident OPEN_PAR expression id_expr CLOSE_PAR
                  {printf("term -> ident OPEN_PAR expression id_expr CLOSE_PAR\n");}
                  ;

id_expr:          /* epsilon */
                  {printf("id_expr -> epsilon\n");}
                  | COMMA expression id_expr
                  {printf("id_expr -> COMMA expression id_expr\n");}
                  ;

var:              ident
                  {printf("var -> ident\n");}
                  | ident OPEN_BRACKET expression CLOSE_BRACKET
                  {printf("var -> ident OPEN_BRACKET expressions CLOSE_BRACKET");}
                  ;
%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
  extern int currLine;

  fprintf(stderr, "Syntax error at line %d: %s\n", currLine, msg);
}

