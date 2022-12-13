package y2022;

import haxe.Unserializer;
import haxe.Serializer;
import haxe.ds.ArraySort;
import utils.Point;

using StringTools;

var testData = [
	'Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
'
];

typedef IMapPoint = {
	var height:Int;
	var bestDist:Null<Int>;
}

@:forward
abstract MapPoint(IMapPoint) from IMapPoint to IMapPoint {
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

enum IMoveDir {
	Up(diff:Int);
	Right(diff:Int);
	Down(diff:Int);
	Left(diff:Int);
}

abstract MoveDir(IMoveDir) from IMoveDir to IMoveDir {
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

class HeightMap {
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

		// var countMoves = 0;
		// for (space in moves)
		// 	for (_ in space)
		// 		countMoves++;
		// trace('$countMoves valid moves'); // 111
	}

	public function pathForward(?start:Point) {
		if (isReverse != false)
			throw "Saved scan is not for forward moves";
		if (start == null)
			start = this.start;

		var queue = [start];
		map[start.y][start.x].bestDist = 0;

		while (queue.length > 0) {
			var pos = queue.shift();
			var here = map[pos.y][pos.x];
			if (!moves.exists(pos))
				continue;
			for (move in moves[pos]) {
				var dpos:Point = move.calcPos(pos), dpt = map[dpos.y][dpos.x];
				if (dpt.bestDist == null) {
					queue.push(dpos);
					moves[dpos] = moves[dpos].filter(i -> i != move.reverseDir());
					dpt.bestDist = here.bestDist + 1;
				} else
					dpt.bestDist = Math.round(Math.min(dpt.bestDist, here.bestDist + 1));
			}
		}

		return map[end.y][end.x].bestDist;
	}

	public function pathAllForward() {
		if (isReverse != false)
			throw "Saved scan is not for forward moves";
		var savedMoves = Serializer.run(moves);
		var bestSolution = 9999999;
		var candidates:Array<Point> = [];
		for (y => row in map)
			for (x => pt in row)
				if (pt == 0)
					candidates.push({x: x, y: y});

		while (candidates.length > 0) {
			for (row in map)
				for (pt in row)
					pt.bestDist = null;

			switch (pathForward(candidates.shift())) {
				case null:
					var antiCandidates:Array<String> = [];
					for (y => row in map)
						for (x => pt in row)
							if (pt.bestDist != null)
								antiCandidates.push('$x:$y');
					candidates = candidates.filter(i -> !antiCandidates.contains(i));
				case x:
					bestSolution = Math.round(Math.min(bestSolution, x));
			}
			moves = Unserializer.run(savedMoves);
		}

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
					rowChars += String.fromCharCode(pt + charCode_a);
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
