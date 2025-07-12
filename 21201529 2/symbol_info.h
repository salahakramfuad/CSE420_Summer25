#include <bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name; // Name of the symbol
    string type; // Type of the symbol (int, float, void, etc.)

    // Category of the symbol (variable, array, function)
    string symbol_category;
    // Write necessary attributes to store the type/return type of the symbol (int/float/void/...) for functions
    string return_type;
    // Write necessary attributes to store the parameters of a function
    vector<string> parameter_types; // Parameter types (for functions)
    vector<string> parameter_names; // Parameter names (for functions)
    // Size of the array (if the symbol is an array)
    int array_size;

public:
    // Constructor
    symbol_info(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->array_size = -1;              // Default: not an array
        this->symbol_category = "variable"; // Default category: variable
    }

    // Getters and setters for name and type
    string get_name()
    {
        return name;
    }

    string get_type()
    {
        return type;
    }

    void set_name(string name)
    {
        this->name = name;
    }

    void set_type(string type)
    {
        this->type = type;
    }

    // Getters and setters for symbol category
    string get_symbol_category()
    {
        return symbol_category;
    }

    void set_symbol_category(string category)
    {
        this->symbol_category = category;
    }

    // Getters and setters for return type (for functions)
    string get_return_type()
    {
        return return_type;
    }

    void set_return_type(string returnType)
    {
        this->return_type = returnType;
    }

    // Getters and setters for array size
    int get_array_size()
    {
        return array_size;
    }

    void set_array_size(int size)
    {
        this->array_size = size;
    }

    // Getters and setters for function parameters
    vector<string> get_parameter_types()
    {
        return parameter_types;
    }

    void set_parameter_types(const vector<string> &params)
    {
        this->parameter_types = params;
    }

    vector<string> get_parameter_names()
    {
        return parameter_names;
    }

    void set_parameter_names(const vector<string> &params)
    {
        this->parameter_names = params;
    }

    void add_parameter(string param_type, string param_name)
    {
        parameter_types.push_back(param_type);
        parameter_names.push_back(param_name);
    }

    // Destructor
    ~symbol_info()
    {
        // No dynamically allocated memory to free in this implementation
        parameter_types.clear();
        parameter_names.clear();
    }
};