package;

import haxe.io.Bytes;
import haxe.DynamicAccess;
import deepequal.DeepEqual.*;
import aws.dynamodb.data.Data;

@:asserts
class DataTest {
	public function new() {}
	
	public function serialize() {
		asserts.compare({BOOL: true}, Data.serialize(true));
		asserts.compare({BOOL: false}, Data.serialize(false));
		asserts.compare({S: 'string'}, Data.serialize('string'));
		asserts.compare({N: '123'}, Data.serialize(123));
		asserts.compare({N: '123.45'}, Data.serialize(123.45));
		asserts.compare({B: 'MTIz'}, Data.serialize(Bytes.ofString('123')));
		asserts.compare({N: '1557221190494'}, Data.serialize(Date.fromTime(1557221190494)));
		
		asserts.compare({N: '1'}, Data.serialize(IA));
		asserts.compare({S: 'a'}, Data.serialize(SA));
		asserts.compare({M: {EA: {M: {}}}}, Data.serialize(EA));
		asserts.compare({M: {EB: {M: {b: {N: '1'}}}}}, Data.serialize(EB(1)));
		asserts.compare({M: {EC: {M: {c: {S: 'a'}}}}}, Data.serialize(EC('a')));
		asserts.compare({M: {ED: {M: {a: {N: '1'}, b: {N: '1.2'}, c: {S: 'a'}, d: { N: '1557221190494'}}}}}, Data.serialize(ED(1, 1.2, 'a', Date.fromTime(1557221190494))));
		
		asserts.compare({SS: ['s1', 's2']}, Data.serialize(['s1', 's2']));
		asserts.compare({NS: ['1', '2']}, Data.serialize([1, 2]));
		asserts.compare({NS: ['1.1', '2.2']}, Data.serialize([1.1, 2.2]));
		asserts.compare({BS: ['MTIz', 'NDU2']}, Data.serialize(['123', '456'].map(function(v) return Bytes.ofString(v))));
		
		asserts.compare({M: {a: {N: '1'}, b: {N: '2'}}}, Data.serialize(['a' => 1, 'b' => 2]));
		asserts.compare({M: {a: {N: '1'}, b: {N: '2'}}}, Data.serialize(({a:1, b:2}:DynamicAccess<Int>)));
		asserts.compare({M: {a: {N: '1'}, b: {S: '2'}}}, Data.serialize({a:1, b:'2'}));
		
		return asserts.done();
	}
	
	public function deserialize() {
		asserts.assert(Data.deserialize(({BOOL: true}:Bool)));
		asserts.assert(!Data.deserialize(({BOOL: false}:Bool)));
		asserts.assert(Data.deserialize(({S: 'string'}:String)) == 'string');
		asserts.assert(Data.deserialize(({N: '123'}:Int)) == 123);
		asserts.assert(Data.deserialize(({N: '123.45'}:Float)) == 123.45);
		asserts.compare(Bytes.ofString('123'), Data.deserialize(({B: 'MTIz'}:Bytes)));
		asserts.compare(Date.fromTime(1557221190494), Data.deserialize(({N: '1557221190494'}:Date)));
		
		asserts.compare(IA, Data.deserialize(({N: '1'}:EInt)));
		asserts.compare(SA, Data.deserialize(({S: 'a'}:EString)));
		asserts.compare(EA, Data.deserialize(({M: {EA: {M: {}}}}:MyEnum)));
		asserts.compare(EB(1), Data.deserialize(({M: {EB: {M: {b: {N: '1'}}}}}:MyEnum)));
		asserts.compare(EC('a'), Data.deserialize(({M: {EC: {M: {c: {S: 'a'}}}}}:MyEnum)));
		asserts.compare(ED(1, 1.2, 'a', Date.fromTime(1557221190494)), Data.deserialize(({M: {ED: {M: {a: {N: '1'}, b: {N: '1.2'}, c: {S: 'a'}, d: { N: '1557221190494'}}}}}:MyEnum)));
		
		asserts.compare(['s1', 's2'], Data.deserialize(({SS: ['s1', 's2']}:Array<String>)));
		asserts.compare([1, 2], Data.deserialize(({NS: ['1', '2']}:Array<Int>)));
		asserts.compare([1.1, 2.2], Data.deserialize(({NS: ['1.1', '2.2']}:Array<Float>)));
		asserts.compare(['123', '456'].map(function(v) return Bytes.ofString(v)), Data.deserialize(({BS: ['MTIz', 'NDU2']}:Array<Bytes>)));
		
		asserts.compare(['a' => 1, 'b' => 2], Data.deserialize(({M: {a: {N: '1'}, b: {N: '2'}}}:Map<String, Int>)));
		asserts.compare({a: 1, b: 2}, Data.deserialize(({M: {a: {N: '1'}, b: {N: '2'}}}:DynamicAccess<Int>)));
		asserts.compare({a: 1, b: '2'}, Data.deserialize(({M: {a: {N: '1'}, b: {S: '2'}}}:{a:Int,b:String})));
		
		return asserts.done();
	}
}

@:enum
abstract EInt(Int) {
	var IA = 1;
	var IB = 2;
}

@:enum
abstract EString(String) {
	var SA = 'a';
	var SB = 'b';
}

enum MyEnum {
	EA;
	EB(b:Int);
	EC(c:String);
	ED(a:Int, b:Float, c:String, d:Date);
}