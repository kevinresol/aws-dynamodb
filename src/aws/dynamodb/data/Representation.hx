package aws.dynamodb.data;

import haxe.DynamicAccess;

// generic representation
typedef Representation = {
	?B:String,
	?BOOL:Bool,
	?BS:Array<String>,
	?L:Array<Representation>,
	?M:DynamicAccess<Representation>,
	?N:String,
	?NS:Array<String>,
	?NULL:Bool,
	?S:String,
	?SS:Array<String>,
}