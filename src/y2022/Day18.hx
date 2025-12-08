package y2022;

import DayEngine.TestData;
import utils.Point3D;

using StringTools;
using Safety;

private typedef AdjacentData = {
	var point:Point3D;
	var adjacent:Array<Point3D>;
	var ?adjacentAir:Array<Point3D>;
}

private enum SpaceType {
	Undetermined;
	OpenAir;
	Lava;
	Pocket;
}

class Day18 extends DayEngine {
	public static final variants:Array<Point3D> = [
		{x: 1, y: 0, z: 0},
		{x: -1, y: 0, z: 0},
		{x: 0, y: 1, z: 0},
		{x: 0, y: -1, z: 0},
		{x: 0, y: 0, z: 1},
		{x: 0, y: 0, z: -1}
	];

	public static function make(data:String) {
		var tests:Array<TestData> = [
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
			},
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
			}

		];
		new Day18(data, 18, tests);
	}

	function problem1(data:String) {
		var map:Map<String, AdjacentData> = [];
		for (drop in data.rtrim().split("\n"))
			map.set(drop, {point: Point3D.ofString(drop), adjacent: []});
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
		var mapData:Array<Point3D> = [for (drop in data.rtrim().split("\n")) drop];
		var maxX = 0, maxY = 0, maxZ = 0;
		for (drop in mapData) {
			if (drop.x > maxX)
				maxX = drop.x;
			if (drop.y > maxY)
				maxY = drop.y;
			if (drop.z > maxZ)
				maxZ = drop.z;
		}

		var map = [
			for (_ in 0...maxZ + 1) [for (_ in 0...maxY + 1) [for (_ in 0...maxX + 1) Undetermined]]
		];
		var queue:Array<Point3D> = [];

		for (w in 0...8) {
			var pt:Point3D = {
				x: w & 0x01 == 0x01 ? 0 : maxX,
				y: w & 0x02 == 0x02 ? 0 : maxY,
				z: w & 0x04 == 0x04 ? 0 : maxZ,
			};
			pt.arraySet(map, OpenAir);
			queue.push(pt);
		}

		for (drop in mapData)
			drop.arraySet(map, Lava);

		while (queue.length > 0) {
			var pt = queue.shift();
			if (pt.arrayGet(map) != OpenAir) continue;
			for (v in variants.map(i -> pt + i)) {
				if (v.arrayGet(map) == Undetermined) {
					queue.push(v);
					v.arraySet(map, OpenAir);
				}
			}
		}

		for (z => lv in map)
			for (y => row in lv)
				for (x => pt in row)
					if (pt == Undetermined)
						map[z][y][x] = Pocket;

		var total = 0;
		for (drop in mapData)
			for (v in variants.map(i -> drop + i))
				if (v.arrayGet(map).or(OpenAir) == OpenAir)
					total++;

		return total;
	}
}
