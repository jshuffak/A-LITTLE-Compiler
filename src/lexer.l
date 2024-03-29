
%top{
#include <iostream>
#include <fstream>
#include <string.h>
#include <string>
#include <vector>
#include "grammar.tab.hpp"
#include "scanner.hpp"
  
// Move this to anothe file
#include "parser.hpp"

#define PRINT_INFO(name, value)				\
  do {							\
    *yyout << "Token Type: " << (name) << std::endl <<	\
    "Value: " << (value) << std::endl;			\
  }while(0)

#define yyterminate() return(token::END)
}

%option noyywrap
%option nodefault
%option yyclass="LittleScanner"
%option c++

keyword PROGRAM|BEGIN|END|FUNCTION|READ|WRITE|IF|ELSIF|ENDIF|DO|WHILE|CONTINUE|BREAK|RETURN|INT|VOID|STRING|FLOAT|TRUE|FALSE
identifier    [a-zA-Z_][a-zA-Z_0-9]{0,30}
floatliteral  [0-9]*[.][0-9]+
intliteral    [0-9]+
stringliteral \"[^"]{0,80}\"
comment       [-]{2}.*
operator [:][=]|[+]|[-]|[*]|[/]|[=]|[<]|[>]|[(]|[)]|[;]|[,]|[;]|[<][=]|[>][=]|[!][=]
whitespace    [ \n\t\r]+
other	      .

%%

PROGRAM    {PRINT_INFO("KEYWORD", YYText()); return PROGRAM   ;}
BEGIN      {PRINT_INFO("KEYWORD", YYText()); return BEGINT    ;}
END        {PRINT_INFO("KEYWORD", YYText()); return END       ;}
FUNCTION   {PRINT_INFO("KEYWORD", YYText()); return FUNCTION  ;}
READ       {PRINT_INFO("KEYWORD", YYText()); return READ      ;}
WRITE      {PRINT_INFO("KEYWORD", YYText()); return WRITE     ;}
IF         {PRINT_INFO("KEYWORD", YYText()); return IF        ;}
ELSIF      {PRINT_INFO("KEYWORD", YYText()); return ELSIF     ;}
ENDIF      {PRINT_INFO("KEYWORD", YYText()); return ENDIF     ;}
DO         {PRINT_INFO("KEYWORD", YYText()); return DO        ;}
WHILE      {PRINT_INFO("KEYWORD", YYText()); return WHILE     ;}
CONTINUE   {PRINT_INFO("KEYWORD", YYText()); return CONTINUE  ;}
BREAK      {PRINT_INFO("KEYWORD", YYText()); return BREAK     ;}
RETURN     {PRINT_INFO("KEYWORD", YYText()); return RETURN    ;}
INT        {PRINT_INFO("KEYWORD", YYText()); return INT       ;}
VOID       {PRINT_INFO("KEYWORD", YYText()); return VOID      ;}
STRING     {PRINT_INFO("KEYWORD", YYText()); return STRING    ;}
FLOAT      {PRINT_INFO("KEYWORD", YYText()); return FLOAT     ;}
TRUE       {PRINT_INFO("KEYWORD", YYText()); return TRUE      ;}
FALSE      {PRINT_INFO("KEYWORD", YYText()); return FALSE     ;}


{identifier}	  {PRINT_INFO("IDENTIFIER", YYText());   yylval.str_val = strdup(YYText()); return(IDENTIFIER);}
{floatliteral}	  {PRINT_INFO("FLOATLITERAL", YYText()); yylval.str_val = strdup(YYText()); return(FLOATLITERAL);}
{intliteral}	  {PRINT_INFO("INTLITERAL", YYText());   yylval.str_val = strdup(YYText()); return (INTLITERAL);}
{stringliteral}	  {PRINT_INFO("STRINGLITERAL",YYText()); yylval.str_val = strdup(YYText()); return (STRINGLITERAL);}
{comment}	  ;
{operator}	  {
  PRINT_INFO("OPERATOR", YYText());
  if(!strcmp(YYText(), "<"))
    return LESSTHAN;
  else if(!strcmp(YYText(), ">"))
    return GREATERTHAN;
  else if(!strcmp(YYText(), "="))
    return EQUAL;
  else if(!strcmp(YYText(), "!="))
    return NOTEQUAL;
  else if(!strcmp(YYText(), "<="))
    return LESSTHANEQUAL;
  else if(!strcmp(YYText(), ">="))
    return GREATERTHANEQUAL;
  else if(!strcmp(YYText(), ":="))
    return COLONEQUAL;
  else if(!strcmp(YYText(), "("))
    return PARANTHLEFT;
  else if(!strcmp(YYText(), ")"))
    return PARANTHRIGHT;
  else if(!strcmp(YYText(), ";"))
    return SEMICOLON;
  else if(!strcmp(YYText(), ","))
    return COMMA;
  else if(!strcmp(YYText(), "+"))
    return PLUS;
  else if(!strcmp(YYText(), "-"))
    return MINUS;
  else if(!strcmp(YYText(), "*"))
    return MULTIPLY;
  else if(!strcmp(YYText(), "/"))
    return DIVIDE;
  else
    return COMMENT;

}
{whitespace}	  ;
{other} {return (COMMENT);}
%%

int main(int argc, char** argv){
  std::stringstream ss;
  std::ifstream file(argv[1]);
  LittleParser parser = LittleParser(&file);
  try {
    try{
      parser.parse();
    }
    catch(std::string a) {
      std::cerr << a << std::endl;
    }
    if (parser.accepted()) {
      try {
	ss << ";IR code" << std::endl;
	parser.print_ir(ss);
	ss << ";tiny code" << std::endl;
      }
      catch(std::string a){
	std::cerr << a << std::endl;
      }
      catch(const char* a){
	std::cerr << a << std::endl;
      }
      parser.table_factory.print_global_declarations(ss);
      try{
	parser.print_assembly(ss);
      }
      catch(std::string str){
	std::cerr << "Assembly problem: " << str << std::endl;
      }
      catch(const char* str){
	std::cerr << "Assembly problem: " << str << std::endl;
      }
      std::cout << ss.rdbuf() << std::endl;
    }
    else
      parser.table_factory.print_table_stack_trace(ss) ;
      std::cout << ss.rdbuf();
    }
    catch (const char* c){
      std::cout <<  c << std::endl;
    }
}

