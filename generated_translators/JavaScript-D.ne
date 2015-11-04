
#The following expressions are the same in every language.

chunk -> _ ( series_of_statements | class | class_extends) _ {%function(d){
	toReturn = d[1][0];
	if(Array.isArray(toReturn)){
		return d.join("");
	}
	else{
		return d[1][0];
	}
}%}

series_of_statements -> statement {%function(d){return d[0];}%} | series_of_statements statement_separator __ statement {%function(d){return d[0] + d[1] + "\n" + d[3];}%}

dot_notation -> dot_notation _dot_notation identifier {%function(d){ return d[0] + d[1] + d[2] }%} | identifier

arithmetic_expression -> expression
boolean_expression -> expression
string_expression -> expression
array_expression -> expression

statement_with_semicolon -> statement_without_semicolon _ semicolon {% function(d){return d[0] + d[2]; }%}

expression -> string_to_regex | accessArray | this | functionCall | varName | dictionary | declare_new_object
| parentheses_expression | pi | natural_logarithm | absolute_value | floor | ceiling | string_to_int | add | subtract | multiply | mod | divide | number | pow | strlen | asin | acos | atan | sin | cos | tan | sqrt | array_length
| String | concatenateString | substring | int_to_string | split | join | startswith | endswith | globalReplace
| initializerList | range
| false | true | instanceof | not_equal | greaterThan | compareInts | strcmp | lessThanOrEqual | greaterThanOrEqual | lessThan | and | or | not | arrayContains | stringContains

statement_without_semicolon -> typeless_variable_declaration | setVar | increment | decrement | initializeEmptyVar | initializeVar | typeless_initializeVar | functionCall | exception | return | functionCallStatement | plusEquals | minusEquals | declare_constant | initializeArray | print
statement ->   func | statement_with_semicolon | for_loop | typeless_function | comment | switch | if | while | forInRange

class_statement_without_semicolon -> initialize_static_variable_with_value | initialize_instance_variable_with_value | initialize_static_variable | initialize_instance_variable
class_statement_with_semicolon -> class_statement_without_semicolon _ semicolon {% function(d){return d[0] + d[2]; }%}
class_statement -> constructor | instance_method | static_method | comment | class_statement_with_semicolon

_class_statements -> class_statements _ class_statement {%function(d){return d[0] +"\n"+ d[2];}%} | class_statement {%function(d){return d[0];}%} | null
class_statements -> class_statement {%function(d){return d[0];}%} | class_statements _ class_statement {%function(d){return d[0] + "\n" + d[2];}%}


type -> boolean | int | double | string | auto | arrayType | void | dictionary_type
caseStatements -> caseStatements _ case {%function(d){return d[0] +"\n"+ d[2];}%} | case
elifOrElse -> else | elif

parameterList -> _parameterList | null
_parameterList -> _parameterList _ parameter_separator _ ( parameter | default_parameter ) {%function(d){return d[0]+d[2]+d[4]}%}
| (parameter | default_parameter )

typeless_parameters -> _typeless_parameters | null
_typeless_parameters -> _typeless_parameters _ parameter_separator _ typeless_parameter {%function(d){return d[0]+d[2]+d[4]}%}
| typeless_parameter

functionCallParameters -> functionCallParameters _ function_call_parameter_separator _ ( expression | function_call_named_parameter) {% function(d) {return d.join(""); } %} | (expression | function_call_named_parameter) | null

keyValueList -> _keyValueList
_keyValueList -> _keyValueList _ keyValueSeparator _ keyValue {%function(d){return d[0]+d[2]+d[4]}%}
| keyValue

_initializerList -> _initializerList _ initializerListSeparator _ expression {%function(d){return d[0]+d[2]+d[4]}%}
| expression

array_access_list -> array_access_index | array_access_list array_access_separator array_access_index {%function(d){return d[0]+d[1]+d[2]}%}

# Primitives
# ==========

identifier -> _name {% function(d) {return d[0]; } %}

_name -> [a-zA-Z_] {% id %}
	| _name [\w_] {% function(d) {return d[0] + d[1]; } %}

# Numbers

number -> _number {% function(d) {return parseFloat(d[0])} %}

_posint ->
	[0-9] {% id %}
	| _posint [0-9] {% function(d) {return d[0] + d[1]} %}

_int ->
	"-" _posint {% function(d) {return d[0] + d[1]; }%}
	| _posint {% id %}

_float ->
	_int {% id %}
	| _int "." _posint {% function(d) {return d[0] + d[1] + d[2]; }%}

_number ->
	_float {% id %}
	| _float "e" _int {% function(d){return d[0] + d[1] + d[2]; } %}


#Strings

String -> "\"" _string "\"" {% function(d) {return '"' + d[1] + '"'; } %}

_string ->
	null {% function() {return ""; } %}
	| _string _stringchar {% function(d) {return d[0] + d[1];} %}

_stringchar ->
	[^\\"] {% id %}
	| "\\" [^] {% function(d) {return JSON.parse("\"" + d[0] + d[1] + "\""); } %}

# Whitespace
_ -> null | _ [\s] {% function() {} %}
__ -> [\s] | __ [\s] {% function() {} %}


#The next two lines are the languages for the translator.
increment -> expression _ "++"{%function(d){
	return d[0] + "" + "++";
}%}
decrement -> expression _ "--"{%function(d){
	return d[0] + "" + "--";
}%}
typeless_initializeVar -> "var" __ varName _ "=" _ expression{%function(d){
	return "auto" + " " + d[2] + "" + "=" + "" + d[6];
}%}
asin -> "Math" _ "." _ "asin" _ "(" _ expression _ ")"{%function(d){
	return "asin" + "" + "(" + "" + d[8] + "" + ")";
}%}
acos -> "Math" _ "." _ "acos" _ "(" _ expression _ ")"{%function(d){
	return "acos" + "" + "(" + "" + d[8] + "" + ")";
}%}
atan -> "Math" _ "." _ "atan" _ "(" _ expression _ ")"{%function(d){
	return "atan" + "" + "(" + "" + d[8] + "" + ")";
}%}
statement_separator -> _{%function(d){
	return "";
}%}
for_loop -> "for" _ "(" _ statement_without_semicolon _ ";" _ expression _ ";" _ statement_without_semicolon _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "for" + "" + "(" + "" + d[4] + "" + ";" + "" + d[8] + "" + ";" + "" + d[12] + "" + ")" + "" + "{" + "" + d[18] + "" + "}";
}%}
typeless_parameter -> identifier{%function(d){
	return "auto" + " " + d[0];
}%}
typeless_function -> "function" __ identifier _ "(" _ typeless_parameters _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "auto" + " " + d[2] + "" + "(" + "" + d[6] + "" + ")" + "" + "{" + "" + d[12] + "" + "}";
}%}
typeless_variable_declaration -> "var" __ varName _ "=" _ identifier{%function(d){
	return "auto" + " " + d[2] + "" + "=" + "" + d[6];
}%}
int_to_string -> "String" _ "(" _ expression _ ")"{%function(d){
	return "std" + "" + "." + "" + "conv" + "" + "." + "" + "to!string" + "" + "(" + "" + d[4] + "" + ")";
}%}
split -> expression _ "." _ "split" _ "(" _ expression _ ")"{%function(d){
	return "split" + "" + "(" + "" + d[0] + "" + "," + "" + d[8] + "" + ")";
}%}
join -> "array" _ "." _ "join" _ "(" _ "separator" _ ")"{%function(d){
	return "join" + "" + "(" + "" + "array" + "" + "," + "" + "separator" + "" + ")";
}%}
function_call_parameter_separator -> ","{%function(d){
	return ",";
}%}
string_to_int -> "parseInt" _ "(" _ expression _ ")"{%function(d){
	return "std" + "" + "." + "" + "conv" + "" + "." + "" + "to!int" + "" + "(" + "" + d[4] + "" + ")";
}%}
array_access_separator -> "]["{%function(d){
	return "][";
}%}
array_access_index -> expression{%function(d){
	return d[0];
}%}
accessArray -> identifier _ "[" _ array_access_list _ "]"{%function(d){
	return d[0] + "" + "[" + "" + d[4] + "" + "]";
}%}
initializerListSeparator -> ","{%function(d){
	return ",";
}%}
initializerList -> "[" _ _initializerList _ "]"{%function(d){
	return "[" + "" + d[2] + "" + "]";
}%}
keyValue -> identifier _ ":" _ expression{%function(d){
	return d[0] + "" + ":" + "" + d[4];
}%}
anonymousFunction -> "function" _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "(" + "" + d[4] + "" + ")" + "" + "{" + "" + "body" + "" + "}";
}%}
auto -> "var"{%function(d){
	return "auto";
}%}
void -> _{%function(d){
	return "void";
}%}
sin -> "Math" _ "." _ "sin" _ "(" _ expression _ ")"{%function(d){
	return "sin" + "" + "(" + "" + d[8] + "" + ")";
}%}
sqrt -> "Math" _ "." _ "sqrt" _ "(" _ expression _ ")"{%function(d){
	return "sqrt" + "" + "(" + "" + d[8] + "" + ")";
}%}
cos -> "Math" _ "." _ "cos" _ "(" _ expression _ ")"{%function(d){
	return "cos" + "" + "(" + "" + d[8] + "" + ")";
}%}
tan -> "Math" _ "." _ "tan" _ "(" _ expression _ ")"{%function(d){
	return "tan" + "" + "(" + "" + d[8] + "" + ")";
}%}
dictionary -> "{" _ keyValueList _ "}"{%function(d){
	return "[" + "" + d[2] + "" + "]";
}%}
keyValueSeparator -> ","{%function(d){
	return ",";
}%}
true -> "true"{%function(d){
	return "true";
}%}
false -> "false"{%function(d){
	return "false";
}%}
compareInts -> arithmetic_expression _ "===" _ arithmetic_expression{%function(d){
	return d[0] + "" + "==" + "" + d[4];
}%}
parentheses_expression -> "(" _ expression _ ")"{%function(d){
	return "(" + "" + d[2] + "" + ")";
}%}
greaterThan -> arithmetic_expression _ ">" _ arithmetic_expression{%function(d){
	return d[0] + "" + ">" + "" + d[4];
}%}
lessThan -> arithmetic_expression _ "<" _ arithmetic_expression{%function(d){
	return d[0] + "" + "<" + "" + d[4];
}%}
class_extends -> "class" __ identifier __ "extends" __ identifier _ "{" _ class_statements _ "}"{%function(d){
	return "class" + " " + d[2] + "" + ":" + "" + d[6] + "" + "{" + "" + d[10] + "" + "}";
}%}
class -> "class" __ identifier _ "{" _ class_statements _ "}"{%function(d){
	return "class" + " " + d[2] + "" + "{" + "" + d[6] + "" + "}";
}%}
pow -> "Math" _ "." _ "pow" _ "(" _ arithmetic_expression _ "," _ arithmetic_expression _ ")"{%function(d){
	return "pow" + "" + "(" + "" + d[8] + "" + "," + "" + d[12] + "" + ")";
}%}
_or -> arithmetic_expression _ "||" _ arithmetic_expression{%function(d){
	return d[0] + "" + "||" + "" + d[4];
}%}
or -> _or{%function(d){
	return d[0];
}%}
_and -> boolean_expression _ "&&" _ boolean_expression{%function(d){
	return d[0] + "" + "&&" + "" + d[4];
}%}
and -> _and{%function(d){
	return d[0];
}%}
not -> "!" _ boolean_expression{%function(d){
	return "!" + "" + d[2];
}%}
_multiply -> arithmetic_expression _ "*" _ arithmetic_expression{%function(d){
	return d[0] + "" + "*" + "" + d[4];
}%}
multiply -> _multiply{%function(d){
	return d[0];
}%}
_divide -> arithmetic_expression _ "/" _ arithmetic_expression{%function(d){
	return d[0] + "" + "/" + "" + d[4];
}%}
divide -> _divide{%function(d){
	return d[0];
}%}
_add -> arithmetic_expression _ "+" _ arithmetic_expression{%function(d){
	return d[0] + "" + "+" + "" + d[4];
}%}
add -> _add{%function(d){
	return d[0];
}%}
_subtract -> arithmetic_expression _ "-" _ arithmetic_expression{%function(d){
	return d[0] + "" + "-" + "" + d[4];
}%}
subtract -> _subtract{%function(d){
	return d[0];
}%}
functionCall -> dot_notation _ "(" _ functionCallParameters _ ")"{%function(d){
	return d[0] + "" + "(" + "" + d[4] + "" + ")";
}%}
double -> "number"{%function(d){
	return "double";
}%}
concatenateString -> string_expression _ "+" _ string_expression{%function(d){
	return d[0] + "" + "+" + "" + d[4];
}%}
return -> "return" __ expression{%function(d){
	return "return" + " " + d[2];
}%}
varName -> identifier{%function(d){
	return d[0];
}%}
if -> "if" _ "(" _ expression _ ")" _ "{" _ series_of_statements _ "}" _ elifOrElse{%function(d){
	return "if" + "" + "(" + "" + d[4] + "" + ")" + "" + "{" + "" + d[10] + "" + "}" + "" + d[14];
}%}
elif -> "else" __ "if" _ "(" _ expression _ ")" _ "{" _ series_of_statements _ "}" _ elifOrElse{%function(d){
	return "else" + " " + "if" + "" + "(" + "" + d[6] + "" + ")" + "" + "{" + "" + d[12] + "" + "}" + "" + d[16];
}%}
else -> "else" _ "{" _ series_of_statements _ "}"{%function(d){
	return "else" + "" + "{" + "" + d[4] + "" + "}";
}%}
while -> "while" _ "(" _ boolean_expression _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "while" + "" + "(" + "" + d[4] + "" + ")" + "" + "{" + "" + d[10] + "" + "}";
}%}
print -> "console" _ "." _ "log" _ "(" _ expression _ ")"{%function(d){
	return "writeln" + "" + "(" + "" + d[8] + "" + ")";
}%}
comment -> "//" _ _string{%function(d){
	return "//" + "" + d[2];
}%}
mod -> arithmetic_expression _ "%" _ arithmetic_expression{%function(d){
	return d[0] + "" + "%" + "" + d[4];
}%}
semicolon -> ";"{%function(d){
	return ";";
}%}
setVar -> varName _ "=" _ expression{%function(d){
	return d[0] + "" + "=" + "" + d[4];
}%}
_dot_notation -> "."{%function(d){
	return ".";
}%}
boolean -> "boolean"{%function(d){
	return "bool";
}%}
int -> "number"{%function(d){
	return "int";
}%}
string -> "string"{%function(d){
	return "string";
}%}
functionCallStatement -> functionCall _ semicolon{%function(d){
	return d[0] + "" + d[2];
}%}
greaterThanOrEqual -> arithmetic_expression _ ">=" _ arithmetic_expression{%function(d){
	return d[0] + "" + ">=" + "" + d[4];
}%}
lessThanOrEqual -> arithmetic_expression _ "<=" _ arithmetic_expression{%function(d){
	return d[0] + "" + "<=" + "" + d[4];
}%}
switch -> "switch" _ "(" _ expression _ ")" _ "{" _ caseStatements __ default _ "}"{%function(d){
	return "switch" + "" + "(" + "" + d[4] + "" + ")" + "" + "{" + "" + d[10] + " " + d[12] + "" + "}";
}%}
case -> "case" __ expression _ ":" _ series_of_statements _ "break" _ ";"{%function(d){
	return "case" + " " + d[2] + "" + ":" + "" + d[6] + "" + "break" + "" + ";";
}%}
foreach -> expression _ "." _ "forEach" _ "(" _ "function" _ "(" _ expression _ ")" _ "{" _ series_of_statements _ "}" _ ")" _ ";"{%function(d){
	return "foreach" + "" + "(" + "" + d[12] + "" + "," + "" + d[0] + "" + ")" + "" + "{" + "" + d[18] + "" + "}";
}%}
default -> "default" _ ":" _ series_of_statements{%function(d){
	return "default" + "" + ":" + "" + d[4];
}%}
array_length -> array_expression _ "." _ "length"{%function(d){
	return d[0] + "" + "." + "" + "length";
}%}
strlen -> string_expression _ "." _ "length"{%function(d){
	return d[0] + "" + "." + "" + "length";
}%}
parameter_separator -> ","{%function(d){
	return ",";
}%}
not_equal -> expression _ "!==" _ expression{%function(d){
	return d[0] + "" + "!=" + "" + d[4];
}%}
constructor -> "constructor" _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "this" + "" + "(" + "" + d[4] + "" + ")" + "" + "{" + "" + d[10] + "" + "}";
}%}
declare_new_object -> "var" __ varName _ "=" _ "new" __ identifier _ "(" _ functionCallParameters _ ")"{%function(d){
	return d[8] + " " + d[2] + "" + "=" + "" + "new" + " " + d[8] + "" + "(" + "" + d[12] + "" + ")";
}%}