package utils;

import haxe.Exception;
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

	public inline function clone()
		return new Point(this.x, this.y);

	@:from
	public static function fromString(str:String) {
		var pattern = ~/^(-?\d+)[:,](-?\d+)$/;
		if (pattern.match(str)) 
			return new Point(Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)));
		else throw 'Invalid Point string "$str"';
	}

	@:from
	public static function fromArray(val:Array<Int>) {
		if (val.length != 2) throw new Exception('Invalid array length for Point (expected 2, got ${val.length})');
		return new Point(val[0], val[1]);
	}

	public inline function iToString(separator = ":")
		return '${this.x}$separator${this.y}';

	@:to
	public inline function toString()
		return iToString(":");

	@:to
	public inline function toPoint64()
		return new Point64(this.x, this.y);

	@:op(a == b)
	public inline function eqPoint(rhs:Point)
		return this.x == rhs.x && this.y == rhs.y;

	@:op(a != b)
	public inline function neqPoint(rhs:Point)
		return this.x != rhs.x || this.y != rhs.y;

	@:op(a + b)
	public inline function addPoint(rhs:Point)
		return new Point(this.x + rhs.x, this.y + rhs.y);

	@:op(a - b)
	public inline function subPoint(rhs:Point)
		return new Point(this.x - rhs.x, this.y - rhs.y);

	@:op(-a)
	public inline function negPoint()
		return new Point(-this.x, -this.y);

	@:op(a * b)
	public inline function multPointByInt(rhs:Int)
		return new Point(this.x * rhs, this.y * rhs);

	@:generic
	public inline function arrayGet<T>(array:Array<Array<T>>)
		return array[this.y].or([])[this.x];

	@:generic
	public inline function arraySet<T>(array:Array<Array<T>>, value:T)
		return (array[this.y][this.x] = value);

	public inline function manhattan(rhs:Point)
		return Math.round(Math.abs(this.x - rhs.x) + Math.abs(this.y - rhs.y));
}
