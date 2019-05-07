package aws.dynamodb.data;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
using tink.MacroApi;
#end

class Data {
	public static macro function serialize(e:Expr) {
		var ct = e.typeof().sure().toComplex();
		return macro @:pos(e.pos) new aws.dynamodb.data.Writer<$ct>().write($e);
	}
	public static macro function deserialize(e:Expr) {
		return 
			switch e {
				case macro ($e:$ct):
					macro new aws.dynamodb.data.Parser<$ct>().parse($e);
				case _:
					switch Context.getExpectedType() {
						case null:
						e.reject('Cannot determine expected type');
						case _.toComplex() => ct:
						macro @:pos(e.pos) new aws.dynamodb.data.Parser<$ct>().parse($e);
					}
			}
	}
}

