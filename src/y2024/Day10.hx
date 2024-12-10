package y2024;

import utils.Direction;
import utils.Point;

using StringTools;

private var testData = [
	'89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
'
];

class Day10 extends DayEngine {
	private static var dirs:Array<Direction> = [Up, Left, Down, Right];

	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [36, 81]
			}
		});
		new Day10(data, 10, tests);
	}

	function parse(data:String)
		return [for (line in data.rtrim().split("\n")) line.split("").map(Std.parseInt)];

	function problem1(data:String) {
		var map = parse(data);
		var zeroes:Array<Point> = [];
		var retval = 0;

		for (y => line in map)
			for (x => cell in line)
				if (cell == 0)
					zeroes.push([x, y]);
		function trek(pt:Point, nines:Map<String, Bool>) {
			for (dir in dirs) {
				var dest = dir.applyToNewPoint(pt),
					destval = dest.arrayGet(map);
				if (destval != null && pt.arrayGet(map) + 1 == destval) {
					if (destval == 9)
						nines.set(dest, true);
					else
						trek(dest, nines);
				}
			}
			return nines;
		}
		for (zero in zeroes) {
			var nines = trek(zero, []);
			for (_ in nines)
				retval++;
		}

		return retval;
	}

	function problem2(data:String) {
		var map = parse(data);
		var zeroes:Array<Point> = [];
		var retval = 0;

		for (y => line in map)
			for (x => cell in line)
				if (cell == 0)
					zeroes.push([x, y]);
		function trek(pt:Point) {
			var retval = 0;
			for (dir in dirs) {
				var dest = dir.applyToNewPoint(pt),
					destval = dest.arrayGet(map);
				if (destval != null && pt.arrayGet(map) + 1 == destval) {
					if (destval == 9)
						retval++;
					else
						retval += trek(dest);
				}
			}
			return retval;
		}
		for (zero in zeroes)
			retval += trek(zero);

		return retval;
	}
}
