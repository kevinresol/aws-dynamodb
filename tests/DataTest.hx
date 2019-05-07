package;

import haxe.io.Bytes;
import haxe.DynamicAccess;
import deepequal.DeepEqual.*;
import aws.dynamodb.data.Data;

@:asserts
class DataTest {
	public function new() {}
	
	public function serialize() {
		asserts.assert(compare({BOOL: true}, Data.serialize(true)));
		asserts.assert(compare({BOOL: false}, Data.serialize(false)));
		asserts.assert(compare({S: 'string'}, Data.serialize('string')));
		asserts.assert(compare({N: '123'}, Data.serialize(123)));
		asserts.assert(compare({N: '123.45'}, Data.serialize(123.45)));
		asserts.assert(compare({B: 'MTIz'}, Data.serialize(Bytes.ofString('123'))));
		asserts.assert(compare({N: '1557221190494'}, Data.serialize(Date.fromTime(1557221190494))));
		
		asserts.assert(compare({N: '1'}, Data.serialize(IA)));
		asserts.assert(compare({S: 'a'}, Data.serialize(SA)));
		asserts.assert(compare({M: {EA: {M: {}}}}, Data.serialize(EA)));
		asserts.assert(compare({M: {EB: {M: {b: {N: '1'}}}}}, Data.serialize(EB(1))));
		asserts.assert(compare({M: {EC: {M: {c: {S: 'a'}}}}}, Data.serialize(EC('a'))));
		asserts.assert(compare({M: {ED: {M: {a: {N: '1'}, b: {N: '1.2'}, c: {S: 'a'}, d: { N: '1557221190494'}}}}}, Data.serialize(ED(1, 1.2, 'a', Date.fromTime(1557221190494)))));
		
		asserts.assert(compare({SS: ['s1', 's2']}, Data.serialize(['s1', 's2'])));
		asserts.assert(compare({NS: ['1', '2']}, Data.serialize([1, 2])));
		asserts.assert(compare({NS: ['1.1', '2.2']}, Data.serialize([1.1, 2.2])));
		asserts.assert(compare({BS: ['MTIz', 'NDU2']}, Data.serialize(['123', '456'].map(Bytes.ofString))));
		
		asserts.assert(compare({M: {a: {N: '1'}, b: {N: '2'}}}, Data.serialize(['a' => 1, 'b' => 2])));
		asserts.assert(compare({M: {a: {N: '1'}, b: {N: '2'}}}, Data.serialize(({a:1, b:2}:DynamicAccess<Int>))));
		asserts.assert(compare({M: {a: {N: '1'}, b: {S: '2'}}}, Data.serialize({a:1, b:'2'})));
		
		return asserts.done();
	}
	
	public function deserialize() {
		asserts.assert(Data.deserialize(({BOOL: true}:Bool)));
		asserts.assert(!Data.deserialize(({BOOL: false}:Bool)));
		asserts.assert(Data.deserialize(({S: 'string'}:String)) == 'string');
		asserts.assert(Data.deserialize(({N: '123'}:Int)) == 123);
		asserts.assert(Data.deserialize(({N: '123.45'}:Float)) == 123.45);
		asserts.assert(compare(Bytes.ofString('123'), Data.deserialize(({B: 'MTIz'}:Bytes))));
		asserts.assert(compare(Date.fromTime(1557221190494), Data.deserialize(({N: '1557221190494'}:Date))));
		
		asserts.assert(compare(IA, Data.deserialize(({N: '1'}:EInt))));
		asserts.assert(compare(SA, Data.deserialize(({S: 'a'}:EString))));
		asserts.assert(compare(EA, Data.deserialize(({M: {EA: {M: {}}}}:MyEnum))));
		asserts.assert(compare(EB(1), Data.deserialize(({M: {EB: {M: {b: {N: '1'}}}}}:MyEnum))));
		asserts.assert(compare(EC('a'), Data.deserialize(({M: {EC: {M: {c: {S: 'a'}}}}}:MyEnum))));
		asserts.assert(compare(ED(1, 1.2, 'a', Date.fromTime(1557221190494)), Data.deserialize(({M: {ED: {M: {a: {N: '1'}, b: {N: '1.2'}, c: {S: 'a'}, d: { N: '1557221190494'}}}}}:MyEnum))));
		
		asserts.assert(compare(['s1', 's2'], Data.deserialize(({SS: ['s1', 's2']}:Array<String>))));
		asserts.assert(compare([1, 2], Data.deserialize(({NS: ['1', '2']}:Array<Int>))));
		asserts.assert(compare([1.1, 2.2], Data.deserialize(({NS: ['1.1', '2.2']}:Array<Float>))));
		asserts.assert(compare(['123', '456'].map(Bytes.ofString), Data.deserialize(({BS: ['MTIz', 'NDU2']}:Array<Bytes>))));
		
		asserts.assert(compare(['a' => 1, 'b' => 2], Data.deserialize(({M: {a: {N: '1'}, b: {N: '2'}}}:Map<String, Int>))));
		asserts.assert(compare({a: 1, b: 2}, Data.deserialize(({M: {a: {N: '1'}, b: {N: '2'}}}:DynamicAccess<Int>))));
		asserts.assert(compare({a: 1, b: '2'}, Data.deserialize(({M: {a: {N: '1'}, b: {S: '2'}}}:{a:Int,b:String}))));
		
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