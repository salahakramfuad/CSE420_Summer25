#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id = 1;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {

        unsigned long hash = 0;
        int prime = 29; // A prime number as the base
        for (char c : name)
        {
            hash = (hash * prime + c) % bucket_count;
        }
        return hash;
    }

public:
    scope_table();
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope);
    scope_table *get_parent_scope()
    {
        return parent_scope;
    }
    int get_unique_id()
    {
        return unique_id;
    }
    symbol_info *lookup_in_scope(symbol_info *symbol)
    {
        int index = hash_function(symbol->get_name());
        for (auto symbol : table[index])
        {
            if (symbol->get_name() == symbol->get_name())
                return symbol; // Symbol found
        }
        // If not found in the current scope, check the parent scope
        if (parent_scope != nullptr)
        {
            return parent_scope->lookup_in_scope(symbol); // Recursive call to parent scope
        }
        return nullptr; // Symbol not found
    }

    bool insert_in_scope(symbol_info *symbol)
    {
        if (lookup_in_scope(symbol->get_name()) != nullptr)
        {
            return false; // Symbol already exists
        }

        int index = hash_function(symbol->get_name());
        table[index].push_back(symbol); // Insert the symbol
        return true;
    }
    bool delete_from_scope(symbol_info *symbol)
    {
        if (lookup_in_scope(symbol->get_name()) != nullptr)
        {

            return true; // Symbol already exists
        }

        return false;
    }

    void print_scope_table(ofstream &outlog);

    ~scope_table();

    // you can add more methods if you need
};

// complete the methods of scope_table class
void scope_table::print_scope_table(ofstream &outlog)
{
    outlog << "ScopeTable # " + to_string(unique_id) << endl;

    // iterate through the current scope table and print the symbols and all relevant information
}