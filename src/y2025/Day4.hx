package y2025;

import haxe.DynamicAccess;
import utils.Point;
using StringTools;

private var testData = [
	'..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
'
];

class Day4 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [13, 43]
			}
		});
		new Day4(data, 4, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(i -> i.split('').map(ii -> ii == '@'));

	function problemCommon(data:String, ?reps:Int) {
		var grid = parse(data);
		var count = 0;
		var z = 0;

		while (reps == null || z++ < reps) {
			var remove:DynamicAccess<Point> = {};
			for (y => line in grid) {
				for (x => ch in line) {
					if (!ch) continue;
					var pt = new Point(x, y), occ = 0;
					for (dy in -1...2) for (dx in -1...2) {
						if (dx == 0 && dy == 0) continue;
						if (pt.addPoint(new Point(dx, dy)).arrayGet(grid)) occ++;
					}
					if (occ < 4) remove[pt] = pt;
				}
			}
			var targets = remove.keys().length;
			if (targets > 0) {
				count += remove.keys().length;
				for (target in remove) target.arraySet(grid, false);
			}
			else break;
		}
		return count;
	}

	function problem1(data:String)
		return problemCommon(data, 1);

	function problem2(data:String)
		return problemCommon(data);
}
