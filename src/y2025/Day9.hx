package y2025;

import haxe.ds.ArraySort;
import haxe.DynamicAccess;
import haxe.Int64;
import utils.Point;

using StringTools;
using Safety;

private var testData = [
	'7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
'
];

private enum D9IAngle {
	TL;
	TR;
	BL;
	BR;
}

@:follow
private abstract D9Angle(D9IAngle) from D9IAngle to D9IAngle {
	private function new(i:D9IAngle)
		this = i;

	public var opposite(get, never):D9Angle;
	public var cw(get, never):D9Angle;
	public var ccw(get, never):D9Angle;

	private function get_opposite()
		return switch (this) {
			case TL: BR;
			case TR: BL;
			case BL: TR;
			case BR: TL;
		}

	private function get_cw()
		return switch (this) {
			case TL: TR;
			case TR: BR;
			case BR: BL;
			case BL: TL;
		}

	private function get_ccw()
		return switch (this) {
			case TL: BL;
			case BL: BR;
			case BR: TR;
			case TR: TL;
		}

	public static function identifyCorner(lhs:Point, rhs:Point):Null<D9Angle> {
		if (lhs == rhs)
			throw 'Cannot identify corners on identical points';
		if (lhs.x == rhs.x || lhs.y == rhs.y)
			return null;
		if (lhs.x < rhs.x) {
			if (lhs.y < rhs.y)
				return BR;
			else
				return TR;
		} else if (lhs.x > rhs.x) {
			if (lhs.y < rhs.y)
				return BL;
			else
				return TL;
		} else
			throw 'Unable to identify lhs corner for $lhs $rhs';
	}
}

private enum D9IAngleType {
	Narrow(a:D9Angle);
	Wide(a:D9Angle);
}

@:follow
private abstract D9AngleType(D9IAngleType) from D9IAngleType to D9IAngleType {
	private function new(i:D9IAngleType)
		this = i;

	public function containsType(rhs:D9IAngleType)
		return switch ([this, rhs]) {
			case [Narrow(x), Narrow(y)] | [Wide(x), Wide(y)]: x == y;
			case [Wide(x), Narrow(y)]: x.opposite != y;
			case [Narrow(_), Wide(_)]: false;
		}

	public function containsAngle(rhs:D9Angle)
		return switch (this) {
			case Narrow(x): x == rhs;
			case Wide(x): x != rhs;
		}
}

class Day9 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				// expected: [50].map(Int64.ofInt)
				expected: [50, 24].map(Int64.ofInt)
			}
		});
		new Day9(data, 9, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(Point.fromString);

	function problem1(data:String) {
		var list = parse(data);
		var retval:Int64 = 0;
		for (x => lhs in list.slice(0, -1))
			for (rhs in list.slice(x + 1)) {
				var area = Int64.mul(Math.round(Math.abs(lhs.x - rhs.x + 1)), Math.round(Math.abs(lhs.y - rhs.y + 1)));
				if (area > retval)
					retval = area;
			}
		return retval;
	}

	function problem2(data:String) {
		var list = parse(data);
		var vertextypes:DynamicAccess<D9AngleType> = {};
		var horizontals:Map<Int, Array<Array<Int>>> = [],
			verticals:Map<Int, Array<Array<Int>>> = [];
		var retval:Int64 = 0;

		{
			/* Scope these vars because they don't need to exist outside of here */
			var topi = 0, toppt = list[0];
			var vertices:DynamicAccess<D9Angle> = {};

			for (x => angle in list) {
				/* Get the previous and next angles on the list, looping as necessary */
				var prev = list[x - 1].or(list[list.length - 1]),
					next = list[x + 1].or(list[0]);

				/* Keep track of the leftmost vertex on the topmost line, important for angle calculation */
				if (angle.y < toppt.y || (angle.y == toppt.y && angle.x < toppt.x)) {
					topi = x;
					toppt = angle;
				}

				/* Calculate the narrow side of the angle, regardless of fill direction */
				// TODO: this duplicate code can probably be simplified
				if (angle.x == next.x) {
					if (angle.y != prev.y)
						throw 'Unexpected flat angle angle for $prev to $angle to $next';

					if (!verticals.exists(angle.x))
						verticals[angle.x] = [];
					verticals[angle.x].push([angle.y, next.y]);

					if (angle.y > next.y) {
						if (angle.x < prev.x)
							vertices[angle] = TR;
						else if (angle.x > prev.x)
							vertices[angle] = TL;
					} else if (angle.y < next.y) {
						if (angle.x < prev.x)
							vertices[angle] = BR;
						else if (angle.x > prev.x)
							vertices[angle] = BL;
					} else
						throw 'Unable to calculate angle for $prev to $angle to $next';
				} else if (angle.y == next.y) {
					if (angle.x != prev.x)
						throw 'Unexpected flat angle angle for $prev to $angle to $next';

					if (!horizontals.exists(angle.y))
						horizontals[angle.y] = [];
					horizontals[angle.y].push([angle.x, next.x]);

					if (angle.x > next.x) {
						if (angle.y < prev.y)
							vertices[angle] = BL;
						else if (angle.y > prev.y)
							vertices[angle] = TL;
					} else if (angle.x < next.x) {
						if (angle.y < prev.y)
							vertices[angle] = BR;
						else if (angle.y > prev.y)
							vertices[angle] = TR;
					} else
						throw 'Unable to calculate angle for $prev to $angle to $next';
				} else
					throw 'Unexpected diagonal line from $angle to $next';
			}

			/* The topmost line, leftmost vertex should always resolve as a bottom-right angle */
			if (vertices[toppt] != BR)
				throw 'Identified starting point $toppt is not a BR corner';
			// else
			// 	trace('topmost line, leftmost vertex is $toppt (this gets set to Narrow(BR))');

			/* And that angle will always be a narrow angle */
			vertextypes[toppt] = Narrow(BR);

			/* Cut the deck at that point, and start scanning through again to determine fill side */
			for (x => angle in list.slice(topi).concat(list.slice(0, topi))) {
				var next = list[(x + 1 + topi) % list.length];
				vertextypes[next] = switch [vertextypes[angle], vertices[next]] {
					/* General logic:
						- If the next angle is cw or ccw, it will be the same type of angle 
						- If the next angle is opposite, it will be the opposite type of angle
						- If the next angle is the same, that's impossible and throw an error */
					case [Narrow(x), y] if (y == x.cw || y == x.ccw): Narrow(y);
					case [Narrow(x), y] if (y == x.opposite): Wide(y);
					case [Wide(x), y] if (y == x.cw || y == x.ccw): Wide(y);
					case [Wide(x), y] if (y == x.opposite): Narrow(y);
					case [x, y]: throw 'Invalid corner for $angle ($x) to $next ($y)';
				}
				// trace('$next - ${vertices[next]} - ${vertextypes[next]}');
			}

			/* Double-check that the starting point is still Narrow(BR) */
			if (!Type.enumEq(vertextypes[toppt], Narrow(BR)))
				throw 'Origin corner did not resolve back as Narrow(BR) (got ${vertextypes[toppt]})';
		}

		/* Sort all the line sets so that [0] <= [1] */
		for (axis in [horizontals, verticals])
			for (set in axis)
				for (line in set)
					ArraySort.sort(line, (x, y) -> x - y);

		// trace(vertextypes);

		// var solutionlhs:Null<Point> = null, solutionrhs:Null<Point> = null;

		/* Test every vertex against every other vertex, without needlessly repeating */
		for (z => lhs in list.slice(0, -1))
			for (rhs in list.slice(z + 1)) {
				/* First, evaluate the two opposite corners to ensure the area is plausible */
				var corner = D9Angle.identifyCorner(lhs, rhs);

				/* If corner is null, it's because it's a flat shape, which is automatically valid
					in this context */
				/* If corner is not null, then the fill angle on opposite sides must be valid */
				/* If a corner is outside of the red/green zone, the test shape is invalid and we move right on */
				if (corner != null && !(vertextypes[lhs].containsAngle(corner) && vertextypes[rhs].containsAngle(corner.opposite))) {
					// trace('$lhs (${vertextypes[lhs]}) to $rhs (${vertextypes[rhs]}) no good because:');
					// if (!vertextypes[lhs].containsAngle(corner))
					// 	trace('- $lhs does not contain $corner');
					// if (!vertextypes[rhs].containsAngle(corner.opposite))
					// 	trace('- $rhs does not contain ${corner.opposite}');
					continue;
				}

				/* Then, scan against each horizontal and vertical line */
				function compareLine(sStart:Int, sEnd:Int, rStart:Int, rEnd:Int, compset:Map<Int, Array<Array<Int>>>) {
					/* Ensure sStart <= sEnd and rStart <= rEnd */
					if (sStart > sEnd)
						throw 'Invalid scan values, $sStart should <= $sEnd';
					if (rStart > rEnd)
						throw 'Invalid range values, $rStart should <= $rEnd';

					/* If it's a flat shape on this axis, this code doesn't even run
						because it doesn't need to */
					for (x in sStart + 1...sEnd) {
						if (!compset.exists(x))
							continue;
						for (set in compset[x]) {
							/* We've already sorted line sets, so we can assume set[0] <= set[1] */
							/* So if both set[0] <= rStart and set[1] >= rEnd, that line draws straight
								through the test shape */
							if (set[0] <= rStart && set[1] >= rEnd) {
								// trace('$x1:$y1 (${vertextypes[lhs]}) to $x2:$y2 (${vertextypes[rhs]}) no good because:');
								// if (compset == verticals)
								// 	trace('- $x:$set is all the way through it');
								// if (compset == horizontals)
								// 	trace('- $set:$x is all the way through it');
								return false;
							}
							/* If set[0] or set[1] is distinctly in between rStart and rEnd,
								the line draws partway through the test shape */
							/* If either of those are on the top or bottom edge (but both aren't on either as above),
								that line does not draw into the test shape and so is okay */
							if ((set[0] > rStart && set[0] < rEnd) || (set[1] > rStart && set[1] < rEnd)) {
								// trace('$x1:$y1 (${vertextypes[lhs]}) to $x2:$y2 (${vertextypes[rhs]}) no good because:');
								// if (compset == verticals)
								// 	trace('- $x:$set intersects');
								// if (compset == horizontals)
								// 	trace('- $set:$x intersects');
								return false;
							}
						}
					}
					return true;
				}

				/* Ensure that x1 <= x2 and y1 <= y2 while still forming the same test shape */
				var x1 = lhs.x < rhs.x ? lhs.x : rhs.x,
					x2 = lhs.x > rhs.x ? lhs.x : rhs.x,
					y1 = lhs.y < rhs.y ? lhs.y : rhs.y,
					y2 = lhs.y > rhs.y ? lhs.y : rhs.y;

				// if (Math.round(Math.abs(lhs.x - rhs.x)) != x2 - x1)
				// 	throw 'You did it wrong on the X axis ($lhs $rhs $x1 $x2 ${lhs.x - rhs.x} ${x2 - x1})';
				// if (Math.round(Math.abs(lhs.y - rhs.y)) != y2 - y1)
				// 	throw 'You did it wrong on the Y axis ($lhs $rhs $y1 $y2 ${lhs.y - rhs.y} ${y2 - y1})';

				// trace(lhs, rhs, x1, x2, y1, y2);

				/* Check the table of vertical lines against the test shape horizontally */
				var good = compareLine(x1, x2, y1, y2, verticals);
				/* Check the table of horizontal lines against the test shape vertically */
				if (good)
					compareLine(y1, y2, x1, x2, horizontals);
				if (good) {
					/* We should have found a shape that is fully within the red/green zone */
					/* Calculate its surface area and compare it against the previous biggest result */
					var area = Int64.mul(Math.round(Math.abs(lhs.x - rhs.x + 1)), Math.round(Math.abs(lhs.y - rhs.y + 1)));
					if (area > retval) {
						// solutionlhs = lhs;
						// solutionrhs = rhs;
						retval = area;
					}
				}
			}

		// trace(solutionlhs, solutionrhs);
		return retval;
		// 4629361800 too high
	}
}
