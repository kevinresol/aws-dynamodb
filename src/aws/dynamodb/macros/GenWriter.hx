package aws.dynamodb.macros;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.Generator;
import tink.typecrawler.FieldInfo;

using haxe.macro.Tools;
using tink.CoreApi;
using tink.MacroApi;

class GenWriter {
	public static function wrap(placeholder:Expr, ct:ComplexType):Function {
		return placeholder.func(['value'.toArg(ct)]);
	}
	
	public static function nullable(e:Expr):Expr {
		return macro value == null ? {NULL: true} : cast $e; // TODO: properly type it
	}
	
	public static function string():Expr {
		return macro {S: value};
	}
	
	public static function float():Expr {
		return macro {N: Std.string(value)};
	}
	
	public static function int():Expr {
		return macro {N: Std.string(value)};
	}
	
	public static function dyn(e:Expr, ct:ComplexType):Expr {
		throw 'dyn not implemented';
	}
	
	public static function dynAccess(e:Expr):Expr {
		return macro {
			var obj = new haxe.DynamicAccess();
			for(key in value.keys()) {
				var value = value[key];
				obj[key] = $e;
			}
			{M: obj}
		}
	}
	
	public static function bool():Expr {
		return macro {BOOL: value};
	}
	
	public static function date():Expr {
		return macro {N: Std.string(value.getTime())}
	}
	
	public static function bytes():Expr {
		return macro {B: haxe.crypto.Base64.encode(value)}
	}
	
	public static function anon(fields:Array<FieldInfo>, ct:ComplexType):Expr {
		var obj = [];
		
		for(f in fields) {
			var name = f.name;
			obj.push({
				field: name,
				expr: macro {
					var value = value.$name;
					${f.expr};
				},
				quotes: null,
			});
		}
		
		return macro {M: ${EObjectDecl(obj).at()}};
	}
	
	public static function array(e:Expr):Expr {
		return macro {L: [for(value in value) $e]}
	}
	
	public static function map(k:Expr, v:Expr):Expr {
		return macro {
			var obj = new haxe.DynamicAccess();
			for(key in value.keys()) {
				var value = value[key];
				obj[key] = $v;
			}
			{M: obj}
		}
	}
	
	public static function enm(constructors:Array<EnumConstructor>, ct:ComplexType, pos:Position, gen:GenType):Expr {
		var cases = [];
		for(c in constructors) {
			var cname = c.ctor.name;
			cases.push({
				var args = [for(f in c.fields) macro $i{f.name}];
				{
					values: [c.fields.length == 0 ? macro $i{cname} : macro $i{cname}($a{args})],
					expr: macro ({
						M: {
							$cname: {
								M: ${EObjectDecl([for(f in c.fields) {
									field: f.name,
									expr: macro {
										var value = $i{f.name};
										${f.expr}
									}
								}]).at()}
							}
						}
					}:aws.dynamodb.data.Representation)
				}
			});
		}
		return ESwitch(macro (value:$ct), cases, null).at();
	}
	
	public static function enumAbstract(names:Array<Expr>, e:Expr, ct:ComplexType, pos:Position):Expr {
		return e;
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
			case TInst(_, [_.getID() => 'String']) if(type.getID() == 'Array'): macro {SS: value};
			case TInst(_, [_.getID() => 'Int' | 'Float']) if(type.getID() == 'Array'): macro {NS: value.map(Std.string)};
			case TInst(_, [_.getID() => 'haxe.io.Bytes']) if(type.getID() == 'Array'): macro {BS: value.map(haxe.crypto.Base64.encode.bind(_, true))};
			case _: gen(type, pos);
		}
	}
	
}