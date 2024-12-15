package y2024;

import utils.Direction;
import haxe.Exception;
import utils.Point;

using StringTools;

private enum GridType {
	Wall;
	Box;
	Space;
	Me;
	LeftBox;
	RightBox;
}

class Day15 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: '########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<',
				expected: [2028]
			},
			{
				data: '#######
#...#.#
#.....#
#..OO@#
#..O..#
#.....#
#######

<vv<<^^<<^^',
				expected: [null, 618]
			},
			{
				data: '##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^',
				expected: [10092, 9021]
			}
		];
		new Day15(data, 15, tests);
	}

	function parse(data:String) {
		var split = data.split("\n\n");
		var pt:Point = null;
		return {
			grid: [
				for (y => line in split[0].split("\n")) [
					for (x => cell in line.split(""))
						switch (cell) {
							case "#":
								Wall;
							case "O":
								Box;
							case "@":
								if (pt == null)
									pt = [x, y];
								else
									throw new Exception("Multiple submarine locations");
								Me;
							case ".":
								Space;
							case x:
								throw new Exception('Unknown grid char $x');
						}
				]
			],
			pt: pt != null ? pt : throw new Exception("Submarine location not found"),
			orders: [
				for (ch in split[1].split("").filter(i -> i != '\n'))
					cast(switch (ch) {
						case "^":
							Up;
						case ">":
							Right;
						case "v":
							Down;
						case "<":
							Left;
						case x:
							throw new Exception('Unknown dir char ');
					}, Direction)
			]
		};
	}

	function parse2(data:String) {
		var split = data.split("\n\n");
		var pt:Point = null;
		return {
			grid: [
				for (y => line in split[0].split("\n")) {
					var parseline:Array<GridType> = [];

					for (x => cell in line.split(""))
						for (half in switch (cell) {
							case "#":
								[Wall, Wall];
							case "O":
								[LeftBox, RightBox];
							case "@":
								if (pt == null)
									pt = [x * 2, y];
								else
									throw new Exception("Multiple submarine locations");
								[Me, Space];
							case ".":
								[Space, Space];
							case x:
								throw new Exception('Unknown grid char $x');
						})
							parseline.push(half);
					parseline;
				}
			],
			pt: pt != null ? pt : throw new Exception("Submarine location not found"),
			orders: [
				for (ch in split[1].split("").filter(i -> i != '\n'))
					cast(switch (ch) {
						case "^":
							Up;
						case ">":
							Right;
						case "v":
							Down;
						case "<":
							Left;
						case x:
							throw new Exception('Unknown dir char ');
					}, Direction)
			]
		};
	}

	static function drawMap(grid:Array<Array<GridType>>)
		for (line in grid) {
			Sys.println("");
			for (cell in line)
				Sys.print(switch (cell) {
					case Wall: "#";
					case Box: "O";
					case Space: ".";
					case Me: "@";
					case LeftBox: "[";
					case RightBox: "]";
				});
		}

	function problem1(data:String) {
		var p = parse(data);
		var retval = 0;

		for (dir in p.orders) {
			var chk = p.pt;
			do {
				chk = dir.applyToNewPoint(chk);
			} while (![Wall, Space].contains(chk.arrayGet(p.grid)));
			if (chk.arrayGet(p.grid) == Space) {
				var back = dir.reverse();
				var backpt = back.applyToNewPoint(chk);
				do {
					chk.arraySet(p.grid, backpt.arrayGet(p.grid));
					chk = backpt;
					backpt = back.applyToNewPoint(chk);
				} while (chk != p.pt);
				p.pt = dir.applyToNewPoint(p.pt);
				chk.arraySet(p.grid, Space);
			}
		}

		for (y => line in p.grid)
			for (x => cell in line)
				if (cell == Box)
					retval += (y * 100) + x;

		return retval;
	}

	static function checkBox(grid:Array<Array<GridType>>, pt:Point, dir:Direction):Null<Array<Point>> {
		var retval:Array<Point> = [];

		for (chk in [pt, pt + [1, 0]].map(dir.applyToNewPoint))
			switch (chk.arrayGet(grid)) {
				case LeftBox:
					retval.push(chk);
					break;
				case RightBox:
					retval.push(chk + [-1, 0]);
				case Wall:
					return null;
				default:
			}
		return retval;
	}

	function problem2(data:String) {
		var p = parse2(data);
		var retval = 0;

		for (dir in p.orders) {
			switch (dir) {
				case Left, Right:
					{
						var chk = p.pt;
						do {
							chk = dir.applyToNewPoint(chk);
						} while (![Wall, Space].contains(chk.arrayGet(p.grid)));
						if (chk.arrayGet(p.grid) == Space) {
							var back = dir.reverse();
							var backpt = back.applyToNewPoint(chk);
							do {
								chk.arraySet(p.grid, backpt.arrayGet(p.grid));
								chk = backpt;
								backpt = back.applyToNewPoint(chk);
							} while (chk != p.pt);
							p.pt = dir.applyToNewPoint(p.pt);
							chk.arraySet(p.grid, Space);
						}
					}
				case Up, Down:
					{
						var chk = dir.applyToNewPoint(p.pt);
						var queue:Null<Array<Point>> = [];
						var boxes:Array<Point> = [];

						switch (chk.arrayGet(p.grid)) {
							case Wall: queue = null;
							case LeftBox: queue.push(chk);
							case RightBox: queue.push(chk + [-1, 0]);
							case Space:
							case Box: throw new Exception("Single-width box on double-width map");
							case Me: throw new Exception("Duplicate submarine on map");
						}

						while (queue != null && queue.length > 0) {
							var box = queue.shift();
							var dupe = false;
							for (dupechk in boxes)
								if (box == dupechk) {
									dupe = true;
									break;
								}
							if (dupe)
								continue;

							var calc = checkBox(p.grid, box, dir);
							if (calc == null)
								queue = null;
							else {
								for (more in calc)
									queue.push(more);
								boxes.push(box);
							}
						}
						if (queue != null) {
							while (boxes.length > 0) {
								var box = boxes.pop();
								for (pt in [box, box + [1, 0]]) {
									dir.applyToNewPoint(pt).arraySet(p.grid, pt.arrayGet(p.grid));
									pt.arraySet(p.grid, Space);
								}
							}
							var newpt = dir.applyToNewPoint(p.pt);
							newpt.arraySet(p.grid, Me);
							p.pt.arraySet(p.grid, Space);
							p.pt = newpt;
						}
					}
			}
		}

		for (y => line in p.grid)
			for (x => cell in line)
				switch (cell) {
					case LeftBox:
						if (line[x + 1] != RightBox)
							throw new Exception("Left box part without right");
						retval += (y * 100) + x;
					case RightBox:
						if (line[x - 1] != LeftBox)
							throw new Exception("Right box part without left");
					default:
				}

		return retval;
	}
}
