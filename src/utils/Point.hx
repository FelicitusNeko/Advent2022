package utils;

using Safety;

typedef IPoint = {
	var x:Int;
	var y:Int;
}

@:forward
abstract Point(IPoint) from IPoint to IPoint {
	public inline function new(x:Int, y:Int)
		this = {
			x: x,
			y: y
		};

	@:from
	public static function fromString(str:String) {
		var pattern = ~/^(-?\d+)[:,](-?\d+)$/;
		if (pattern.match(str)) 
			return new Point(Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)));
		else throw 'Invalid Point string "$str"';
	}

	public inline function iToString(separator = ":")
		return '${this.x}$separator${this.y}';

	@:to
	public inline function toString()
		return iToString(":");

	@:op(a == b)
	public inline function eqPoint(rhs:Point)
		return this.x == rhs.x && this.y == rhs.y;

	@:op(a != b)
	public inline function neqPoint(rhs:Point)
		return this.x != rhs.x || this.y != rhs.y;

	@:op(a + b)
	public inline function addPoint(rhs:Point)
		return new Point(this.x + rhs.x, this.y + rhs.y);

	@:generic
	public inline function arrayGet<T>(array:Array<Array<T>>)
		return array[this.y].or([])[this.x];

	@:generic
	public inline function arraySet<T>(array:Array<Array<T>>, value:T)
		return (array[this.y][this.x] = value);

	public inline function manhattan(rhs:Point)
		return Math.round(Math.abs(this.x - rhs.x) + Math.abs(this.y - rhs.y));
}
