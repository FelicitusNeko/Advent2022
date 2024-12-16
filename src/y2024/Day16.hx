package y2024;

import sys.io.File;
import utils.Direction;
import utils.Point;
import haxe.Exception;

using StringTools;

private typedef MoveData = {
	pt:Point,
	dir:Direction,
	score:Int
}

class Day16 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: "###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############",
				expected: [7036, 45]
			},
			{
				data: "#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################",
				expected: [11048, 64]
			}
		];
		new Day16(data, 16, tests);
	}

	function parse(data:String) {
		return [
			for (line in data.rtrim().split("\n")) [
				for (ch in line.split(""))
					switch (ch) {
						case "#":
							null;
						case ".":
							-1;
						case "S":
							0;
						case "E":
							-999;
						case x:
							throw new Exception('Unknown grid character $x');
					}
			]
		];
	}

	function problem1(data:String) {
		static var dirs:Array<Direction> = [Up, Right, Down, Left];
		var grid = parse(data);
		var start:Point = null, goal:Point = null;

		for (y => line in grid)
			for (x => cell in line)
				switch (cell) {
					case 0:
						start = [x, y];
					case -999:
						goal = [x, y];
					default:
				}
		if (start == null)
			throw new Exception("Starting point not found");
		if (goal == null)
			throw new Exception("Goal not found");

		var queue:Array<MoveData> = [
			{
				pt: start,
				dir: Right,
				score: 0
			}
		];

		while (queue.length > 0) {
			var here = queue.pop();
			var dirs = [here.dir];
			if (!(here.pt.x % 2 == 0 || here.pt.y % 2 == 0))
				dirs = [here.dir, here.dir.cw(), here.dir.ccw()];

			for (z => dir in dirs) {
				var there = dir.applyToNewPoint(here.pt);
				var val = there.arrayGet(grid);
				var score = here.score + (z == 0 ? 1 : 1001);
				if (val != null && (val < 0 || score < val)) {
					there.arraySet(grid, score);
					queue.push({
						pt: there,
						dir: dir,
						score: score
					});
				}
			}
		}

		return cast(goal.arrayGet(grid));
	}

	function problem2(data:String) {
		static var dirs:Array<Direction> = [Up, Right, Down, Left];
		var grid = parse(data);
		var start:Point = null, goal:Point = null;

		for (y => line in grid)
			for (x => cell in line)
				switch (cell) {
					case 0:
						start = [x, y];
					case -999:
						goal = [x, y];
					default:
				}
		if (start == null)
			throw new Exception("Starting point not found");
		if (goal == null)
			throw new Exception("Goal not found");

		var queue:Array<MoveData> = [
			{
				pt: start,
				dir: Right,
				score: 0
			}
		];

		while (queue.length > 0) {
			var here = queue.shift();
			var dirs = [here.dir];
			if (!(here.pt.x % 2 == 0 || here.pt.y % 2 == 0))
				dirs = [here.dir, here.dir.cw(), here.dir.ccw()];

			var foreblocked = false;
			for (z => dir in dirs) {
				var there = dir.applyToNewPoint(here.pt);
				var val = there.arrayGet(grid);
				var score = here.score + (z == 0 ? 1 : 1001);
				if (foreblocked && val != null && (val < 0 || score <= val)) {
					foreblocked = false;
					here.pt.arraySet(grid, here.score + 1000);
				}
				if (val != null && (val < 0 || score < val)) {
					there.arraySet(grid, score);
					if (there != goal) queue.push({
						pt: there,
						dir: dir,
						score: score
					});
				} else if (z == 0 && val == null)
					foreblocked = true;
			}
		}

		//File.saveContent('maze.csv', grid.map(i -> i.join(",")).join("\n"));

		var backqueue:Array<Point> = [goal];
		var paths:Map<String, Bool> = [goal => true];

		while (backqueue.length > 0) {
			var here = backqueue.pop();
			var score = here.arrayGet(grid);
			here.arraySet(grid, null);
			for (dir in dirs) {
				var there = dir.applyToNewPoint(here);
				if (paths.exists(there)) continue;
				var val = there.arrayGet(grid);
				//trace(here, score, there, val, val != null && val < score);
				if (val != null && val < score) {
					paths.set(there, true);
					backqueue.push(there);
				}
			}
		}

		return [for (x in paths.keys()) x].length;
		// 548 too low
	}
}
