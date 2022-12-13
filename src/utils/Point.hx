package utils;

typedef IPoint = {
	var x:Int;
	var y:Int;
}

@:forward
abstract Point(IPoint) from IPoint to IPoint {
	@:to
	public function toString()
		return '${this.x}:${this.y}';

	@:op(a == b)
	public function isEqual(rhs:Point)
		return this.x == rhs.x && this.y == rhs.y;
}
