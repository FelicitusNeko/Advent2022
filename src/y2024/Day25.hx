package y2024;

using StringTools;

private var testData = [
	'#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
'
];

class Day25 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [3]
			}
		});
		new Day25(data, 25, tests);
	}

	function parse(data:String) {
		var split = data.rtrim().split("\n\n");
		var keys:Array<Array<Int>> = [], locks:Array<Array<Int>> = [];

		for (pattern in split) {
			var lines = pattern.split("\n");
			var isKey = lines[0] == ".....";
			if (isKey)
				lines.reverse();
			var count:Array<Int> = [for (_ in 0...5) 0];
			for (line in lines.slice(1))
				for (x => c in line.split(""))
					if (c == "#")
						count[x]++;
			(isKey ? keys : locks).push(count);
		}

		return {
			keys: keys,
			locks: locks
		};
	}

	function problem1(data:String) {
		var list = parse(data);
		var retval = 0;
		for (key in list.keys)
			for (lock in list.locks) {
				var good = true;
				for (x in 0...key.length)
					if (key[x] + lock[x] > 5) {
						good = false;
						break;
					}
				if (good)
					retval++;
			}
		return retval;
	}

	function problem2(data:String) {
		trace("Day 25 Part 2 has no puzzle; get 49 stars!");
		return null;
	}
}
