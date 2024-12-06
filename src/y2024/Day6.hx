package y2024;

import utils.Point;
import haxe.Exception;
import utils.Direction;

using StringTools;

private var testData = [
	'....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
'
];

private typedef Grid<T> = Array<Array<T>>;

private enum IGridSpace {
	Space;
	Wall;
	Guard(d:Direction);
	Stepped(c:Int);
}

@:forward
private abstract GridSpace(IGridSpace) from IGridSpace to IGridSpace {
	@:from
	public static function fromString(s:String)
		return cast(switch (s) {
			case ".": Space;
			case "#": Wall;
			case "^": Guard(Up);
			case ">": Guard(Right);
			case "v": Guard(Down);
			case "<": Guard(Left);
			case "X": Stepped(1);
			case x: throw new Exception('Unknown grid char $x');
		}, GridSpace);

	@:to
	public function toString()
		return switch (this) {
			case Space: ".";
			case Wall: "#";
			case Guard(d): switch (d) {
					case Up: "^";
					case Right: ">";
					case Down: "v";
					case Left: "<";
				}
			case Stepped(_): "X";
		}

	@:op(a++)
	function increment()
		return switch (this) {
			case Space: Stepped(1);
			case Stepped(c): Stepped(++c);
			case Guard(d): Guard(d.cw());
			default: this;
		}
}

private typedef GridData = {
	grid:Grid<GridSpace>,
	pt:Point,
	dir:Direction
}

class Day6 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [41]
			}
		});
		new Day6(data, 6, tests);
	}

	function parse(data:String):GridData {
		var grid = [
			for (line in data.rtrim().split("\n"))
				line.split("").map(i -> GridSpace.fromString(i))
		];

		for (y => line in grid) {
			for (x => cell in line)
				switch (cell) {
					case Guard(d):
						grid[y][x] = Stepped(1);
						return {
							grid: grid,
							pt: [x, y],
							dir: d
						};
					default:
				}
		}

		throw new Exception("Guard not found");
	}

	function problem1(data:String) {
		var g = parse(data);
		var done = false;
		var retval = 0;

		while (!done) {
			var step = g.dir.applyToNewPoint(g.pt);
			if (step.x < 0 || step.y < 0)
				done = true;
			else
				switch (step.arrayGet(g.grid)) {
					case x = Space, x = Stepped(_):
						g.pt = step;
						step.arraySet(g.grid, x++);
					case Wall:
						g.dir = g.dir.cw();
					case null:
						done = true;
					default:
				}
		}

		for (line in g.grid)
			for (cell in line)
				if (cell.getName() == "Stepped")
					retval++;

		return retval;
	}

	function problem2(data:String) {
		var g = parse(data);
		var retval = 0;

		/**
		 * For every step:
		 * - Track the guard's position and location
		 * - Move forward
		 * - Check if there's a wall directly to the guard's right at any distance
		 * - If so:
		 *   - Place an obstruction in front of the guard
		 *   - Zip through the simulation
		 *   * We probably don't need to track positions/locations *after* the obstruction has been placed, since we can only place one
		 *   - If the guard returns to any position/location combo it ever has, it's a valid loop
		 *   - If the guard leaves the field, no good
		 * - Continue to keep track of spaces the guard has stepped on the grid
		 * * We probably can't put an obstruction anywhere the guard has already stepped, as it would create a paradox
		 * * We probably can't put an obstruction outside of the field
		 * - Keep going until the guard leaves the field out of lack of obstruction placed
		 * ! Maybe a good idea to have a watchdog to avoid indefinite looping (shouldn't happen since we are explicitly checking for loops, but still)
		 */

		return retval;
	}
}
