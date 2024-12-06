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
				expected: [41, 6]
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

	/**
	 * For every step:
	 * - Track the guard's position and location
	 * - Move forward
	 * * We probably don't need to track for turns, since those happen deterministically (but do anyway)
	 *   - no, still track position on turn
	 * - Check if there's a wall directly to the guard's right at any distance
	 * - If so:
	 *   - Place an obstruction in front of the guard
	 *   - Zip through the simulation
	 *   * We probably don't need to track positions/locations *after* the obstruction has been placed, since we can only place one
	 *     - yes the fuck we do, otherwise a loop can happen in an unexpected place
	 *   - If the guard returns to any position/location combo it ever has, it's a valid loop
	 *   - If the guard leaves the field, no good
	 * - Continue to keep track of spaces the guard has stepped on the grid
	 * * We probably can't put an obstruction anywhere the guard has already stepped, as it would create a paradox
	 *   - conclusive that we don't; this results in a number that's much too high
	 * * We probably can't put an obstruction outside of the field
	 *   - not that we *can't*, but this seems to not affect the response at all
	 * - Keep going until the guard leaves the field out of lack of obstruction placed
	 * ! Maybe a good idea to have a watchdog to avoid indefinite looping (shouldn't happen since we are explicitly checking for loops, but still)
	 *   - as long as we track every position in and out of sim, this seems unnecessary
	 */
	function problem2(data:String) {
		var g = parse(data);
		var done = false;
		var history:Map<String, Bool> = [];
		var retval = 0;

		var obst:Null<Point> = null;
		var gsim:Null<GridData> = null;
		var hsim:Null<Map<String, Bool>> = null;

		while (!done) {
			if (obst != null) { // we're considering an obstruction
				var step = gsim.dir.applyToNewPoint(gsim.pt); // look forward
				if (step == obst) // the guard runs into the new obstruction and would turn
					gsim.dir = gsim.dir.cw();
				else
					switch (step.arrayGet(gsim.grid)) { // otherwise simulate as normal
						case Space, Stepped(_): // the guard would step forward
							gsim.pt = step;
						case Wall: // the guard would turn right
							gsim.dir = gsim.dir.cw();
						case null: // the guard would leave the field without looping; simulation failed
							obst = null; // exit the simulation
						default:
					}

				if (obst != null) {
					if (history.exists('${gsim.pt.x}${gsim.dir.c}${gsim.pt.y}')
						|| hsim.exists('${gsim.pt.x}${gsim.dir.c}${gsim.pt.y}')) { // the guard has been in this position before and thus is in a loop
						retval++; // simulation success
						obst = null; // exit the simulation
					} else
						hsim.set('${gsim.pt.x}${gsim.dir.c}${gsim.pt.y}', true); // keep track of this position
				}

				if (obst == null) {
					gsim = null;
					hsim = null;
				}
			} else { // we're not considering an obstruction
				var step = g.dir.applyToNewPoint(g.pt); // look forward
				switch (step.arrayGet(g.grid)) {
					case x = Space, x = Stepped(_): // the guard steps forward
						g.pt = step;
						step.arraySet(g.grid, x++);
					case Wall: // the guard turns right
						g.dir = g.dir.cw();
					case null: // the guard has left the field
						done = true;
					default:
				}

				if (!done) { // while the guard is still on the field
					history.set('${g.pt.x}${g.dir.c}${g.pt.y}', true); // keep track of this position

					// If the guard hasn't left the field, and in front of them is an unstepped space
					// (must be unstepped to avoid a paradox)
					if (g.dir.applyToNewPoint(g.pt).arrayGet(g.grid) == Space) {
						var toRight = g.dir.cw(); // look right
						if (history.exists('${g.pt.x}${toRight.c}${g.pt.y}')) { // if the guard has already been in this position facing to their right
							retval++; // instantly resolve that thread
						} else {
							var chkPt = toRight.applyToNewPoint(g.pt);
							var res:Null<Bool> = null;
	
							while (res == null) {
								chkPt = toRight.applyToNewPoint(chkPt); // keep scanning to the guard's right
								switch (chkPt.arrayGet(g.grid)) {
									case Wall: // if there's a wall, good
										res = true;
									case null: // if there's nothing, bad
										res = false;
									default: // if there's anything else, keep looking
								}
							}
	
							if (res) { // if the check found a wall at any distance
								obst = g.dir.applyToNewPoint(g.pt); // put an obstruction in front of the guard
								gsim = { // set up a simulation
									grid: g.grid,
									dir: toRight,
									pt: g.pt
								};
								hsim = [];
							}
						}
					}
				}
			}
		}

		return retval;
		// 1744 too low
		// 1748 is correct, but not what this script finds
	}
}
