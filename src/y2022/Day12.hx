package y2022;

import haxe.Unserializer;
import haxe.Serializer;
import utils.Point;

using StringTools;

private var testData = [
	'Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
'
];

private typedef IMapPoint = {
	var height:Int;
	var bestDist:Null<Int>;
}

@:forward
private abstract MapPoint(IMapPoint) from IMapPoint to IMapPoint {
	public function new(height:Int, ?bestDist:Int)
		this = {
			height: height,
			bestDist: bestDist
		};

	@:op(a > b)
	public inline function gtMapPoint(rhs:MapPoint)
		return this.height > rhs.height;

	@:op(a < b)
	public inline function ltMapPoint(rhs:MapPoint)
		return this.height < rhs.height;

	@:op(a >= b)
	public inline function geMapPoint(rhs:MapPoint)
		return this.height >= rhs.height;

	@:op(a <= b)
	public inline function leMapPoint(rhs:MapPoint)
		return this.height <= rhs.height;

	@:op(a == b)
	public inline function eqMapPoint(rhs:MapPoint)
		return this.height == rhs.height;

	@:op(a + b)
	public inline function addMapPoint(rhs:MapPoint)
		return new MapPoint(this.height + rhs.height);

	@:op(a - b)
	public inline function subMapPoint(rhs:MapPoint)
		return new MapPoint(this.height - rhs.height);

	@:from
	public static inline function fromInt(height:Int)
		return new MapPoint(height);

	@:to
	public inline function toInt()
		return this.height;

	@:to
	public inline function toString()
		return String.fromCharCode(this.height + HeightMap.charCode_a);

	public inline function toDetailedString()
		return 'Height: ${this.height} (${String.fromCharCode(this.height + HeightMap.charCode_a)}) - Best distance to space: ${this.bestDist}';
}

private enum IMoveDir {
	Up(diff:Int);
	Right(diff:Int);
	Down(diff:Int);
	Left(diff:Int);
}

private abstract MoveDir(IMoveDir) from IMoveDir to IMoveDir {
	public var diff(get, never):Int;
	public var dir(get, never):String;

	inline function get_diff()
		return this.getParameters()[0];

	inline function get_dir()
		return this.getName();

	@:op(a == b)
	public function eqMoveDir(rhs:MoveDir)
		return (this.getName() == rhs.getName() && this.getParameters()[0] == this.getParameters()[0]);

	@:op(a != b)
	public function neqMoveDir(rhs:MoveDir)
		return (this.getName() != rhs.getName() || this.getParameters()[0] != this.getParameters()[0]);

	public inline function reverseDir()
		return switch (this) {
			case Up(diff): Down(-diff);
			case Down(diff): Up(-diff);
			case Left(diff): Right(-diff);
			case Right(diff): Left(-diff);
		}

	public function calcPos(pos:Point) {
		var newPos:Point = {x: pos.x, y: pos.y};
		switch (this) {
			case Up(_):
				newPos.y--;
			case Left(_):
				newPos.x--;
			case Down(_):
				newPos.y++;
			case Right(_):
				newPos.x++;
		}
		return newPos;
	}

	public function calcRevPos(pos:Point) {
		var newPos:Point = {x: pos.x, y: pos.y};
		switch (this) {
			case Up(_):
				newPos.y++;
			case Left(_):
				newPos.x++;
			case Down(_):
				newPos.y--;
			case Right(_):
				newPos.x--;
		}
		return newPos;
	}
}

private class HeightMap {
	public static final charCode_a = "a".charCodeAt(0);

	var map:Array<Array<MapPoint>> = [];
	var start:Point;
	var end:Point;
	var moves:Map<String, Array<MoveDir>> = [];
	var isReverse:Null<Bool> = null;

	public var width(get, never):Int;
	public var height(get, never):Int;

	public function new(data:String) {
		map = data.rtrim().split("\n").map(y -> y.split("").map(x -> new MapPoint(switch (x) {
			case "S": -1;
			case "E": -2;
			default: x.charCodeAt(0) - charCode_a;
		})));
		var startPoints = 0;
		for (y => row in map)
			for (x => pt in row)
				switch (pt.height) {
					case 0:
						startPoints++;
					case -1:
						startPoints++;
						map[y][x] = 0;
						start = {x: x, y: y};
					case -2:
						map[y][x] = 25;
						end = {x: x, y: y};
				}
	}

	inline function get_width()
		return map[0].length;

	inline function get_height()
		return map.length;

	public function scanForward() {
		moves = [];
		isReverse = false;
		for (y => row in map)
			for (x => pt in row) {
				pt.bestDist = null;
				var movesHere:Array<MoveDir> = [];
				if (y > 0 && map[y - 1][x] <= pt + 1)
					movesHere.push(Up(map[y - 1][x] - pt));
				if (x > 0 && map[y][x - 1] <= pt + 1)
					movesHere.push(Left(map[y][x - 1] - pt));
				if (y < height - 1 && map[y + 1][x] <= pt + 1)
					movesHere.push(Down(map[y + 1][x] - pt));
				if (x < width - 1 && map[y][x + 1] <= pt + 1)
					movesHere.push(Right(map[y][x + 1] - pt));
				if (movesHere.length > 0)
					moves['$x:$y'] = movesHere;
			}
	}

	public function pathForward(?start:Point) {
		// We're gonna use the Dijkstra method for this
		if (isReverse != false) scanForward();
		// Also part 2 has a mobile start point; if one is not provided, use the one provided by the input
		if (start == null)
			start = this.start;

		// The processing queue starts at the start point (go figure)
		var queue = [start];
		// And the best distance from start to start is always 0
		map[start.y][start.x].bestDist = 0;

		while (queue.length > 0) {
			// Grab the next position from the queue
			var pos = queue.shift();
			var here = map[pos.y][pos.x];
			// If there are no valid moves saved for this position (which shouldn't happen, but just in case) keep going
			if (!moves.exists(pos))
				continue;
			for (move in moves[pos]) {
				// Assume the destination point exists, and save it to a var
				var dpos:Point = move.calcPos(pos), dpt = map[dpos.y][dpos.x];
				// If we haven't seen the destination position before:
				if (dpt.bestDist == null) {
					// Add it to the queue
					queue.push(dpos);
					// And don't process the move back to the current position (if it's valid)
					moves[dpos] = moves[dpos].filter(i -> i != move.reverseDir());
					// We don't have any other distance for the destination, so just assign it something
					dpt.bestDist = here.bestDist + 1;
				} else
					// See if (to here) + 1 is better than the best distance to the destination; if so, update it
					dpt.bestDist = Math.round(Math.min(dpt.bestDist, here.bestDist + 1));
			}
		}

		// Return the best distance to the end point, if we even reached it
		return map[end.y][end.x].bestDist;
	}

	public function pathAllForward() {
		if (isReverse != false) scanForward();
		// Serialise the move list, 'cause we're gonna be running lots of simulations
		var savedMoves = Serializer.run(moves);
		// Best solution for now is just gonna be a big number for convenience (otherwise we'd use Null<Int> and that adds mess we can avoid)
		var bestSolution = 9999999;
		// Build a candidate list of every location on the map with 'a' height
		var candidates:Array<Point> = [];
		for (y => row in map)
			for (x => pt in row)
				if (pt == 0)
					candidates.push({x: x, y: y});

		while (candidates.length > 0) {
			// Wipe out the entire table of best distances
			for (row in map)
				for (pt in row)
					pt.bestDist = null;

			// Run pathForward on the first candidate in the list
			switch (pathForward(candidates.shift())) {
				case null: // We didn't find the end
					// That means we probably found a bunch of other candidates that'll have the same result, so let's take them off the list
					var antiCandidates:Array<String> = [];
					for (y => row in map)
						for (x => pt in row)
							// If a space has a best distance assigned, assume that it's not gonna go anywhere
							if (pt.bestDist != null)
								antiCandidates.push('$x:$y');
					candidates = candidates.filter(i -> !antiCandidates.contains(i));
				case x: // We got to the end (store the result in x 'cause Haxe is cool like that)
					// If it's the best score we've found, save it
					bestSolution = Math.round(Math.min(bestSolution, x));
			}
			// Deserialise the move list to restore it to how it was before starting
			moves = Unserializer.run(savedMoves);
		}

		// Return the best solution we were able to find (or 9999999 if we never once got to the end)
		return bestSolution;
	}

	public function toString() {
		var retval:Array<String> = [];
		for (y => row in map) {
			var rowChars = "";
			for (x => pt in row)
				if (start.x == x && start.y == y)
					rowChars += "X";
				else if (end.x == x && end.y == y)
					rowChars += "E";
				else
					rowChars += pt;
			retval.push(rowChars);
		}
		return retval.join("\n");
	}
}

class Day12 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [31, 29]
			}
		});
		new Day12(data, 12, tests);
	}

	function problem1(data:String) {
		var map = new HeightMap(data);
		map.scanForward();
		return cast map.pathForward();
	}

	function problem2(data:String) {
		var map = new HeightMap(data);
		map.scanForward();
		return cast map.pathAllForward();
	}
}
