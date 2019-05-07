package aws.dynamodb.macros;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.Generator;
import tink.typecrawler.FieldInfo;

using haxe.macro.Tools;
using tink.CoreApi;
using tink.MacroApi;

class GenParser {
	public static function wrap(placeholder:Expr, ct:ComplexType):Function {
		return placeholder.func(['value'.toArg(macro:aws.dynamodb.data.Representation)]);
	}
	
	public static function nullable(e:Expr):Expr {
		return macro value.NULL ? null : $e;
	}
	
	public static function string():Expr {
		return macro value.S;
	}
	
	public static function float():Expr {
		return macro Std.parseFloat(value.N);
	}
	
	public static function int():Expr {
		return macro Std.parseInt(value.N);
	}
	
	public static function dyn(e:Expr, ct:ComplexType):Expr {
		throw 'dyn not implemented';
	}
	
	public static function dynAccess(e:Expr):Expr {
		return macro {
			var map = new haxe.DynamicAccess();
			var obj = value.M;
			for(key in Reflect.fields(obj)) {
				var value = Reflect.field(obj, key);
				map.set(key, $e);
			}
			map;
		}
	}
	
	public static function bool():Expr {
		return macro value.BOOL;
	}
	
	public static function date():Expr {
		return macro Date.fromTime(Std.parseFloat(value.N));
	}
	
	public static function bytes():Expr {
		return macro haxe.crypto.Base64.decode(value.B);
	}
	
	public static function anon(fields:Array<FieldInfo>, ct:ComplexType):Expr {
		var obj = [];
		
		for(f in fields) {
			obj.push({
				field: f.name,
				expr: macro {
					var value = value.M[$v{f.name}];
					${f.expr};
				},
				quotes: null,
			});
		}
		
		return EObjectDecl(obj).at();
	}
	
	public static function array(e:Expr):Expr {
		return macro [for(value in value.L) $e];
	}
	
	public static function map(k:Expr, v:Expr):Expr {
		return macro {
			var map = new Map();
			var obj = value.M;
			for(key in Reflect.fields(obj)) {
				var value = Reflect.field(obj, key);
				map[key] = $v;
			}
			map;
		}
	}
	
	public static function enm(constructors:Array<EnumConstructor>, ct:ComplexType, pos:Position, gen:GenType):Expr {
		var cases = [];
		for(c in constructors) {
			var cname = c.ctor.name;
			cases.push({
				values: [macro _[$v{cname}] => value],
				guard: macro value != null,
				expr: {
					var obj = EObjectDecl([for(f in c.fields) {
						field: f.name,
						expr: macro {
							var value = value.M[$v{f.name}];
							${f.expr};
						}
					}]).at();
					
					var args = [for(f in c.fields) {
						var fname = f.name;
						macro obj.$fname;
					}];
					
					macro {
						var obj = $obj;
						(${c.fields.length == 0 ? macro $i{cname} : macro $i{cname}($a{args})}:$ct);
					}
				}
			});
		}
		
		var fail = macro throw 'Cannot parse ' + value + ' into ' + $v{ct.toString()};
		return ESwitch(macro value.M, cases, fail).at();
	}
	
	public static function enumAbstract(names:Array<Expr>, e:Expr, ct:ComplexType, pos:Position):Expr {
		return macro @:pos(pos) {
			var v:$ct = cast $e;
			${ESwitch(
				macro v, 
				[{expr: macro v, values: names}], 
				macro {
					var list = $a{names};
					throw new tink.core.Error(422, 'Unrecognized enum value: ' + v + '. Accepted values are: ' + list);
				}
			).at(pos)}
		}
	}
	
	public static function rescue(t:Type, pos:Position, gen:GenType):Option<Expr> {
		return None;
	}
	
	public static function reject(t:Type):String {
		return 'Cannot handle ${t.toString()}';
	}
	
	public static function shouldIncludeField(c:ClassField, owner:Option<ClassType>):Bool {
		return true;
	}
	
	public static function drive(type:Type, pos:Position, gen:Type->Position->Expr):Expr {
		return switch type {
			case TInst(_, [_.getID() => 'String']) if(type.getID() == 'Array'): macro value.SS;
			case TInst(_, [_.getID() => 'Int']) if(type.getID() == 'Array'): macro value.NS.map(Std.parseInt);
			case TInst(_, [_.getID() => 'Float']) if(type.getID() == 'Array'): macro value.NS.map(Std.parseFloat);
			case TInst(_, [_.getID() => 'haxe.io.Bytes']) if(type.getID() == 'Array'): macro value.BS.map(haxe.crypto.Base64.decode);
			case _: gen(type, pos);
		}
	}
	
}