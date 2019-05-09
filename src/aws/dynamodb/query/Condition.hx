package aws.dynamodb.query;

import aws.dynamodb.data.Value;

enum Operand {
	Value(v:Value);
	Attribute(path:String);
}

enum Condition {
	Compare(cmp:Comparator, o1:Operand, o2:Operand);
	Between(o:Operand, min:Operand, max:Operand);
	In(o:Operand, arr:Array<Operand>);
	Function(f:Function);
	And(c1:Condition, c2:Condition);
	Or(c1:Condition, c2:Condition);
	Not(c:Condition);
	Parenthesis(c:Condition);
}

@:enum
abstract Comparator(String) to String {
	var Eq = '=';
	var Ne = '<>';
	var Lt = '<';
	var Le = '<=';
	var Gt = '>';
	var Ge = '>=';
}

enum Function {
	AttributeExists(path:String);
	AttributeNotExists(path:String);
	AttributeType(path:String, type:AttributeType);
	BeginsWith(path:String, operand:Operand);
	Contains(path:String, operand:Operand);
	Size(path:String);
}

@:enum
abstract AttributeType(String) to String {
	var String = 'S';
	var StringSet = 'SS';
	var Number = 'N';
	var NumberSet = 'NS';
	var Binary = 'B';
	var BinarySet = 'BS';
	var Boolean = 'BOOL';
	var Null = 'NULL';
	var List = 'L';
	var Map = 'M';
}

/*
condition-expression ::=
      operand comparator operand
    | operand BETWEEN operand AND operand
    | operand IN ( operand (',' operand (, ...) ))
    | function 
    | condition AND condition 
    | condition OR condition
    | NOT condition 
    | ( condition )

comparator ::=
    = 
    | <> 
    | < 
    | <= 
    | > 
    | >=

function ::=
    attribute_exists (path) 
    | attribute_not_exists (path) 
    | attribute_type (path, type) 
    | begins_with (path, substr) 
    | contains (path, operand)
    | size (path)
*/