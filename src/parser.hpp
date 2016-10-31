#ifndef _PARSER_H_
#define _PARSER_H_

#include "scanner.hpp"
#include "table_factory.hpp"
#include "data_object.hpp"
#include "iri.hpp"
#include "memory_set.hpp"

#include <iostream>
#include <sstream>
#include <vector>
#include <list>
class LittleParser;

extern int yyparse(LittleParser& parser, LittleScanner& scanner);

class LittleParser{
  public:

    // Constructors / Destructors
    LittleParser(std::istream* i, std::ostream* o);
    LittleParser(std::istream* i);
    ~LittleParser();

    // Externally visible functions
    void parse();
    void error(const char* error);
    bool accepted();
    const char* get_error_message();
    void print_ir(std::stringstream& ss);
    void print_assembly(std::stringstream& ss);

    // Memory management functions
    void register_str_arr(std::vector<char*>*);
    void register_sym_arr(std::list<Symbol*>*);
    MemorySet<half_expr_t> half_expr_set;
    MemorySet<DataObject>  data_object_set;


    // Global parse data structures
    TableFactory table_factory;

    // Label management
    void push_label(int label);
    void pop_label();
    int peek_label();
    IRI* label_to_iri(int label);
    IRI* jump_to_label(int label);

    void iri_list_push_back(IRI*);
    std::list<IRI*> iri_list;

  private:
    std::vector<int> label_stack;
    bool accept;
    LittleScanner scanner;
    const char* error_message;
    std::vector<std::vector<char*>* > str_arr_arr;
    std::vector<std::list<Symbol*>* > sym_arr_arr;

};

#endif
