package y2025;

import haxe.Int64;
import utils.Point;

using StringTools;

private var testData = [
	'.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
'
];

private typedef D7Data = {
	beams:Array<{
		pos:Point,
		valance:Int64
	}>,
	splitters:Map<Int, Array<Point>>,
	bottom:Int
}

class Day7 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [21, 40].map(Int64.ofInt)
			}
		});
		new Day7(data, 7, tests);
	}

	function parse(data:String) {
		var retval:D7Data = {beams: [], splitters: [], bottom: 0};
		for (y => line in data.rtrim().split("\n")) {
			retval.bottom = y;
			for (x => ch in line.split(''))
				switch (ch) {
					case 'S':
						retval.beams.push({pos: new Point(x, y), valance: 1});
					case '^':
						if (retval.splitters.exists(y))
							retval.splitters[y].push(new Point(x, y));
						else
							retval.splitters.set(y, [new Point(x, y)]);
					case '.':
					case x:
						trace('Unknown char "$x"');
				}
		}
		return retval;
	}

	function problemCommon(data:String, part2:Bool) {
		var data = parse(data);
		var beams = data.beams.slice(0);
		var splits:Int64 = 0, valance:Int64 = 0;
		while (beams.length > 0) {
			var work = beams.slice(0);
			beams = [];
			function addUnique(inbeam:Point, valance:Int64) {
				for (beam in beams)
					if (inbeam == beam.pos) {
						beam.valance += valance;
						return;
					}
				beams.push({pos: inbeam, valance: valance});
			}

			for (beam in work) {
				if (++beam.pos.y >= data.bottom) {
					valance += beam.valance;
					continue;
				}
				var isSplit = false;
				if (data.splitters.exists(beam.pos.y))
					for (splitter in data.splitters[beam.pos.y])
						if (splitter == beam.pos) {
							addUnique(beam.pos - new Point(1, 0), beam.valance);
							addUnique(beam.pos + new Point(1, 0), beam.valance);
							splits++;
							isSplit = true;
							break;
						}
				if (!isSplit)
					addUnique(beam.pos, beam.valance);
			}
		}
		return part2 ? valance : splits;
	}

	function problem1(data:String)
		return problemCommon(data, false);

	function problem2(data:String) 
		return problemCommon(data, true);
}
