package y2024;

import utils.Point;

using StringTools;

class Day4 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: '..X...
.SAMX.
.A..A.
XMAS.S
.X....
',
				expected: [4]
			},
			{
				data: 'MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
',
				expected: [18, 9]
			},
			{
				data: 'M.S
.A.
M.S
',
				expected: [null, 1]
			},
			{
				data: '.M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
..........
',
				expected: [null, 9]
			}
		];
		new Day4(data, 4, tests);
	}

	function problem1(data:String) {
		static var xmas = 'XMAS'.split('');
		static var dirs:Array<Point> = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]];

		var grid = data.rtrim().split("\n").map(i -> i.split(''));
		var xs:Array<Point> = [];
		var retval = 0;

		for (y => line in grid)
			for (x => cell in line)
				if (cell == xmas[0])
					xs.push([x, y]);

		for (x in xs) {
			var check:Array<Point> = [for (_ in 0...8) [x.x, x.y]];
			var good = [for (_ in 0...8) true];

			for (y in 1...4) {
				for (z in 0...8) {
					if (good[z]) {
						check[z] += dirs[z];
						if (check[z].arrayGet(grid) != xmas[y])
							good[z] = false;
					}
				}

				var anyGood = false;
				for (g in good)
					anyGood = anyGood || g;
				if (!anyGood)
					break;
			}

			for (g in good)
				if (g)
					retval++;
		}

		return retval;
	}

	function problem2(data:String) {
		static var dirs:Array<Point> = [[-1, -1], [-1, 1], [1, -1], [1, 1]];

		var grid = data.rtrim().split("\n").map(i -> i.split(''));
		var as:Array<Point> = [];
		var retval = 0;

		for (y => line in grid)
			for (x => cell in line)
				if (cell == 'A')
					as.push([x, y]);

		for (a in as) {
			var ms = 0, ss = 0;
			for (dir in dirs)
				switch ((a + dir).arrayGet(grid)) {
					case 'M':
						ms++;
					case 'S':
						ss++;
				}

			if (ms + ss == 4 && ms == 2 && (a + dirs[0]).arrayGet(grid) != (a + dirs[3]).arrayGet(grid))
				retval++;
		}

		return retval; // 2046
	}
}
