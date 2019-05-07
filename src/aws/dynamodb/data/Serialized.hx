package aws.dynamodb.data;

@:genericBuild(aws.dynamodb.macros.Macro.buildSerialized())
class Serialized<T> {}