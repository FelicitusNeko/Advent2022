package utils;

import haxe.Exception;
import haxe.Int64;
//using Safety;

typedef IPoint64 = {
	var x:Int64;
	var y:Int64;
}

@:forward
abstract Point64(IPoint64) from IPoint64 to IPoint64 {
	public inline function new(x:Int64, y:Int64)
		this = {
			x: x,
			y: y
		};

	@:from
	public static function fromString(str:String) {
		var pattern = ~/^(-?\d+)[:,](-?\d+)$/;
		if (pattern.match(str)) 
			return new Point64(Int64.parseString(pattern.matched(1)), Int64.parseString(pattern.matched(2)));
		else throw 'Invalid Point string "$str"';
	}

	@:from
	public static function fromArray(val:Array<Int64>) {
		if (val.length != 2) throw new Exception('Invalid array length for Point (expected 2, got ${val.length})');
		return new Point64(val[0], val[1]);
	}

	public inline function iToString(separator = ":")
		return '${this.x}$separator${this.y}';

	@:to
	public inline function toString()
		return iToString(":");

	@:to
	public inline function toPoint() // warning: truncates to int32
		return new Point(this.x.low, this.y.low);

	@:op(a == b)
	public inline function eqPoint64(rhs:Point64)
		return this.x == rhs.x && this.y == rhs.y;

	@:op(a != b)
	public inline function neqPoint64(rhs:Point64)
		return this.x != rhs.x || this.y != rhs.y;

	@:op(a + b)
	public inline function addPoint64(rhs:Point64)
		return new Point64(this.x + rhs.x, this.y + rhs.y);

	@:op(a - b)
	public inline function subPoint64(rhs:Point64)
		return new Point64(this.x - rhs.x, this.y - rhs.y);

	@:op(a + b)
	public inline function addPoint(rhs:Point)
		return new Point64(this.x + rhs.x, this.y + rhs.y);

	@:op(a - b)
	public inline function subPoint(rhs:Point)
		return new Point64(this.x - rhs.x, this.y - rhs.y);

	@:op(-a)
	public inline function negPoint()
		return new Point64(-this.x, -this.y);

	@:op(a * b)
	public inline function multPointByInt(rhs:Int)
		return new Point64(this.x * rhs, this.y * rhs);

	@:op(a * b)
	public inline function multPointByInt64(rhs:Int64)
		return new Point64(this.x * rhs, this.y * rhs);

	// @:generic
	// public inline function arrayGet<T>(array:Array<Array<T>>)
	// 	return array[this.y].or([])[this.x];

	// @:generic
	// public inline function arraySet<T>(array:Array<Array<T>>, value:T)
	// 	return (array[this.y][this.x] = value);

	public inline function manhattan(rhs:Point64) {
		var dx = this.x - rhs.x;
		var dy = this.y - rhs.y;
		if (dx < 0) dx = -dx;
		if (dy < 0) dy = -dy;
		return dx + dy;		
	}
}
