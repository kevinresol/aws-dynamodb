package aws.dynamodb.macros;

import haxe.macro.Expr;
import tink.macro.BuildCache;
import tink.typecrawler.Crawler;

using tink.MacroApi;

class Macro {
	public static function buildSerialized() {
		return BuildCache.getType('aws.dynamodb.data.Serialized', function(ctx:BuildContext) {
			
			function make(ct:ComplexType):TypeDefinition {
				return {
					fields: [],
					kind: TDAlias(ct),
					name: ctx.name,
					pack: ['aws', 'dynamodb', 'data'],
					pos: ctx.pos,
				}
			}
			
			switch ctx.type.getID() {
				case 'Bool': return make(macro:{BOOL:Bool});
				case 'String': return make(macro:{S:String});
				case 'Int' | 'Float': return make(macro:{N:String});
				case 'haxe.io.Bytes': return make(macro:{B:String});
				case _:
			}
			
			return make(macro:Dynamic); // TODO
		});
	}
	
	public static function buildWriter() {
		return BuildCache.getType('aws.dynamodb.data.Writer', function(ctx:BuildContext) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			
			var ret = Crawler.crawl(ctx.type, ctx.pos, GenWriter);
			var def = macro class $name {
				public function new() {}
				public function write(value:$ct):aws.dynamodb.data.Serialized<$ct> return ${ret.expr};
			}
			
			def.fields = def.fields.concat(ret.fields);
			def.pack = ['aws', 'dynamodb', 'data'];
			
			return def;
		});
	}
	
	public static function buildParser() {
		return BuildCache.getType('aws.dynamodb.data.Parser', function(ctx:BuildContext) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			
			var ret = Crawler.crawl(ctx.type, ctx.pos, GenParser);
			var def = macro class $name {
				public function new() {}
				public function tryParse(value:Dynamic):tink.core.Outcome<$ct, tink.core.Error> return tink.core.Error.catchExceptions(parse.bind(value));
				public function parse(value:Dynamic):$ct return ${ret.expr};
			}
			def.fields = def.fields.concat(ret.fields);
			def.pack = ['aws', 'dynamodb', 'data'];
			
			return def;
		});
	}
}