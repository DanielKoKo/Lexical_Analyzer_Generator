    /* cs152-miniL phase3 */
%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<vector>
#include<algorithm>
#include<fstream>
#include<iostream>
#include<sstream>

  void yyerror(const char *msg);
  extern int yylex();
  extern int currLine;

  char *identToken;
  int numberToken;
  int  count_names = 0;

struct Symbol 
{
  std::string name;
  std::string type;
};
std::vector<Symbol> table;

bool find_symbol(std::string value)
{
  for (int i = 0; i < table.size(); i++)
  {
    if (table.at(i).name == value)
      return true;
  }

  

  return false;
}

std::string get_symbol_type(std::string value)
{
  std::string type = "";

  for (int i = 0; i < table.size(); i++)
  {
    if (table.at(i).name == value)
    {
      type = table.at(i).type;
      break;
    }
  }

  return type;
}

void add_to_table(std::string value, std::string type)
{
  Symbol new_symbol;

  new_symbol.name = value;
  new_symbol.type = type;

  table.push_back(new_symbol);
}

void print_symbol_table()
{
  printf("symbol table:\n");
  printf("--------------------\n");

  for (int i = 0; i < table.size(); i++)
  {
      if (table[i].type == "function")
        printf("function: %s\n", table[i].name.c_str());
      else
        printf("symbol: %s\n", table[i].name.c_str());
  }

  printf("--------------------\n");
}

std::string toString(int &i) {
  std::stringstream ss;
  ss << i;
 
  return ss.str();
}

  std::string output = "";    //final output
  std::string tmp_id = "";    //last read id
  std::string tmp_write = ""; //_temp0, _temp1, ...
  std::string tmp_func = "";  //last read function name
  std::string tmp_num = "";   //last read num
  std::string tmp_str = "";   //for conditionals
  std::string tmp_comp = "";  //for conditionals
  std::string tmp_loop = "";  //for concatenating tmp_str when there's a loop
  std::string break_str = ""; //for break conditions only
  std::string arr_var;
  std::string last_id = "";
  
  bool is_func = true;
  
  //Using a variable without having first declared it. done
  bool isDeclared = false;
  //Calling a function which has not been defined. done
  bool isDefined = false;
  //Not defining a main function. done
  //bool isMain = false;
  //Defining a variable more than once. done
  bool alreadyDeclared = false;
  //Trying to name a variable with the same name as a reserved keyword.
  //bool isReserved = false;

  //for nested multiplicative operations
  bool extra_mult = false;   
  bool extra_div = false;
  bool extra_mod = false;

  //checks for arithmetics
  bool add_flag = false;
  bool sub_flag = false;
  bool mult_flag = false;
  bool div_flag = false;
  bool mod_flag = false;  

  bool equal_flag = false;
  bool index_reset = false; //checks if the array index has been reset
  bool func_call = false;   //checks if function has been called
  bool write_flag = false;  //checks if WRITE has just been encountered
  bool if_flag = false;
  bool if_else_flag = false;
  
  //checks for comparisons
  bool eq_flag = false;
  bool neq_flag = false;
  bool lt_flag = false;
  bool gt_flag = false;
  bool lte_flag = false;
  bool gte_flag = false;

  bool comp_first = false;       //checks if it's the first encounter for comparison
  bool nested = false;           //checks if there's a nested while loop
  bool encountered_nest = false; //checks if a nest has just been encountered
  bool first_nest = true;        //checks if it's the outer loop
  bool outer = false;            //checks if we're currently on the outer-most while loop
  bool is_break = false;         //checks for breaks in loop
  bool just_read_array = false;
  bool has_continue = false;     //checks if continue exists
  bool just_read_id = false;
  bool just_read_num = false;

  bool has_error = false;
  bool err_wrong_array = false;
  bool err_missing_index = false;
  bool arr_size_line = false;
  bool err_continue = false;
  bool err_arr_size = false;
  bool err_index_type = false;
  bool err_break = false;
  int err_break_line;
  int err_wrong_array_line;
  int err_missing_index_line;
  int err_continue_line;
  int err_arr_size_line;
  int err_index_type_line;

  int tmp_cnt = 0;        //stores current temp number
  int declare_cnt = 0;    //stores total number of declaration variables
  int arr_index_cnt = 0;
  int loop_cnt = 0; 
  int nest_cnt = 0;
  int break_cnt = 0;
  int comp_check = 0;
  int comp_cnt = 0;
  int arr_num = -1;

  std::vector<std::string> nums;
  std::vector<std::string> ids;
  std::vector<std::string> temps; //for multiplicative operations
%}

%union{
  /* put your types here */
  int ival;
  char* idVal;
  char* brackets;
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
                  {

                  }

functions:        /* epsilon */
                  {
                    if (is_break)
                    {
                      err_break = true;
                      err_break_line = currLine;
                      has_error = true;
                    }
                  }
                  | function functions
                  {
                  };

function:         FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                  {
                    is_func = true;
                    output += "endfunc\n\n";
                  }

ident:            ID
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array")
                      {
                        err_index_type = true;
                        has_error = true;
                        err_index_type_line = currLine;
                      }
                    }

                    just_read_id = true;
                    just_read_num = false;
                    if (!is_func)
                    {
                      tmp_id = $1;
                     if (tmp_id == "FUNCTION" ||
                        tmp_id == "SEMICOLON" ||
                        tmp_id == "BEGINPARAMS" ||
                        tmp_id == "ENDPARAMS" ||
                        tmp_id == "BEGINLOCALS" ||
                        tmp_id == "ENDLOCALS" ||
                        tmp_id == "BEGINBODY" ||
                        tmp_id == "ENDBODY" ||
                        tmp_id == "COLON" ||
                        tmp_id == "ARRAY" ||
                        tmp_id == "OPEN_BRACKET" ||
                        tmp_id == "CLOSE_BRACKET" ||
                        tmp_id == "OF" ||
                        tmp_id == "ASSIGN" ||
                        tmp_id == "READ" ||
                        tmp_id == "WRITE" ||
                        tmp_id == "CONTINUE" ||
                        tmp_id == "BREAK" ||
                        tmp_id == "RETURN" ||
                        tmp_id == "IF" ||
                        tmp_id == "THEN" ||
                        tmp_id == "ENDIF" ||
                        tmp_id == "ELSE" ||
                        tmp_id == "WHILE" ||
                        tmp_id == "DO" ||
                        tmp_id == "BEGINLOOP" ||
                        tmp_id == "ENDLOOP" ||
                        tmp_id == "NOT" ||
                        tmp_id == "EQ" ||
                        tmp_id == "NEQ" ||
                        tmp_id == "LT" ||
                        tmp_id == "GT" ||
                        tmp_id == "LTE" ||
                        tmp_id == "GTE" ||
                        tmp_id == "ADD" ||
                        tmp_id == "SUB" ||
                        tmp_id == "MULT" ||
                        tmp_id == "DIV" ||
                        tmp_id == "MOD" ||
                        tmp_id == "OPEN_PAR" ||
                        tmp_id == "CLOSE_PAR" ||
                        tmp_id == "COMMA" ||
                        tmp_id == "INTEGER") {

                              extern int currLine;

                              fprintf(stderr, "error at line %d: reserved word used in variable name\n", currLine);
                              exit(-1);

                          }
                      ids.push_back($1);
                    }

                    if (is_func)
                    {
                      std::string value = $1;
                      add_to_table($1, "function");
                      if(value != "main") {
                        extern int currLine;

                        fprintf(stderr, "error at line %d: main function not defined\n", currLine);
                        exit(-1);
                      }
                      
                      output += "func " + value + "\n";

                      is_func = false;
                    }

                    if (find_symbol("j") && !encountered_nest && first_nest)
                    {
                      encountered_nest = true;
                      nested = true;
                      nest_cnt++; 
                    }

                    last_id = tmp_id;
                  }

number:           NUMBER
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    just_read_num = true;

                    tmp_num = toString($1);
                    arr_num = $1;

                    if (!eq_flag && !neq_flag && !gt_flag && !lt_flag &&
                        !gte_flag && !lte_flag)
                    {
                      nums.push_back(tmp_num);

                      if (declare_cnt > 0)
                      {
                        if (get_symbol_type(tmp_id) != "array")
                        {
                          output += "= " + tmp_id + ", " + tmp_num + "\n";
                          nums.clear();
                        }

                        ids.clear();
                        declare_cnt--;
                      }
                    }
                    else
                    {
                      if ((eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                          && comp_first)
                      {
                        int new_loop = loop_cnt;

                        if (!encountered_nest && first_nest)
                          new_loop = loop_cnt + 1;

                        if (nested)
                        {
                          if (tmp_id == "j")
                            new_loop++;

                          tmp_comp += tmp_num + "\n?:= loopbody" + toString(new_loop) + ", " + tmp_loop + "\n";
                          tmp_comp += ":= endloop" + toString(new_loop) + "\n";
                          tmp_comp += ": loopbody" + toString(new_loop) + "\n";
                        }
                        else
                        {
                          if (break_cnt == 0)
                          {
                            break_str += tmp_num + "\n?:= loopbody" + toString(loop_cnt) + ", " + tmp_loop + "\n";
                            break_cnt++;
                          }
                          else
                          {
                            break_str += tmp_num + "\n?:= if_true" + toString(loop_cnt) + ", " + tmp_write + "\n";
                            break_str += ":= endif" + toString(loop_cnt) + "\n";
                            break_str += ": if_true" + toString(loop_cnt) + "\n";
                          }

                          tmp_comp += tmp_num + "\n?:= loopbody" + toString(loop_cnt) + ", " + tmp_loop + "\n";
                        }

                        comp_first = false;
                      }
                      else if (eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                      {
                        if (tmp_id == "j" && encountered_nest)
                        {
                          if (encountered_nest && first_nest)
                            tmp_comp += "= " + tmp_id + ", " + tmp_num + "\n";

                          if (first_nest && nested)
                            tmp_comp += ": beginloop" + tmp_num + "\n";

                          encountered_nest = false;
                          first_nest = false;
                        }
                      }
                    }
                  }

declarations:     /* epsilon */
                  {
                    
                  }
                  | declaration SEMICOLON declarations
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    declare_cnt++; // counts the number of symbols to assign
                  };

declaration:      ident COLON array INTEGER 
                  {
                    if (just_read_id)
                    {
                      if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_num = false;
                    just_read_id = false;
last_id = "";
                    // don't add symbol to table if it already exists 
        
                      alreadyDeclared = find_symbol(tmp_id);
                      if(alreadyDeclared == true) {
                       extern int currLine;

                      fprintf(stderr, "error at line %d: variable already defined\n", currLine);
                      exit(-1);
                    
                      }
                

                    add_to_table(tmp_id, "array");
                    output += ".[] " + tmp_id + ", " + tmp_num + "\n";

                    ids.clear();
                  }
                  | ident COLON INTEGER
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    // don't add symbol to table if it already exists 
                    if (find_symbol(tmp_id))
                    {
                      output += ". " + tmp_id + "\n";
                      break;
                    }

                    add_to_table(tmp_id, "integer");
                    output += ". " + tmp_id + "\n";

                    ids.clear();
                    nums.clear();
                  };

array:            ARRAY OPEN_BRACKET number CLOSE_BRACKET OF
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    just_read_id = false;
last_id = "";
just_read_num = false;
                    //error handling
                    if (arr_num <= 0)
                    {
                      err_arr_size = true;
                      err_arr_size_line = currLine;
                      has_error = true;
                    }
                  }

statements:       /* epsilon */
                  {

                  }
                  | statement SEMICOLON statements
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  };

statement:        var ASSIGN expression
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | if 
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    if(if_else_flag && comp_cnt < 2) {
                      tmp_write = "_temp" + toString(tmp_cnt);

                      output += ". " + tmp_write + "\n";

                      //should we be parsing variables from the if statement or do we assume they will always do var1 comp var2?

                      if(comp_check == 1)
                        output += "== " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 2)
                        output += "!= " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 3)
                        output += "< " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 4)
                        output += "> " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 5)
                        output += "<= " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 6)
                        output += ">= " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";

                      tmp_write = "if_true" + toString(tmp_cnt);
                      output += "?:= " + tmp_write + ", _temp" + toString(tmp_cnt) + "\n"; 

                      output += ":= else" + toString(tmp_cnt) + "\n";
                      output += ": " + tmp_write + "\n";

                      if (equal_flag) {
                        output += "= " + ids.at(2) + ", " + ids.at(1) + "\n"; //never called
                      }
                      output += ":= endif" + toString(tmp_cnt) + "\n";
                      output += ": else" + toString(tmp_cnt) + "\n";

                      if (equal_flag) {
                        output += "= " + ids.at(2) + ", " + ids.at(0) + "\n"; //never called
                        equal_flag = false;
                      }
                      output += ": endif" + toString(tmp_cnt) + "\n";
                      output += ".> " + ids.at(2) + "\n";


                      comp_check = 0;
                      tmp_cnt++;
                      if_else_flag = false;
                    }
                    else if(if_flag && comp_cnt < 2) {
                      tmp_write = "_temp" + toString(tmp_cnt);
                      
                      output += ". " + tmp_write + "\n";

                      //should we be parsing variables from the if statement or do we assume they will always do var1 comp var2?

                      if(comp_check == 1)
                        output += "== " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 2)
                        output += "!= " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 3)
                        output += "< " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 4)
                        output += "> " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 5)
                        output += "<= " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                      else if(comp_check == 6)
                        output += ">= " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";

                      tmp_write = "if_true" + toString(tmp_cnt);
                      output += "?:= " + tmp_write + ", _temp" + toString(tmp_cnt) + "\n"; 

                      output += ":= endif" + toString(tmp_cnt) + "\n";
                      output += ": " + tmp_write + "\n";
                      
                      if (equal_flag) {
                        output += "= " + ids.at(2) + ", " + ids.at(1) + "\n";
                        equal_flag = false;
                      }

                      output += ": endif" + toString(tmp_cnt) + "\n";
                      output += ".> " + ids.at(2) + "\n";


                      comp_check = 0;
                      tmp_cnt++;
                      if_flag = false;
                    }
                  }
                  | while 
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | do 
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | READ var 
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | WRITE var 
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    
                    tmp_write = "_temp" + toString(tmp_cnt);
                    int break_int = tmp_cnt + 1;
                    std::string break_write = "_temp" + toString(break_int);

                    write_flag = true;
                    if ((eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag) && first_nest)
                    {
                        tmp_str += ". " + tmp_write + "\n";
                    }
                    else
                    {
                      if (first_nest)
                        output += ". " + tmp_write + "\n";
                    }

                    tmp_cnt++;

                    if (func_call)
                    {
                      output += "= " + tmp_id + ", " + tmp_write + "\n";
                      output += ".> " + tmp_id + "\n";
                      func_call = false;
                    }

                    if (add_flag && !err_missing_index)
                    {
                      if (get_symbol_type(tmp_id) != "array")
                      {
                        if (eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                        {
                          tmp_str += "+ " + tmp_write + ", " + ids.at(1) + ", " + tmp_num + "\n";
                          tmp_str += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          tmp_str += ".> " + ids.at(0) + "\n";
                        }
                        else
                        {
                          output += ". " + tmp_write + "\n";
                          output += "+ " + tmp_write + ", " + ids.at(1) + ", " + ids.at(2) + "\n";
                          output += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          output += ".> " + ids.at(0) + "\n";
                        }
                      }
                      else
                      {
                        output += "+ " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                        output += "[]= " + tmp_id + ", " + tmp_num + ", " + tmp_write + "\n";
                      }
                      
                      add_flag = false;
                    }
                    else if (sub_flag && !err_missing_index)
                    {
                      if (get_symbol_type(tmp_id) != "array")
                      {
                        if (eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                        {
                          tmp_str += "- " + tmp_write + ", " + ids.at(1) + ", " + tmp_num + "\n";
                          tmp_str += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          tmp_str += ".> " + ids.at(0) + "\n";
                        }
                        else
                        {
                          output += ". " + tmp_write + "\n";
                          output += "- " + tmp_write + ", " + ids.at(1) + ", " + ids.at(2) + "\n";
                          output += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          output += ".> " + ids.at(0) + "\n";
                        }
                      }
                      else
                      {
                        output += "- " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                        output += "[]= " + tmp_id + ", " + tmp_num + ", " + tmp_write + "\n";
                      }

                      sub_flag = false;
                    }
                    else if (mult_flag && !err_missing_index)
                    {
                      if (get_symbol_type(tmp_id) != "array")
                      {
                        if (eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                        {
                          tmp_str += "* " + tmp_write + ", " + ids.at(1) + ", " + tmp_num + "\n";
                          tmp_str += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          tmp_str += ".> " + ids.at(0) + "\n";
                        }
                        else
                        {
                          output += ". " + tmp_write + "\n";
                          output += "* " + tmp_write + ", " + ids.at(1) + ", " + ids.at(2) + "\n";
                          output += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          output += ".> " + ids.at(0) + "\n";
                        }
                      }
                      else
                      {
                        output += "* " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                        output += "[]= " + tmp_id + ", " + tmp_num + ", " + tmp_write + "\n";
                      }

                      mult_flag = false;
                    }
                    else if (div_flag && !err_missing_index)
                    {
                      if (get_symbol_type(tmp_id) != "array")
                      {
                        if (eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                        {
                          tmp_str += "/ " + tmp_write + ", " + ids.at(1) + ", " + tmp_num + "\n";
                          tmp_str += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          tmp_str += ".> " + ids.at(0) + "\n";
                        }
                        else
                        {
                          output += ". " + tmp_write + "\n";
                          output += "/ " + tmp_write + ", " + ids.at(1) + ", " + ids.at(2) + "\n";
                          output += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          output += ".> " + ids.at(0) + "\n";
                        }
                      }
                      else
                      {
                        output += "/ " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                        output += "[]= " + tmp_id + ", " + tmp_num + ", " + tmp_write + "\n";
                      }

                      div_flag = false;
                    }
                    else if (mod_flag && !err_missing_index)
                    {
                      if (get_symbol_type(tmp_id) != "array")
                      {
                        if (eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag)
                        {
                          tmp_str += "% " + tmp_write + ", " + ids.at(1) + ", " + tmp_num + "\n";
                          tmp_str += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          tmp_str += ".> " + ids.at(0) + "\n";
                        }
                        else
                        {
                          output += ". " + tmp_write + "\n";
                          output += "% " + tmp_write + ", " + ids.at(1) + ", " + ids.at(2) + "\n";
                          output += "= " + ids.at(0) + ", " + tmp_write + "\n";
                          output += ".> " + ids.at(0) + "\n";
                        }
                      }
                      else
                      {
                        output += "% " + tmp_write + ", " + ids.at(0) + ", " + ids.at(1) + "\n";
                        output += "[]= " + tmp_id + ", " + tmp_num + ", " + tmp_write + "\n";
                      }

                      mod_flag = false;
                    }
                    else
                    {
                      if (get_symbol_type(tmp_id) == "array" && !extra_mult && !err_missing_index)
                      {
                        output += "=[] " + tmp_write + ", " + tmp_id + ", " + toString(arr_index_cnt) + "\n";
                        output += ".> " + tmp_write + "\n";

                        output += "[]= " + tmp_id + ", " + nums.at(0) + ", " + nums.at(1) + "\n";

                        arr_index_cnt++;
                      }
                      else if (get_symbol_type(tmp_id) == "array" && extra_mult && !err_missing_index)
                      {
                        arr_index_cnt++;
                        output += "=[] " + tmp_write + ", " + tmp_id + ", " + toString(arr_index_cnt) + "\n";
                        output += ".> " + tmp_write + "\n";

                        arr_index_cnt++;
                      }
                    }

                    if (eq_flag) eq_flag = false;
                    else if (neq_flag) neq_flag = false;
                    else if (gt_flag) gt_flag = false;
                    else if (lt_flag) lt_flag = false;
                    else if (gte_flag) gte_flag = false;
                    else if (lte_flag) lte_flag = false;

                    ids.clear();
                    nums.clear();
                  }
                  | CONTINUE 
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
last_id = "";
                    has_continue = true;
                  }
                  | BREAK 
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    is_break = true;
                  }
                  | RETURN expression 
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    output += "= " + ids.at(ids.size() - 2) + ", $0\n";
                    output += "= " + ids.at(ids.size() - 1) + ", $1\n";
                    tmp_write = "_temp" + toString(tmp_cnt);
                    
                    output += ". " + tmp_write + "\n";
                    tmp_cnt++;

                    if (add_flag)
                    {
                      output += "+ " + tmp_write + ", " + ids.at(ids.size()-2) + ", " + ids.at(ids.size()-1) + "\n";
                      output += "ret " + tmp_write + "\n";

                      add_flag = false;
                    }
                    else if (sub_flag)
                    {
                      output += "- " + tmp_write + ", " + ids.at(ids.size()-2) + ", " + ids.at(ids.size()-1) + "\n";
                      output += "ret " + tmp_write + "\n";

                      sub_flag = false;
                    }
                    else if (mult_flag)
                    {
                      output += "* " + tmp_write + ", " + ids.at(ids.size()-2) + ", " + ids.at(ids.size()-1) + "\n";
                      output += "ret " + tmp_write + "\n";

                      mult_flag = false;
                    }
                    else if (div_flag)
                    {
                      output += "/ " + tmp_write + ", " + ids.at(ids.size()-2) + ", " + ids.at(ids.size()-1) + "\n";
                      output += "ret " + tmp_write + "\n";

                      div_flag = false;
                    }
                    else if (mod_flag)
                    {
                      output += "% " + tmp_write + ", " + ids.at(ids.size()-2) + ", " + ids.at(ids.size()-1) + "\n";
                      output += "ret " + tmp_write + "\n";

                      mod_flag = false;
                    }

                    ids.clear();
                  };

if:               IF bool_exp THEN statements ENDIF
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    if_flag = true;
                  }
                  | IF bool_exp THEN statements ELSE statements ENDIF
                  {
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }

                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    if_else_flag = true;
                  };

while:            WHILE bool_exp BEGINLOOP statements ENDLOOP
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";

                    /*
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }
                    */

                    if (!outer)
                    {
                      output += ": beginloop" + toString(loop_cnt) + "\n";

                      if (is_break)
                      {
                        output += ". _temp" + toString(loop_cnt) + "\n";
                        output += break_str;
                      }
                      else
                        output += tmp_comp;
                    }

                    if (nested)
                    {
                      output += tmp_str;
                      if (write_flag && nested)
                      {
                        output += ".> " + tmp_id + "\n";
                        output += ". " + tmp_write + "\n";

                        if (add_flag)
                        {
                          output += "+ " + tmp_write + ", " + tmp_id + ", " + tmp_num + "\n";
                          output += "= " + tmp_id + ", " + tmp_write + "\n";
                        }
                        else if (sub_flag)
                        {
                          output += "- " + tmp_write + ", " + tmp_id + ", " + tmp_num + "\n";
                          output += "= " + tmp_id + ", " + tmp_write + "\n";
                        }
                        else if (div_flag)
                        {
                          output += "/ " + tmp_write + ", " + tmp_id + ", " + tmp_num + "\n";
                          output += "= " + tmp_id + ", " + tmp_write + "\n";
                        }
                        else if (mod_flag)
                        {
                          output += "% " + tmp_write + ", " + tmp_id + ", " + tmp_num + "\n";
                          output += "= " + tmp_id + ", " + tmp_write + "\n";
                        }
                        else if (mult_flag)
                        {
                          output += " " + tmp_write + ", " + tmp_id + ", " + tmp_num + "\n";
                          output += "= " + tmp_id + ", " + tmp_write + "\n";
                        }
                        write_flag = false;
                      }
                      if (nest_cnt == 0)
                      {
                        output += ":= endloop" + toString(loop_cnt) + "\n";
                        output += ": loopbody" + toString(loop_cnt) + "\n";
                        nest_cnt++;
                      }
                    }
                    else if (!outer)
                    {
                      output += ":= endloop" + toString(loop_cnt) + "\n";
                      
                      if (!is_break)
                        output += ": loopbody" + toString(loop_cnt) + "\n";

                      if (break_cnt > 0)
                      {
                        output += ": endif" + toString(loop_cnt) + "\n";

                        if (is_break && write_flag)
                        {
                          int tmp_break = loop_cnt + 2;
                          std::string break_write = "_temp" + toString(tmp_break);

                          output += ". " + break_write + "\n";

                          if (add_flag)
                          {
                            output += "+ " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (sub_flag)
                          {
                            output += "- " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (div_flag)
                          {
                            output += "/ " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (mod_flag)
                          {
                            output += "% " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (mult_flag)
                          {
                            output += " " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }

                          write_flag = false;
                        }
                      }
                      else
                        output += ": loopbody" + toString(loop_cnt) + "\n";

                      if (!is_break)
                        output += tmp_str;
                    }

                    int loop_tmp = loop_cnt;
                    if (outer)
                    loop_tmp--;

                    if (nest_cnt > 0)
                      loop_tmp++;

                    output += ":= beginloop" + toString(loop_tmp) + "\n";
                    output += ": endloop" + toString(loop_tmp) + "\n";
                    
                    nest_cnt--;
                    loop_cnt++;
                    tmp_str.clear();
                    tmp_comp.clear();
                    is_break = false;
                  }

do:               DO BEGINLOOP statements ENDLOOP WHILE bool_exp
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
                    last_id = "";
                    
                    /*
                    if (has_continue)
                    {
                      err_continue = true;
                      err_continue_line = currLine;
                      has_error = true;
                    }
                    */

                      output += ": beginloop" + toString(loop_cnt) + "\n";

                      if (is_break)
                      {
                        output += ". _temp" + toString(loop_cnt) + "\n";
                        output += break_str;
                      }
                      else
                        output += tmp_comp;

                      output += ":= endloop" + toString(loop_cnt) + "\n";
                      
                      if (!is_break)
                        output += ": loopbody" + toString(loop_cnt) + "\n";

                      if (break_cnt > 0)
                      {
                        output += ": endif" + toString(loop_cnt) + "\n";

                        if (is_break && write_flag)
                        {
                          int tmp_break = loop_cnt + 2;
                          std::string break_write = "_temp" + toString(tmp_break);

                          output += ". " + break_write + "\n";

                          if (add_flag)
                          {
                            output += "+ " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (sub_flag)
                          {
                            output += "- " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (div_flag)
                          {
                            output += "/ " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (mod_flag)
                          {
                            output += "% " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }
                          else if (mult_flag)
                          {
                            output += " " + break_write + ", " + tmp_id + ", " + tmp_num + "\n";
                            output += "= " + tmp_id + ", " + break_write + "\n";
                          }

                          write_flag = false;
                        }
                      }
                      else
                        output += ": loopbody" + toString(loop_cnt) + "\n";

                      if (!is_break)
                        output += tmp_str;

                    int loop_tmp = loop_cnt;

                    output += ":= beginloop" + toString(loop_tmp) + "\n";
                    output += ": endloop" + toString(loop_tmp) + "\n";
                    
                    nest_cnt--;
                    loop_cnt++;
                    tmp_str.clear();
                    tmp_comp.clear();
                  }

bool_exp:         not expression comp expression
                  {
                    just_read_id = false;
last_id = "";
                  }

not:              /* epsilon */
                  { 
                    just_read_id = false;
last_id = "";
                  }
                  | not NOT
                  {
                    just_read_id = false;
last_id = "";
                  };

comp:             EQ
                  {
                    
                    comp_check = 1;
                    eq_flag = true;
                    comp_first = true;
                    tmp_loop = "_temp" + toString(tmp_cnt);
                    tmp_comp += ". " + tmp_loop + "\n";
                    tmp_comp += "== " + tmp_loop + ", " + tmp_id + ", ";
                    //tmp_cnt++;
                    comp_cnt++;
                  }
                  | NEQ
                  {
                    
                    comp_check = 2;
                    neq_flag = true;
                    comp_first = true;
                    tmp_loop = "_temp" + toString(tmp_cnt);
                    tmp_comp += ". " + tmp_loop + "\n";
                    tmp_comp += "!= " + tmp_loop + ", " + tmp_id + ", ";
                    //tmp_cnt++;
                    comp_cnt++;
                  }
                  | LT
                  {
                    
                    comp_check = 3;
                    lt_flag = true;
                    comp_first = true;
                    tmp_loop = "_temp" + toString(tmp_cnt);
                    tmp_comp += ". " + tmp_loop + "\n";
                    tmp_comp += "< " + tmp_loop + ", " + tmp_id + ", ";
                    //tmp_cnt++;
                    comp_cnt++;
                  }
                  | GT
                  {
                    
                    comp_check = 4;
                    gt_flag = true;
                    comp_first = true;

                    break_str += ":= endloop" + toString(loop_cnt) + "\n";
                    break_str += ": loopbody" + toString(loop_cnt) + "\n";
                    break_str += ".> " + tmp_id + "\n";

                    int tmp = tmp_cnt - 1;

                    break_str += ". " + tmp_write + "\n";
                    break_str += "> " + tmp_write + ", " + tmp_id + ", ";

                    tmp_loop = "_temp" + toString(tmp_cnt);
                    tmp_comp += ". " + tmp_loop + "\n";
                    tmp_comp += "> " + tmp_loop + ", " + tmp_id + ", ";

                    //tmp_cnt++;
                    comp_cnt++;
                  }
                  | LTE
                  {
                    
                    comp_check = 5;
                    lte_flag = true;
                    comp_first = true;

                    tmp_loop = "_temp" + toString(tmp_cnt);

                    break_str += "<= " + tmp_loop + ", " + tmp_id + ", ";

                    tmp_comp += ". " + tmp_loop + "\n";
                    tmp_comp += "<= " + tmp_loop + ", " + tmp_id + ", ";

                    //tmp_cnt++;
                    comp_cnt++;
                  }
                  | GTE 
                  {
                    
                    comp_check = 6;
                    gte_flag = true;
                    comp_first = true;
                    tmp_loop = "_temp" + toString(tmp_cnt);
                    tmp_comp += ". " + tmp_loop + "\n";
                    tmp_comp += ">= " + tmp_loop + ", " + tmp_id + ", ";
                    //tmp_cnt++;
                    comp_cnt++;
                  };

expression:       multiplicative_expr 
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    equal_flag = true;
                  }
                  | multiplicative_expr ADD multiplicative_expr
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }

                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    if (ids.size() > 3 && !err_missing_index)
                    {
                      extra_mult = true;

                      for (int i = 0; i < ids.size(); i++)
                      {
                        if (i > 0 && !index_reset)
                        {
                          arr_index_cnt = 0;
                          index_reset = true;
                        }

                        if (i < nums.size())
                        {
                          tmp_write = "_temp" + toString(tmp_cnt);
                          temps.push_back(tmp_write);

                          output += ". " + tmp_write + "\n";
                          output += "=[] " + tmp_write + ", " + ids.at(i) + ", " + toString(arr_index_cnt) + "\n";
                        
                          //this checks if current ID is the one we're assigning
                          if (!index_reset)
                            output += ".> " + tmp_write + "\n";

                          tmp_cnt++;
                          arr_index_cnt++;
                        }
                      }                    

                      tmp_write = "_temp" + toString(tmp_cnt);
                      int num = tmp_cnt - 1;
                      std::string tmp1 = toString(num);

                      output += ". " + tmp_write + "\n";

                      if ((eq_flag || neq_flag || gt_flag || lt_flag || gte_flag || lte_flag) && loop_cnt == 0)
                        output += "+ " + tmp_write + ", " + "_temp" + tmp1 + ", " + tmp_num + "\n";
                      else if (loop_cnt > 0)
                      {
                        if (nested)
                        {
                          output += "+ " + tmp_write + ", " + tmp_id + ", " + tmp_num + "\n";
                          nested = false;
                          outer = true;
                        }
                        else
                          output += "+ " + tmp_write + ", " + "_temp" + tmp1 + ", " + tmp_num + "\n";
                          
                        output += "= " + tmp_id + ", " + tmp_write + "\n";
                      }
                      else
                        output += "+ " + tmp_write + ", " + "_temp" + tmp1 + ", " + ids.back() + "\n";
                     
                      temps.push_back(tmp_write);
                      tmp_cnt++;
                    }
                    else
                    {
                      add_flag = true;
                    }
                  }
                  
                  | multiplicative_expr SUB multiplicative_expr
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    if (ids.size() > 3 && !err_missing_index)
                    {
                      extra_mult = true;

                      for (int i = 0; i < ids.size(); i++)
                      {
                        if (i > 0 && !index_reset)
                        {
                          arr_index_cnt = 0;
                          index_reset = true;
                        }

                        if (i < nums.size())
                        {
                          tmp_write = "_temp" + toString(tmp_cnt);
                          temps.push_back(tmp_write);

                          output += ". " + tmp_write + "\n";
                          output += "=[] " + tmp_write + ", " + ids.at(i) + ", " + toString(arr_index_cnt) + "\n";
                        
                          //this checks if current ID is the one we're assigning
                          if (!index_reset)
                            output += ".> " + tmp_write + "\n";

                          tmp_cnt++;
                          arr_index_cnt++;
                        }
                      }                    

                      tmp_write = "_temp" + toString(tmp_cnt);
                      int num = tmp_cnt - 1;
                      std::string tmp1 = toString(num);

                      output += ". " + tmp_write + "\n";
                      output += "- " + tmp_write + ", " + "_temp" + tmp1 + ", " + ids.back() + "\n";
                     
                      temps.push_back(tmp_write);
                      tmp_cnt++;
                    }
                    else
                    {
                      sub_flag = true;
                    }
                  };

multiplicative_expr:      term 
                          {
                            if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                            just_read_id = false;
                            just_read_num = false;
last_id = "";
                            
                          }
                          | term MULT term
                          {
                            if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                            just_read_id = false;
                            just_read_num = false;
last_id = "";
                            if (extra_mult && !err_missing_index)
                            {
                              tmp_write = "_temp" + toString(tmp_cnt);
                              output += ". " + tmp_write + "\n";
                              output += "* " + tmp_write + ", " + temps.at(1) + ", " + temps.back() + "\n";
                              output += "[]= " + ids.at(0) + ", " + nums.at(0) + ", " + tmp_write + "\n";
                              
                              tmp_cnt++;
                            }
                            else
                            {
                              mult_flag = true;
                            }
                          }
                          | term DIV term
                          {
                            just_read_id = false;
                            just_read_num = false;
last_id = "";
                            if (extra_div && !err_missing_index)
                            {
                              tmp_write = "_temp" + toString(tmp_cnt);
                              output += ". " + tmp_write + "\n";
                              output += "/ " + tmp_write + ", " + temps.at(1) + ", " + temps.back() + "\n";
                              output += "[]= " + ids.at(0) + ", " + nums.at(0) + ", " + tmp_write + "\n";
                              
                              tmp_cnt++;
                            }
                            else
                            {
                              div_flag = true;
                            }
                          }
                          | term MOD term
                          {
                            if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                            just_read_id = false;
                            just_read_num = false;
last_id = "";
                            if (extra_mod && !err_missing_index)
                            {
                              tmp_write = "_temp" + toString(tmp_cnt);
                              output += ". " + tmp_write + "\n";
                              output += "% " + tmp_write + ", " + temps.at(1) + ", " + temps.back() + "\n";
                              output += "[]= " + ids.at(0) + ", " + nums.at(0) + ", " + tmp_write + "\n";
                              
                              tmp_cnt++;
                            }
                            else
                            {
                              mod_flag = true;
                            }
                          };

term:             var 
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | number
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | OPEN_PAR expression CLOSE_PAR
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | ident OPEN_PAR expression id_expr CLOSE_PAR
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    tmp_write = "_temp" + toString(tmp_cnt);
                
                    output += "param " + ids.at(ids.size()-2) + "\n";
                    output += "param " + ids.at(ids.size()-1) + "\n";
                    output += tmp_write + "\n";
                    output += "call " + ids.at(1) + ", " + tmp_func;
                    func_call = true;
                  };

id_expr:          /* epsilon */
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  }
                  | COMMA expression id_expr
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  };

var:              ident
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                    
                    if(ids.size() > 0) {
                      for(int x = 0; x < ids.size(); x++) {
                        isDeclared = find_symbol(ids.at(x));
                        if(!isDeclared && (ids.at(x).size() == 1)) {
                          fprintf(stderr, "error at line %d: variable used is not declared\n", currLine);

                          exit(-1);
                        }
                        else if(!isDeclared) {
                          fprintf(stderr, "error at line %d: function used is not declared\n", currLine);

                          exit(-1);
                        }
                        
                      }
                    }
                  }
                  | ident OPEN_BRACKET expression CLOSE_BRACKET
                  {
                    if (just_read_id)
                    {
                      if (get_symbol_type(last_id) == "array" && !just_read_num)
                      {
                        err_missing_index = true;
                        has_error = true;
                        err_missing_index_line = currLine;
                      }
                    }
                    just_read_id = false;
                    just_read_num = false;
last_id = "";
                  };
%% 

int main(int argc, char **argv) {
   yyparse();

  if (err_missing_index)
  {
    std::cout << "Used array variable " << arr_var << " at line " << toString(err_missing_index_line) << " is missing a specified index.\n";
  }
  if (err_continue)
  {
    std::cout << "Continue statement at line " << toString(err_continue_line) << " not within loop.\n";
  }
  if (err_break)
  {
    std::cout << "Break statement at line " << toString(err_break_line) << " not within loop.\n";
  }
  if (err_arr_size)
  {
    std::cout << "Array " << arr_var << "\'s index at line " << toString(err_arr_size_line) + " is <= 0.\n";
  }
  if (err_index_type)
  {
    std::cout << "Array index is not integer at line " << toString(err_index_type_line) + ".\n";
  }
  
  if (!has_error)
  {
    print_symbol_table();
    std::cout << "Output: \n" << output;

    std::ofstream outFile;
    outFile.open("output.mil");
    outFile << output;
    outFile.close();
  }

   return 0;
}

//Using a variable without having first declared it.
//Calling a function which has not been defined.
//Not defining a main function.
//Defining a variable more than once.
//Trying to name a variable with the same name as a reserved keyword.

void yyerror(const char *msg) {
  extern int currLine;

  fprintf(stderr, "Syntax error at line %d: %s\n", currLine, msg);
}

