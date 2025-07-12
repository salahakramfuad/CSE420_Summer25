%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// Symbol table creation
symbol_table *symboltable = new symbol_table(20); // Initialize with an appropriate size

// Line counter
int lines = 1;

// Log file output stream
ofstream outlog("parser_log.txt");

// Necessary variables for parsing
string current_variable_type = "";        // Current variable type
vector<string> variable_list;             // List of variables
string current_function_name = "";        // Current function name
string current_function_return_type = ""; // Return type of the current function
vector<string> parameter_types;           // Parameter types for functions
vector<string> parameter_names;           // Parameter names for functions

void yyerror(char *s)
{
    outlog << "At line " << lines << ": " << s << endl << endl;

    // Reinitialize variables upon error
    current_variable_type.clear();
    variable_list.clear();
    current_function_name.clear();
    current_function_return_type.clear();
    parameter_types.clear();
    parameter_names.clear();
}

%}


%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
    {
        outlog << "At line no: " << lines << " start : program " << endl << endl;
        outlog << "Symbol Table" << endl << endl;

        // Print your whole symbol table here
        symboltable->print_all_scopes(outlog); // Assuming a printAll function exists in SymbolTable
    }
    ;

program : program unit
    {
        outlog << "At line no: " << lines << " program : program unit " << endl << endl;
        outlog << $1->get_name() << "\n" << $2->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + "\n" + $2->get_name(), "program");
    }
    | unit
    {
        outlog << "At line no: " << lines << " program : unit " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "program");
    }
    ;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN enter_scope compound_statement exit_scope
    {
        outlog << "At line no: " << lines
               << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " << endl
               << endl;
        outlog << $1->get_name() << " " << $2->get_name() << "(" << $4->get_name() << ")\n" << $7->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + " " + $2->get_name() + "(" + $4->get_name() + ")\n" + $7->get_name(), "func_def");

        // Insert the function into the symbol table
        symbol_info *new_func = new symbol_info($2->get_name(), "FUNCTION");
        if (!symboltable->insert(new_func))
        {
            outlog << "Error: Function " << $2->get_name() << " already defined!" << endl << endl;
            delete new_func; // Cleanup if insertion fails
        }
        else
        {
            outlog << "Function " << $2->get_name() << " inserted into symbol table." << endl << endl;
        }
    }
    | type_specifier ID LPAREN RPAREN enter_scope compound_statement exit_scope
    {
        outlog << "At line no: " << lines
               << " func_definition : type_specifier ID LPAREN RPAREN compound_statement " << endl << endl;
        outlog << $1->get_name() << " " << $2->get_name() << "()\n" << $6->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + " " + $2->get_name() + "()\n" + $6->get_name(), "func_def");

        // Insert the function into the symbol table
        symbol_info *new_func = new symbol_info($2->get_name(), "FUNCTION");
        if (!symboltable->insert(new_func))
        {
            outlog << "Error: Function " << $2->get_name() << " already defined!" << endl << endl;
            delete new_func; // Cleanup if insertion fails
        }
        else
        {
            outlog << "Function " << $2->get_name() << " inserted into symbol table." << endl << endl;
        }
    }
    ;

enter_scope :
    {
        outlog << "Entering a new scope" << endl;
        symboltable->enter_scope();
    }
    ;

exit_scope :
    {
        outlog << "Exiting the current scope" << endl;
        symboltable->exit_scope();
    }
    ;

parameter_list : parameter_list COMMA type_specifier ID
    {
        outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier ID " << endl << endl;
        outlog << $1->get_name() << "," << $3->get_name() << " " << $4->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + "," + $3->get_name() + " " + $4->get_name(), "param_list");

        // Insert the parameter into the current scope
        symbol_info *param = new symbol_info($4->get_name(), "PARAMETER");
        param->set_type($3->get_name()); // Assuming you have a setType method for type handling
        if (!symboltable->insert(param))
        {
            outlog << "Error: Parameter " << $4->get_name() << " already declared in this scope!" << endl << endl;
            delete param;
        }
        else
        {
            outlog << "Parameter " << $4->get_name() << " of type " << $3->get_name() << " inserted." << endl << endl;
        }
    }
    | parameter_list COMMA type_specifier
    {
        outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier " << endl << endl;
        outlog << $1->get_name() << "," << $3->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + "," + $3->get_name(), "param_list");
        // No parameter name to insert here; only type is provided.
    }
    | type_specifier ID
    {
        outlog << "At line no: " << lines << " parameter_list : type_specifier ID " << endl << endl;
        outlog << $1->get_name() << " " << $2->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + " " + $2->get_name(), "param_list");

        // Insert the parameter into the current scope
        symbol_info *param = new symbol_info($2->get_name(), "PARAMETER");
        param->set_type($1->get_name()); // Assuming you have a setType method for type handling
        if (!symboltable->insert(param))
        {
            outlog << "Error: Parameter " << $2->get_name() << " already declared in this scope!" << endl << endl;
            delete param;
        }
        else
        {
            outlog << "Parameter " << $2->get_name() << " of type " << $1->get_name() << " inserted." << endl << endl;
        }
    }
    | type_specifier
    {
        outlog << "At line no: " << lines << " parameter_list : type_specifier " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "param_list");
        // No parameter name to insert here; only type is provided.
    }
    ;


compound_statement : LCURL enter_scope statements RCURL exit_scope
    { 
        outlog << "At line no: " << lines << " compound_statement : LCURL statements RCURL " << endl << endl;
        outlog << "{\n" << $3->get_name() << "\n}" << endl << endl;

        $$ = new symbol_info("{\n" + $3->get_name() + "\n}", "comp_stmnt");
        
        // The compound statement is complete.
        // The symbol table has already been printed and scope exited by exit_scope.
    }
    | LCURL enter_scope RCURL exit_scope
    { 
        outlog << "At line no: " << lines << " compound_statement : LCURL RCURL " << endl << endl;
        outlog << "{\n}" << endl << endl;

        $$ = new symbol_info("{\n}", "comp_stmnt");

        // The compound statement is complete.
        // The symbol table has already been printed and scope exited by exit_scope.
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
    {
        outlog << "At line no: " << lines << " var_declaration : type_specifier declaration_list SEMICOLON " << endl << endl;
        outlog << $1->get_name() << " " << $2->get_name() << ";" << endl << endl;

        $$ = new symbol_info($1->get_name() + " " + $2->get_name() + ";", "var_dec");

        // Insert variables into the symbol table
        string type = $1->get_name(); // Variable type
        vector<symbol_info*> variables = $2->get_variable_list(); // Use helper to extract variables and array details

        for (symbol_info* var : variables)
        {
            var->set_data_type(type); // Set type
            if (var->get_is_array()) 
            {
                var->set_array_size(stoi(var->get_name())); // Assuming array size is part of name or defined elsewhere
            }
            if (!symboltable->insert(var))
            {
                outlog << "Error: Variable " << var->get_name() << " already declared in this scope!" << endl << endl;
                delete var; // Prevent memory leak
            }
            else
            {
                outlog << "Variable " << var->get_name() << " of type " << type << " inserted." << endl << endl;
            }
        }
    }
    ;

type_specifier : INT
    {
        outlog << "At line no: " << lines << " type_specifier : INT " << endl << endl;
        outlog << "int" << endl << endl;

        $$ = new symbol_info("int", "type");
    }
    | FLOAT
    {
        outlog << "At line no: " << lines << " type_specifier : FLOAT " << endl << endl;
        outlog << "float" << endl << endl;

        $$ = new symbol_info("float", "type");
    }
    | VOID
    {
        outlog << "At line no: " << lines << " type_specifier : VOID " << endl << endl;
        outlog << "void" << endl << endl;

        $$ = new symbol_info("void", "type");
    }
    ;

declaration_list : declaration_list COMMA ID
    {
        outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID " << endl << endl;
        outlog << $1->get_name() + "," << $3->get_name() << endl << endl;

        $$ = $1;
        $$->add_variable(new symbol_info($3->get_name(), "VARIABLE"));
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
    {
        outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD " << endl << endl;
        outlog << $1->get_name() + "," << $3->get_name() << "[" << $5->get_name() << "]" << endl << endl;

        $$ = $1;
        $$->add_variable(new symbol_info($3->get_name() + "[" + $5->get_name() + "]", "ARRAY"));
    }
    | ID
    {
        outlog << "At line no: " << lines << " declaration_list : ID " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info("list", "var_list");
        $$->add_variable(new symbol_info($1->get_name(), "VARIABLE"));
    }
    | ID LTHIRD CONST_INT RTHIRD
    {
        outlog << "At line no: " << lines << " declaration_list : ID LTHIRD CONST_INT RTHIRD " << endl << endl;
        outlog << $1->get_name() << "[" << $3->get_name() << "]" << endl << endl;

        $$ = new symbol_info("list", "var_list");
        $$->add_variable(new symbol_info($1->get_name() + "[" + $3->get_name() + "]", "ARRAY"));
    }
    ;



statements : statement
    {
        outlog << "At line no: " << lines << " statements : statement " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "stmnts");
        
        // Insert statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Statement " << $1->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Statement " << $1->get_name() << " inserted." << endl << endl;
        }
    }
    | statements statement
    {
        outlog << "At line no: " << lines << " statements : statements statement " << endl << endl;
        outlog << $1->get_name() << "\n" << $2->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name() + "\n" + $2->get_name(), "stmnts");

        // Insert concatenated statements into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Statement " << $1->get_name() + "\n" + $2->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Statement " << $1->get_name() + "\n" + $2->get_name() << " inserted." << endl << endl;
        }
    }
    ;

	   
statement : var_declaration
    {
        outlog << "At line no: " << lines << " statement : var_declaration " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "stmnt");

        // Insert the variable declaration symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Variable declaration " << $1->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Variable declaration " << $1->get_name() << " inserted." << endl << endl;
        }
    }
    | func_definition
    {
        outlog << "At line no: " << lines << " statement : func_definition " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "stmnt");

        // Insert the function definition symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Function definition " << $1->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Function definition " << $1->get_name() << " inserted." << endl << endl;
        }
    }
    | expression_statement
    {
        outlog << "At line no: " << lines << " statement : expression_statement " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "stmnt");

        // Insert the expression statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Expression statement " << $1->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Expression statement " << $1->get_name() << " inserted." << endl << endl;
        }
    }
    | compound_statement
    {
        outlog << "At line no: " << lines << " statement : compound_statement " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        $$ = new symbol_info($1->get_name(), "stmnt");

        // Insert the compound statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Compound statement " << $1->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Compound statement " << $1->get_name() << " inserted." << endl << endl;
        }
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement
    {
        outlog << "At line no: " << lines << " statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement " << endl << endl;
        outlog << "for(" << $3->get_name() << $4->get_name() << $5->get_name() << ")\n" << $7->get_name() << endl << endl;

        $$ = new symbol_info("for(" + $3->get_name() + $4->get_name() + $5->get_name() + ")\n" + $7->get_name(), "stmnt");

        // Insert the for loop statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: For loop " << $3->get_name() + $4->get_name() + $5->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "For loop " << $3->get_name() + $4->get_name() + $5->get_name() << " inserted." << endl << endl;
        }
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
    {
        outlog << "At line no: " << lines << " statement : IF LPAREN expression RPAREN statement " << endl << endl;
        outlog << "if(" << $3->get_name() << ")\n" << $5->get_name() << endl << endl;

        $$ = new symbol_info("if(" + $3->get_name() + ")\n" + $5->get_name(), "stmnt");

        // Insert the if statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: If statement " << $3->get_name() + $5->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "If statement " << $3->get_name() + $5->get_name() << " inserted." << endl << endl;
        }
    }
    | IF LPAREN expression RPAREN statement ELSE statement
    {
        outlog << "At line no: " << lines << " statement : IF LPAREN expression RPAREN statement ELSE statement " << endl << endl;
        outlog << "if(" << $3->get_name() << ")\n" << $5->get_name() << "\nelse\n" << $7->get_name() << endl << endl;

        $$ = new symbol_info("if(" + $3->get_name() + ")\n" + $5->get_name() + "\nelse\n" + $7->get_name(), "stmnt");

        // Insert the if-else statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: If-else statement " << $3->get_name() + $5->get_name() + $7->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "If-else statement " << $3->get_name() + $5->get_name() + $7->get_name() << " inserted." << endl << endl;
        }
    }
    | WHILE LPAREN expression RPAREN statement
    {
        outlog << "At line no: " << lines << " statement : WHILE LPAREN expression RPAREN statement " << endl << endl;
        outlog << "while(" << $3->get_name() << ")\n" << $5->get_name() << endl << endl;

        $$ = new symbol_info("while(" + $3->get_name() + ")\n" + $5->get_name(), "stmnt");

        // Insert the while statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: While statement " << $3->get_name() + $5->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "While statement " << $3->get_name() + $5->get_name() << " inserted." << endl << endl;
        }
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON
    {
        outlog << "At line no: " << lines << " statement : PRINTLN LPAREN ID RPAREN SEMICOLON " << endl << endl;
        outlog << "printf(" << $3->get_name() << ");" << endl << endl;

        $$ = new symbol_info("printf(" + $3->get_name() + ");", "stmnt");

        // Insert the print statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Print statement " << $3->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Print statement " << $3->get_name() << " inserted." << endl << endl;
        }
    }
    | RETURN expression SEMICOLON
    {
        outlog << "At line no: " << lines << " statement : RETURN expression SEMICOLON " << endl << endl;
        outlog << "return " << $2->get_name() << ";" << endl << endl;

        $$ = new symbol_info("return " + $2->get_name() + ";", "stmnt");

        // Insert the return statement symbol into the symbol table
        if (!symboltable->insert($$))
        {
            outlog << "Error: Return statement " << $2->get_name() << " already exists!" << endl << endl;
        }
        else
        {
            outlog << "Return statement " << $2->get_name() << " inserted." << endl << endl;
        }
    }
    ;

	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->get_name()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->get_name()+";","expr_stmt");
	        }
			;
	  
variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"varbl");
		
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;
		
		$$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]","varbl");
	 }
	 ;
	 
expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"expr");
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<"="<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+"="+$3->get_name(),"expr");
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"lgc_expr");
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"lgc_expr");
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"rel_expr");
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"rel_expr");
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"simp_expr");
			
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"simp_expr");
	      }
		  ;
					
term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"term");
			
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"term");
			
	 }
     ;

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+$2->get_name(),"un_expr");
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info("!"+$2->get_name(),"un_expr");
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"un_expr");
	     }
		 ;
	
factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->get_name()<<"("<<$3->get_name()<<")"<<endl<<endl;

		$$ = new symbol_info($1->get_name()+"("+$3->get_name()+")","fctr");
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->get_name()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->get_name()+")","fctr");
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->get_name()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1->get_name()+"++","fctr");
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->get_name()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1->get_name()+"--","fctr");
	}
	;
	
argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->get_name()<<endl<<endl;
						
					$$ = new symbol_info($1->get_name(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<","<<$3->get_name()<<endl<<endl;
						
				$$ = new symbol_info($1->get_name()+","+$3->get_name(),"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<endl<<endl;
						
				$$ = new symbol_info($1->get_name(),"arg");
		  }
	      ;
 

%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("my_log.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
	// Enter the global or the first scope here
    symboltable->enter_scope();
	outlog << "Starting parsing..." << endl;

	yyparse();
	symboltable->exit_scope();
	outlog<<endl<<"Total lines: "<<lines<<endl;
	
	outlog.close();
	
	fclose(yyin);
	
	return 0;
}