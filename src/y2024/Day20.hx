package y2024;

import utils.Direction;
import haxe.Exception;
import utils.Point;

using StringTools;

private var testData = [
	'###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############'
];

class Day20 extends DayEngine {
	static var dirs:Array<Direction> = [Right, Down, Left, Up];
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [0]
			}
		});
		new Day20(data, 20, tests);
	}

	function parse(data:String)
		return [for (line in data.rtrim().split("\n")) [for (cell in line.split("")) cell]];

	function problem1(data:String) {
		var grid = parse(data);
		var pt = (() -> {
			for (y => line in grid)
				for (x => cell in line)
					if (cell == "S")
						return new Point(x, y);
			return null;
		})();
		if (pt == null)
			throw new Exception("Start point not found");

		var path:Array<String> = [pt];
		var lastDir:Direction = Up;
		var done = false;
		while (!done) {
			var dirs = [lastDir, lastDir.cw(), lastDir.ccw()];
			if (path.length <= 1)
				dirs.push(lastDir.reverse());
			for (dir in dirs) {
				var chk = dir.applyToNewPoint(pt);
				switch (chk.arrayGet(grid)) {
					case ".":
						lastDir = dir;
						path.push(pt = chk);
						break;
					case "E":
						path.push(pt = chk);
						done = true;
						break;
					default:
				}
			}
		}

		var cheats:Map<Int, Int> = [];
		var tested:Map<String, Bool> = [];
		for (z => pt in path) {
			for (dir in dirs) {
				var chk = dir.applyToNewPoint(pt);
				if (tested.exists(chk)) continue;
				if (chk.arrayGet(grid) == "#") {
					tested.set(chk, true);
					for (sdir in [dir, dir.cw(), dir.ccw()]) {
						var result = path.indexOf(sdir.applyToNewPoint(chk));
						if (result > z && result - z > 2) {
							var delta = result - z - 2;
							if (cheats.exists(delta)) cheats[delta]++;
							else cheats.set(delta, 1);
						}
					}
				}
			}
		}

		var retval = 0;
		for (k => v in cheats) if (k >= 100) retval += v;

		return retval;
	}

	function problem2(data:String) {
		var list = parse(data);
		return null;
	}
}
