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

	function problem2(data:String) {
		var p = parse2(data);
		drawMap(p.grid);
		return null;
	}
}
