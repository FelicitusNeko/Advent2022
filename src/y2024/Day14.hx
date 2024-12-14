package y2024;

import sys.io.File;
import utils.Point;
import haxe.Exception;

using StringTools;

private var testData = [
	'p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
'
];

class Day14 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [12]
			}
		});
		new Day14(data, 14, tests);
	}

	function parse(data:String)
		return [
			for (line in data.rtrim().split("\n")) {
				static var pattern = ~/^p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)$/;
				if (pattern.match(line)) {
					var nums = [for (x in 1...5) pattern.matched(x)].map(Std.parseInt);
					{
						p: new Point(nums[0], nums[1]),
						v: new Point(nums[2], nums[3])
					};
				} else throw new Exception('Unknown pattern "$line"');
			}
		];

	function problem1(data:String) {
		var list = parse(data);
		var w = 0, h = 0;

		for (bot in list) {
			w = w > bot.p.x ? w : bot.p.x;
			h = h > bot.p.y ? h : bot.p.y;
		}

		for (_ in 0...100) {
			for (bot in list) {
				bot.p += bot.v;
				if (bot.p.x < 0)
					bot.p.x += w + 1;
				if (bot.p.x > w)
					bot.p.x -= w + 1;
				if (bot.p.y < 0)
					bot.p.y += h + 1;
				if (bot.p.y > h)
					bot.p.y -= h + 1;
			}
		}

		var quads = [0, 0, 0, 0];
		var hw = Math.round(w / 2), hh = Math.round(h / 2);
		for (bot in list) {
			if (bot.p.x < hw) {
				if (bot.p.y < hh)
					quads[0]++;
				else if (bot.p.y > hh)
					quads[1]++;
			} else if (bot.p.x > hw) {
				if (bot.p.y < hh)
					quads[2]++;
				else if (bot.p.y > hh)
					quads[3]++;
			}
		}

		var retval = 1;
		for (quad in quads)
			retval *= quad;

		return retval;
	}

	function problem2(data:String) {
		var list = parse(data);
		var retval = 0;
		var w = 0, h = 0, hw = 0;
		var done = false;
		var longestLine = 0;

		for (bot in list) {
			w = w > bot.p.x ? w : bot.p.x;
			h = h > bot.p.y ? h : bot.p.y;
		}
		hw = Math.round(w / 2);

		while (!done) {
			retval++;
			var grid = [for (_ in 0...h + 1) [for (_ in 0...w + 1) "."]];

			for (bot in list) {
				bot.p += bot.v;
				if (bot.p.x < 0)
					bot.p.x += w + 1;
				if (bot.p.x > w)
					bot.p.x -= w + 1;
				if (bot.p.y < 0)
					bot.p.y += h + 1;
				if (bot.p.y > h)
					bot.p.y -= h + 1;
				bot.p.arraySet(grid, "#");
			}

			var maybe:Null<Int> = null, maybestreak = 0;
			for (y => line in grid) {
				var streak = 0;
				for (cell in line)
					if (cell == "#")
						streak++;
					else {
						if (streak > 30) { // cheating a bit by having watched a solved visualisation but come on
							if (maybe != null && maybe == y - streak - 1)
								done = true;
							else {
								maybe = y;
								maybestreak = streak;
							}
						}
						streak = 0;
					}
			}

			if (done)
				File.saveContent("2024.14.2.txt", 'Iteration $retval\n\n' + grid.map(i -> i.join("")).join("\n"));
		}

		return retval;
	}
}
