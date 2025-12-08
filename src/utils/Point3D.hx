package utils;

import haxe.Exception;

using Safety;

typedef IPoint3D = {
	var x:Int;
	var y:Int;
	var z:Int;
}

@:forward
abstract Point3D(IPoint3D) from IPoint3D {
	public inline function new(x:Int, y:Int, z:Int)
		this = {
			x: x,
			y: y,
			z: z
		};

	public inline function clone()
		return new Point3D(this.x, this.y, this.z);

	@:from
	public static function ofString(data:String) {
		var pattern = ~/^(-?\d+),(-?\d+),(-?\d+)$/;
		if (pattern.match(data))
			return new Point3D(Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)), Std.parseInt(pattern.matched(3)));
		else
			throw 'Invalid point data: $data';
	}

	@:from
	public static function fromArray(val:Array<Int>) {
		if (val.length != 3)
			throw new Exception('Invalid array length for Point (expected 2, got ${val.length})');
		return new Point3D(val[0], val[1], val[2]);
	}

	public inline function iToString(separator = ":")
		return [this.x, this.y, this.z].join(separator);

	@:to
	public inline function toString()
		return iToString();

	// toPoint3D64 omitted, let's hope it doesn't come to that

	@:op(a == b)
	public inline function eqPoint3D(rhs:Point3D)
		return this.x == rhs.x && this.y == rhs.y && this.z == rhs.z;

	@:op(a != b)
	public inline function neqPoint3D(rhs:Point3D)
		return this.x != rhs.x || this.y != rhs.y || this.z != rhs.z;

	@:op(a + b)
	public inline function addPoint3D(rhs:Point3D)
		return new Point3D(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);

	@:op(a - b)
	public inline function subPoint3D(rhs:Point3D)
		return new Point3D(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z);

	@:op(-a)
	public inline function negPoint3D()
		return new Point3D(-this.x, -this.y, -this.z);

	@:op(a * b)
	public inline function multPoint3DByInt(rhs:Int)
		return new Point3D(this.x * rhs, this.y * rhs, this.z * rhs);

	@:generic
	public function arrayGet<T>(ar:Array<Array<Array<T>>>)
		return ar[this.z].or([])[this.y].or([])[this.x];

	@:generic
	public function arraySet<T>(ar:Array<Array<Array<T>>>, value:T)
		return ar[this.z][this.y][this.x] = value;

	public inline function manhattan(rhs:Point3D)
		return Math.round(Math.abs(this.x - rhs.x) + Math.abs(this.y - rhs.y) + Math.abs(this.z - rhs.z));

    public inline function euclidean(rhs:Point3D)
        return Math.sqrt(Math.pow(this.x - rhs.x, 2) + Math.pow(this.y - rhs.y, 2) + Math.pow(this.z - rhs.z, 2));
}
