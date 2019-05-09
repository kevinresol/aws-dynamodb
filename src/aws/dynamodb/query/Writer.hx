package aws.dynamodb.query;

import aws.dynamodb.query.Condition;
import aws.dynamodb.data.Value;

class Writer {
	public var attributes(default, null):Array<String> = [];
	public var values(default, null):Array<Value> = [];
	public var expression(default, null):String;
	
	function new(cond) {
		expression = writeCondition(cond);
	}
	
	public static inline function write(cond:Condition) {
		var writer = new Writer(cond);
		return {
			expression: writer.expression,
			attributes: [for(i in 0...writer.attributes.length) attributePlaceholder(i) => writer.attributes[i]],
			values: [for(i in 0...writer.values.length) valuePlaceholder(i) => writer.values[i]],
		}
	}
		
	function writeCondition(cond:Condition) {
		return switch cond {
			case Not(c): 'NOT ${writeCondition(c)}';
			case And(c1, c2): '${writeCondition(c1)} AND ${writeCondition(c2)}';
			case Or(c1, c2): '${writeCondition(c1)} OR ${writeCondition(c2)}';
			case Compare(cmp, o1, o2): '${writeOperand(o1)} $cmp ${writeOperand(o2)}';
			case Between(o, min, max): '${writeOperand(o)} BETWEEN ${writeOperand(o)} AND ${writeOperand(o)}';
			case Function(f): writeFunction(f);
			case In(o, arr): '${writeOperand(o)} IN (${writeOperands(arr)})';
			case Parenthesis(c): '(${writeCondition(c)})';
		}
	}
	
	function writeFunction(f:Function) {
		return switch f {
			case AttributeExists(path): 'attribute_exists(${writeAttribute(path)})';
			case AttributeNotExists(path): 'attribute_not_exists(${writeAttribute(path)})';
			case AttributeType(path, type): 'attribute_type(${writeAttribute(path)}, $type)';
			case BeginsWith(path, o): 'begins_with(${writeAttribute(path)}, ${writeOperand(o)})';
			case Contains(path, o): 'contains(${writeAttribute(path)}, ${writeOperand(o)})';
			case Size(path): 'size(${writeAttribute(path)})';
		}
	}
	
	inline static function attributePlaceholder(i:Int) {
		return '#v$i';
	}
	
	inline static function valuePlaceholder(i:Int) {
		return ':v$i';
	}
	
	function writeAttribute(path:String) {
		var index = switch attributes.indexOf(path) {
			case -1: attributes.push(path) - 1;
			case i: i;
		}
		return attributePlaceholder(index);
	}
	
	function writeValue(value:Value) {
		// TODO some caching?
		var index = values.push(value) - 1;
		return valuePlaceholder(index);
	}
	
	function writeOperand(operand:Operand) {
		return switch operand {
			case Value(v): writeValue(v);
			case Attribute(path): writeAttribute(path);
		}
	}
	
	function writeOperands(operands:Array<Operand>) {
		return operands.map(writeOperand).join(', ');
	}
	
}