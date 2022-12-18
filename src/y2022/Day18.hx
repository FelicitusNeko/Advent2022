package y2022;

import y2022.DayEngine.TestData;
import utils.Point;

using StringTools;

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

	@:op(a + b)
	public inline function addPoint3D(rhs:Point3D)
		return new Point3D(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);

	@:from
	public static function ofString(data:String) {
		var pattern = ~/^(-?\d+),(-?\d+),(-?\d+)$/;
		if (pattern.match(data))
			return new Point3D(Std.parseInt(pattern.matched(1)), Std.parseInt(pattern.matched(2)), Std.parseInt(pattern.matched(3)));
		else
			throw 'Invalid point data: $data';
	}

	@:to
	public inline function toString()
		return '${this.x},${this.y},${this.z}';
}

typedef AdjacentData = {
	var point:Point3D;
	var adjacent:Array<Point3D>;
	var ?adjacentAir:Array<Point3D>;
}

class Day18 extends DayEngine {
	public static function make(data:String) {
		var tests:Array<TestData> = [
			{
				data: '2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
',
				expected: [64, 58]
			},
			{
				data: '0,0,0
0,0,1
0,0,2
0,0,3
0,1,0
0,1,1
0,1,2
0,1,3
0,2,0
0,2,1
0,2,2
0,2,3
1,0,0
1,0,1
1,0,2
1,0,3
1,1,0
1,1,3
1,2,0
1,2,1
1,2,2
1,2,3
2,0,0
2,0,1
2,0,2
2,0,3
2,1,0
2,1,1
2,1,2
2,1,3
2,2,0
2,2,1
2,2,2
2,2,3
',
				expected: [76, 66]
			}

		];
		new Day18(data, 18, tests);
	}

	function problem1(data:String) {
		var map:Map<String, AdjacentData> = [];
		for (drop in data.rtrim().split("\n"))
			map.set(drop, {point: Point3D.ofString(drop), adjacent: []});
		var variants:Array<Point3D> = [
			{x: 1, y: 0, z: 0},
			{x: -1, y: 0, z: 0},
			{x: 0, y: 1, z: 0},
			{x: 0, y: -1, z: 0},
			{x: 0, y: 0, z: 1},
			{x: 0, y: 0, z: -1}
		];
		for (_ => drop in map)
			for (variant in variants) {
				var check = (drop.point + variant).toString();
				if (map.exists(check)) {
					var match = map[check];
					if (!drop.adjacent.contains(match.point))
						drop.adjacent.push(match.point);
					if (!match.adjacent.contains(drop.point))
						match.adjacent.push(drop.point);
				}
			}
		var total = 0;
		for (_ => drop in map) {
			total += 6 - drop.adjacent.length;
		}
		return total;
	}

	function problem2(data:String) {
		var map:Map<String, AdjacentData> = [];
		var airMap:Map<String, AdjacentData> = [];
		var variants:Array<Point3D> = [
			{x: 1, y: 0, z: 0},
			{x: -1, y: 0, z: 0},
			{x: 0, y: 1, z: 0},
			{x: 0, y: -1, z: 0},
			{x: 0, y: 0, z: 1},
			{x: 0, y: 0, z: -1}
		];
		var total = 0;
		
		for (drop in data.rtrim().split("\n"))
			map.set(drop, {point: Point3D.ofString(drop), adjacent: []});

		for (_ => drop in map)
			for (variant in variants) {
				var checkPt = (drop.point + variant),
					check = checkPt.toString();
				if (map.exists(check)) {
					var match = map[check];
					if (!drop.adjacent.contains(match.point))
						drop.adjacent.push(match.point);
					if (!match.adjacent.contains(drop.point))
						match.adjacent.push(drop.point);
				} else {
					if (!airMap.exists(check))
						airMap.set(check, {point: checkPt, adjacent: [drop.point]});
					else
						airMap[check].adjacent.push(drop.point);
				}
			}
		for (_ => drop in map)
			total += 6 - drop.adjacent.length;

		for (_ => air in airMap)
			air.adjacentAir = [];

		for (_ => air in airMap)
			for (variant in variants) {
				var checkPt = (air.point + variant),
					check = checkPt.toString();
				if (airMap.exists(check)) {
					var match = airMap[check];
					if (!air.adjacentAir.contains(match.point))
						air.adjacentAir.push(match.point);
					if (!match.adjacentAir.contains(air.point))
						match.adjacentAir.push(air.point);
				}
			}

		for (_ => air in airMap)
			if (air.adjacent.length + air.adjacentAir.length == 6)
				total -= air.adjacent.length;

		return total;
		// 2897 too high
		// need to check for cubies inside a larger gap (in a 5×5×5 cube with 3×3×3 cube of air inside, there's a 1×1×1 untracked space which would throw off the count)
	}
}
