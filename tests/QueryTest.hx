package;

import aws.dynamodb.query.Condition;
import aws.dynamodb.query.Writer;
import aws.dynamodb.data.Value;

@:asserts
class QueryTest {
	public function new() {}
	
	public function write() {
		var cond = Compare(Eq, Value({N: '1'}), Value({N: '2'}));
		var out = Writer.write(cond);
		asserts.assert(out.expression == ':v0 = :v1');
		asserts.compare(new Map<String, String>(), out.attributes);
		asserts.compare([':v0' => {N: '1'}, ':v1' => {N: '2'}], out.values);
		return asserts.done();
	}
}