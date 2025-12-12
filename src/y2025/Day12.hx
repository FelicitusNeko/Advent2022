package y2025;

import utils.Point;

using StringTools;
using Safety;

private var testData = [
	'0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2
'
];

private enum D12IRotation {
	Deg0;
	Deg90;
	Deg180;
	Deg270;
}

private abstract D12Rotation(D12IRotation) from D12IRotation to D12IRotation {
	public var cw(get, never):D12Rotation;
	public var ccw(get, never):D12Rotation;

	private function get_cw()
		return switch (this) {
			case Deg0: Deg90;
			case Deg90: Deg180;
			case Deg180: Deg270;
			case Deg270: Deg0;
		}

	private function get_ccw()
		return switch (this) {
			case Deg0: Deg270;
			case Deg90: Deg0;
			case Deg180: Deg90;
			case Deg270: Deg180;
		}

	@:to
	public function toInt()
		return switch (this) {
			case Deg0: 0;
			case Deg90: 1;
			case Deg180: 2;
			case Deg270: 3;
		}
}

private typedef D12ShapeDef = Array<Array<Bool>>;

private typedef D12IShape = {
	// shape:D12ShapeDef,
	shaperotate:Array<D12ShapeDef>,
	offset:Point,
	rotation:D12Rotation
};

@:forward(offset, rotation)
private abstract D12Shape(D12IShape) from D12IShape to D12IShape {
	public var shape(get, never):D12ShapeDef;

	private function new(i:D12IShape)
		this = i;

	private function get_shape()
		return this.shaperotate[this.rotation.toInt()];

	@:from
	public static function fromShapeDef(i:D12ShapeDef) {
		var shapes = [[for (line in i) line.slice(0)]];
		for (z in 0...3)
			shapes.push([
				for (x in 0...3) [
					for (y in 0...3)
						shapes[z][2 - y][x]
				]
			]);

		return new D12Shape({
			shaperotate: shapes,
			offset: [0, 0],
			rotation: Deg0
		});
	}

	// public function turncw()
	// 	return new D12Shape({
	// 		shape: [
	// 			for (x in 0...this.shape[0].length) [
	// 				for (y in 0...this.shape.length)
	// 					this.shape[this.shape.length - y - 1][x]
	// 			]
	// 		],
	// 		offset: this.offset.clone(),
	// 		rotation: this.rotation.cw
	// 	});
	// public function turnccw()
	// 	return new D12Shape({
	// 		shape: [
	// 			for (x in 0...this.shape[0].length) [
	// 				for (y in 0...this.shape.length)
	// 					this.shape[y][this.shape[0].length - x - 1]
	// 			]
	// 		],
	// 		offset: this.offset.clone(),
	// 		rotation: this.rotation.ccw
	// 	});

	public function turncw() {
		// var newShape:D12ShapeDef = [
		// 	for (x in 0...this.shape[0].length) [
		// 		for (y in 0...this.shape.length)
		// 			this.shape[this.shape.length - y - 1][x]
		// 	]
		// ];
		// this.shape = newShape;
		return this.rotation = this.rotation.cw;
	}

	public function turnccw() {
		// var newShape:D12ShapeDef = [
		// 	for (x in 0...this.shape[0].length) [
		// 		for (y in 0...this.shape.length)
		// 			this.shape[y][this.shape[0].length - x - 1]
		// 	]
		// ];
		// this.shape = newShape;
		return this.rotation = this.rotation.ccw;
	}

	public function collides(rhs:D12Shape) {
		var dpos = rhs.offset - this.offset;
		for (y => line in get_shape())
			for (x => ch in line)
				if (ch && rhs.shape[dpos.y + y].or([])[dpos.x + x].or(false))
					return true;
		return false;
	}

	@:to
	public function toString()
		return [
			for (line in get_shape()) [
				for (ch in line)
					(ch ? "#" : ".")
			].join("") + "\n"
		].join("");
}

private typedef D12Region = {
	w:Int,
	h:Int,
	counts:Array<Int>
}

private typedef D12Data = {
	shapes:Array<D12ShapeDef>,
	regions:Array<D12Region>
}

class Day12 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [2]
			}
		});
		new Day12(data, 12, tests);
	}

	function parse(data:String):D12Data {
		var sets = data.rtrim().split("\n\n");
		var regions = sets.pop().sure();
		return {
			shapes: [
				for (x => set in sets) {
					var lines = set.split("\n");
					if (lines[0] != '$x:') throw "nope";
					[for (line in lines.slice(1)) [for (ch in line.split('')) ch == "#"]];
				}
			],
			regions: [
				for (region in regions.split("\n")) {
					var tokens = region.split(" ");
					{
						w: Std.parseInt(tokens[0]).sure(),
						h: Std.parseInt(tokens[0].substring(tokens[0].indexOf('x') + 1)),
						counts: [for (token in tokens.slice(1)) Std.parseInt(token).sure()]
					};
				}
			]
		}
	}

	function problem1(data:String) {
		// TODO: THIS IS WAY TOO SLOW
		var list = parse(data);
		var retval = 0;
		// 1. make an array of all the shapes that will be required
		// 2. each shape will turn cw then move l-r u-d until it does not collide with any shape before it
		// 3. keep going until we either reach the end of the list or the first shape falls off the board

		for (z => region in list.regions) {
			var shapes:Array<D12Shape> = [];
			var mX = region.w - 2,
				mY = region.h - 2; // assuming every shape is 3×3
			var pos = 0;

			function advance(me:D12Shape) {
				if (me.turncw() == Deg0) {
					if (++me.offset.x >= mX) {
						me.offset.x = 0;
						if (++me.offset.y >= mY) {
							// trace('shape $pos falls off the board and is reset');
							me.offset.y = 0;
							pos--;
							return false;
						} // else trace('shape $pos moves down to ${me.offset}');
					} // else trace('shape $pos moves right to ${me.offset}');
				} // else trace('shape $pos turns cw to ${me.rotation}');
				return true;
			}

			for (x => type in region.counts)
				for (y in 0...type) {
					var shape:D12Shape = list.shapes[x];
					shape.offset = [shapes.length % (mX), Math.floor(shapes.length / mX)];
					if (shape.offset.y >= mY) {
						pos = -1;
						break;
					}
					shapes.push(shape);
				}

			while (pos >= 0 && pos < shapes.length) {
				var me = shapes[pos];
				var collides = false;
				for (shape in shapes.slice(0, pos).filter(i -> {
					var delta = me.offset - i.offset;
					return delta.x >= -2 && delta.y >= -2 && delta.x < 3 && delta.y < 3;
				}))
					if (collides = collides || me.collides(shape)) {
						// trace('shape $pos collides with shape $x');
						break;
					}

				if (collides) {
					while (pos >= 0 && !advance(shapes[pos])) {}
				} else
					pos++;
			}
			if (pos == shapes.length) {
				trace('result found for region $z');
				retval++;
			} else
				trace('no result found for region $z');
		}

		return retval;
	}

	function problem2(data:String) {
		var list = parse(data);
		return null;
	}
}
