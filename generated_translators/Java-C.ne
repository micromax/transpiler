
#The following expressions are the same in every language.

chunk -> _ (_series_of_statements | class | class_extends) _ {%function(d){return d[1][0];}%}
_series_of_statements -> series_of_statements _ statement {%function(d){return d[0] +"\n"+ d[2];}%} | statement {%function(d){return d[0];}%} | null
series_of_statements -> statement {%function(d){return d[0];}%} | series_of_statements _ statement {%function(d){return d[0] + "\n" + d[2];}%}

arithmetic_expression -> expression
boolean_expression -> expression
string_expression -> expression
array_expression -> expression

expression ->  accessArray | this | functionCall | varName | dictionary | declare_new_object
| parentheses_expression | add | subtract | multiply | mod | divide | number | pow | strlen
| String | concatenateString | substring
| initializerList
| false | true | not_equal | greaterThan | compareInts | strcmp | lessThanOrEqual | greaterThanOrEqual | lessThan | and | or | not | arrayContains

statement -> constructor | declare_constant | instance_method | static_method | initializeArray | print | comment | switch | setVar | initializeVar | func | functionCallStatement | return | if | while | forInRange
type -> boolean | int | string | arrayType
caseStatements -> caseStatements _ case {%function(d){return d[0] +"\n"+ d[2];}%} | case
elifStatements -> elifStatements _ elif {%function(d){return d[0] +"\n"+ d[2];}%} | elif #Match a series of elif statements
elifOrElse -> else | elifStatements _ else {%function(d){return d[0] +"\n"+ d[2];}%} #Match a series of elif statements followed by else

parameterList -> _parameterList | null
_parameterList -> _parameterList _ parameter_separator _ parameter {%function(d){return d[0]+d[2]+d[4]}%}
| parameter
functionCallParameters -> functionCallParameters _ parameter_separator _ expression | expression | null

keyValueList -> _keyValueList
_keyValueList -> _keyValueList _ keyValueSeparator _ keyValue {%function(d){return d[0]+d[2]+d[4]}%}
| keyValue

_initializerList -> _initializerList _ initializerListSeparator _ expression {%function(d){return d[0]+d[2]+d[4]}%}
| expression

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
declare_constant -> "final" _ __ _ type _ __ _ varName _ "=" _ expression _ ";"{%function(d){
	return "static" + " " + "const" + " " + d[8] + "=" + d[12] + ";";
}%}
initializeArray -> arrayType _ __ _ identifier _ "=" _ array_expression _ ";"{%function(d){
	return d[0] + " " + d[4] + "=" + d[8] + ";";
}%}
accessArray -> identifier _ "[" _ arithmetic_expression _ "]"{%function(d){
	return d[0] + "[" + d[4] + "]";
}%}
arrayType -> type _ "[]"{%function(d){
	return d[0] + "[]";
}%}
initializerListSeparator -> ","{%function(d){
	return ",";
}%}
initializerList -> "{" _ _initializerList _ "}"{%function(d){
	return "{" + d[2] + "}";
}%}
keyValue -> _{%function(d){
	return "";
}%}
dictionary -> _{%function(d){
	return "";
}%}
keyValueSeparator -> _{%function(d){
	return "";
}%}
true -> "true"{%function(d){
	return "1";
}%}
false -> "false"{%function(d){
	return "0";
}%}
compareInts -> arithmetic_expression _ "==" _ arithmetic_expression{%function(d){
	return d[0] + "==" + d[4];
}%}
parentheses_expression -> "(" _ expression _ ")"{%function(d){
	return "(" + d[2] + ")";
}%}
greaterThan -> arithmetic_expression _ ">" _ arithmetic_expression{%function(d){
	return d[0] + ">" + d[4];
}%}
lessThan -> arithmetic_expression _ "<" _ arithmetic_expression{%function(d){
	return d[0] + "<" + d[4];
}%}
class_extends -> "public" _ __ _ "class" _ __ _ identifier _ __ _ "extends" _ __ _ identifier _ "{" _ series_of_statements _ "}"{%function(d){
	return "#include" + " " + "'" + d[16] + ".h'" + "\n" + d[20];
}%}
class -> "public" _ __ _ "class" _ __ _ identifier _ "{" _ series_of_statements _ "}"{%function(d){
	return d[12];
}%}
arrayContains -> "Arrays" _ "." _ "asList" _ "(" _ array_expression _ ")" _ "." _ "contains" _ "(" _ expression _ ")"{%function(d){
	return "";
}%}
this -> "this" _ "." _ varName{%function(d){
	return "";
}%}
pow -> "Math" _ "." _ "pow" _ "(" _ arithmetic_expression _ "," _ arithmetic_expression _ ")"{%function(d){
	return "pow" + "(" + d[8] + "," + d[12] + ")";
}%}
_or -> arithmetic_expression _ "||" _ arithmetic_expression{%function(d){
	return d[0] + "||" + d[4];
}%}
or -> _or{%function(d){
	return d[0];
}%}
_and -> boolean_expression _ "&&" _ boolean_expression{%function(d){
	return d[0] + "&&" + d[4];
}%}
and -> _and{%function(d){
	return d[0];
}%}
not -> "!" _ boolean_expression{%function(d){
	return "!" + d[2];
}%}
_multiply -> arithmetic_expression _ "*" _ arithmetic_expression{%function(d){
	return d[0] + "*" + d[4];
}%}
multiply -> _multiply{%function(d){
	return d[0];
}%}
_divide -> arithmetic_expression _ "/" _ arithmetic_expression{%function(d){
	return d[0] + "/" + d[4];
}%}
divide -> _divide{%function(d){
	return d[0];
}%}
_add -> arithmetic_expression _ "+" _ arithmetic_expression{%function(d){
	return d[0] + "+" + d[4];
}%}
add -> _add{%function(d){
	return d[0];
}%}
subtract -> arithmetic_expression _ "-" _ arithmetic_expression{%function(d){
	return d[0] + "-" + d[4];
}%}
functionCall -> identifier _ "(" _ functionCallParameters _ ")"{%function(d){
	return d[0] + "(" + d[4] + ")";
}%}
concatenateString -> string_expression _ "+" _ string_expression{%function(d){
	return "";
}%}
initializeVar -> type _ __ _ varName _ "=" _ expression _ ";"{%function(d){
	return d[0] + " " + d[4] + "=" + d[8] + ";";
}%}
return -> "return" _ __ _ expression _ ";"{%function(d){
	return "return" + " " + d[4] + ";";
}%}
varName -> identifier{%function(d){
	return d[0];
}%}
func -> "public" _ __ _ "static" _ __ _ type _ __ _ identifier _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return d[8] + " " + d[12] + "(" + d[16] + ")" + "{" + d[22] + "}";
}%}
if -> "if" _ "(" _ boolean_expression _ ")" _ "{" _ series_of_statements _ "}" _ elifOrElse{%function(d){
	return "if" + "(" + d[4] + ")" + "{" + d[10] + "}" + d[14];
}%}
elif -> "else" _ __ _ "if" _ "(" _ boolean_expression _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "else" + " " + "if" + "(" + d[8] + ")" + "{" + d[14] + "}";
}%}
else -> "else" _ "{" _ series_of_statements _ "}"{%function(d){
	return "else" + "{" + d[4] + "}";
}%}
while -> "while" _ "(" _ boolean_expression _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "while" + "(" + d[4] + ")" + "{" + d[10] + "}";
}%}
forInRange -> "for" _ "(" _ "int" _ __ _ varName _ "=" _ arithmetic_expression _ ";" _ varName _ "<" _ arithmetic_expression _ ";" _ varName _ "++" _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "int" + " " + d[8] + ";" + "for" + "(" + d[8] + "=" + d[12] + ";" + d[8] + "<" + d[20] + ";" + d[8] + "++" + ")" + "{" + d[32] + "}";
}%}
listComprehension -> _{%function(d){
	return "";
}%}
import -> "import" _ __ _ expression _ ";"{%function(d){
	return "#include" + " " + "'" + d[4] + ".h'";
}%}
print -> "System" _ "." _ "out" _ "." _ "println" _ "(" _ expression _ ")" _ ";"{%function(d){
	return "printf" + "(" + d[12] + ")" + ";";
}%}
comment -> "//" _ _string _ "\n"{%function(d){
	return "//" + d[2] + "\n";
}%}
mod -> arithmetic_expression _ "%" _ arithmetic_expression{%function(d){
	return d[0] + "%" + d[4];
}%}
setVar -> varName _ "=" _ expression _ ";"{%function(d){
	return d[0] + "=" + d[4] + ";";
}%}
parameter -> type _ __ _ varName{%function(d){
	return d[0] + " " + d[4];
}%}
boolean -> "boolean"{%function(d){
	return "int";
}%}
int -> "int"{%function(d){
	return "int";
}%}
string -> "String"{%function(d){
	return "char*";
}%}
functionCallStatement -> functionCall _ ";"{%function(d){
	return d[0] + ";";
}%}
_greaterThanOrEqual -> arithmetic_expression _ ">=" _ arithmetic_expression{%function(d){
	return d[0] + ">=" + d[4];
}%}
greaterThanOrEqual -> _greaterThanOrEqual{%function(d){
	return d[0];
}%}
_lessThanOrEqual -> arithmetic_expression _ "<=" _ arithmetic_expression{%function(d){
	return d[0] + "<=" + d[4];
}%}
lessThanOrEqual -> _lessThanOrEqual{%function(d){
	return d[0];
}%}
switch -> "switch" _ "(" _ expression _ ")" _ "{" _ caseStatements _ __ _ default _ "}"{%function(d){
	return "switch" + "(" + d[4] + ")" + "{" + d[10] + " " + d[14] + "}";
}%}
case -> "case" _ __ _ expression _ ":" _ series_of_statements _ "break" _ ";"{%function(d){
	return "case" + " " + d[4] + ":" + d[8] + "break" + ";";
}%}
foreach -> "for" _ "(" _ type _ __ _ expression _ ":" _ expression _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "";
}%}
default -> "default" _ ":" _ series_of_statements{%function(d){
	return "default" + ":" + d[4];
}%}
substring -> string_expression _ "." _ "substring" _ "(" _ arithmetic_expression _ "," _ arithmetic_expression _ ")"{%function(d){
	return "";
}%}
strcmp -> string_expression _ "." _ "equals" _ "(" _ string_expression _ ")"{%function(d){
	return "strcmp" + "(" + d[0] + "," + d[8] + ")" + "==" + "0";
}%}
arrayLength -> array_expression _ "." _ "length"{%function(d){
	return "sizeof" + "(" + d[0] + ")" + "/" + "sizeof" + "(" + d[0] + "[" + "0" + "]" + ")";
}%}
strlen -> string_expression _ "." _ "length" _ "(" _ ")"{%function(d){
	return "strlen" + "(" + d[0] + ")";
}%}
parameter_separator -> ","{%function(d){
	return ",";
}%}
not_equal -> expression _ "!=" _ expression{%function(d){
	return d[0] + "!=" + d[4];
}%}
instance_method -> "public" _ __ _ type _ __ _ identifier _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "";
}%}
static_method -> "public" _ __ _ "static" _ __ _ type _ __ _ identifier _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return d[8] + " " + d[12] + "(" + d[16] + ")" + "{" + d[22] + "}";
}%}
constructor -> "public" _ __ _ identifier _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "";
}%}
declare_new_object -> "new" _ __ _ identifier _ "(params)"{%function(d){
	return "";
}%}