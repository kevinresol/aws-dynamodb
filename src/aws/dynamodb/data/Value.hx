package aws.dynamodb.data;

import haxe.DynamicAccess;

// generic representation
typedef Value = {
	?B:String,
	?BOOL:Bool,
	?BS:Array<String>,
	?L:Array<Value>,
	?M:DynamicAccess<Value>,
	?N:String,
	?NS:Array<String>,
	?NULL:Bool,
	?S:String,
	?SS:Array<String>,
}