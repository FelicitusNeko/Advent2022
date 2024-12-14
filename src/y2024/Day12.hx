package y2024;

import utils.Direction;
import utils.Point;

using StringTools;

class Day12 extends DayEngine {
	static var dirs:Array<Direction> = [Up, Right, Down, Left];

	public static function make(data:String) {
		var tests = [
			{
				data: 'AAAA
BBCD
BBCC
EEEC
',
				expected: [140, 80]
			},
			{
				data: 'OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
',
				expected: [772, 436]
			},
			{
				data: 'EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
',
				expected: [null, 236]
			},
			{
				data: 'AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
',
				expected: [null, 368]
			},
			{
				data: 'RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
',
				expected: [1930, 1206]
			}
		];
		new Day12(data, 12, tests);
	}

	static function printgrid(grid:Array<Array<String>>) {
		for (row in grid) {
			Sys.println('');
			for (ch in row)
				Sys.print(ch);
		}
		Sys.println('');
	}

	static function scan(grid:Array<Array<String>>, ch:String, pt:Point) {
		var retval = [];
		for (check in dirs.map(i -> i.applyToNewPoint(pt)))
			if (check.arrayGet(grid) == ch) {
				check.arraySet(grid, ".");
				retval.push(check);
			}
		return retval;
	}

	static inline function parse(data:String)
		return [for (line in data.rtrim().split("\n")) line.split("")];

	function problem1(data:String) {
		var grid = parse(data);
		var zones:Array<Array<Point>> = [];
		var zonech:Array<String> = [];
		var retval = 0;

		for (y in 0...grid.length) {
			var row = grid[y];
			for (x in 0...row.length) {
				var ch = row[x];
				var pt:Point = [x, y];
				if (ch != ".") {
					zonech.push(ch);
					pt.arraySet(grid, ".");
					var scanqueue = [pt], zone = [pt];
					while (scanqueue.length > 0)
						for (rpt in scan(grid, ch, scanqueue.pop())) {
							scanqueue.push(rpt);
							zone.push(rpt);
						}
					zones.push(zone);
				}
			}
		}

		for (x => zone in zones) {
			var zonestr = zone.map(i -> i.toString());
			var perimeter = 0;
			for (pt in zone)
				for (check in dirs.map(i -> i.applyToNewPoint(pt)))
					if (!zonestr.contains(check))
						perimeter++;
			retval += perimeter * zone.length;
		}

		return retval;
	}

	function problem2(data:String) {
		var grid = parse(data);
		var zones:Array<Array<Point>> = [];
		var zonech:Array<String> = [];
		var retval = 0;

		for (y in 0...grid.length) {
			var row = grid[y];
			for (x in 0...row.length) {
				var ch = row[x];
				var pt:Point = [x, y];
				if (ch != ".") {
					zonech.push(ch);
					pt.arraySet(grid, ".");
					var scanqueue = [pt], zone = [pt];
					while (scanqueue.length > 0)
						for (rpt in scan(grid, ch, scanqueue.pop())) {
							scanqueue.push(rpt);
							zone.push(rpt);
						}
					zones.push(zone);
				}
			}
		}

		for (z => zone in zones) {
			var top = zone[0].y, bottom = zone[0].y;
			var left = zone[0].x, right = zone[0].x;
			var sides = 0;
			for (pt in zone) {
				if (top > pt.y)
					top = pt.y;
				if (bottom < pt.y)
					bottom = pt.y;
				if (left > pt.x)
					left = pt.x;
				if (right < pt.x)
					right = pt.x;
			}

			var zonestr = zone.map(i -> i.toString());
			for (y in top - 1...bottom + 1) {
				var streakfore = false, streakaft = false;
				for (x in left...right + 1) {
					var change = false;
					var hasfore = zonestr.contains('$x:$y'),
						hasaft = zonestr.contains('$x:${y + 1}');
					if (hasfore != streakfore) {
						change = true;
						streakfore = hasfore;
					}
					if (hasaft != streakaft) {
						change = true;
						streakaft = hasaft;
					}
					if (change && (streakfore || streakaft) && !(streakfore && streakaft))
						sides++;
				}
			}

			for (x in left - 1...right + 1) {
				var streakfore = false, streakaft = false;
				for (y in top...bottom + 1) {
					var change = false;
					var hasfore = zonestr.contains('$x:$y'),
						hasaft = zonestr.contains('${x + 1}:$y');
					if (hasfore != streakfore) {
						change = true;
						streakfore = hasfore;
					}
					if (hasaft != streakaft) {
						change = true;
						streakaft = hasaft;
					}
					if (change && (streakfore || streakaft) && !(streakfore && streakaft))
						sides++;
				}
			}

			retval += sides * zone.length;
		}

		return retval;
	}
}
