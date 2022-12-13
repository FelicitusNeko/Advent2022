package y2022;

import haxe.ds.ArraySort;
import y2022.Day9.Point;

using StringTools;

var testData = [
	'Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
'
];

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

	public function calcPos(pos:Point) {
		var newPos = {x: pos.x, y: pos.y};
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
		var newPos = {x: pos.x, y: pos.y};
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

	var map:Array<Array<Int>> = [];
	var start:Point;
	var end:Point;
	var moves:Map<String, Array<MoveDir>> = [];
	var isReverse:Null<Bool> = null;

	public var width(get, never):Int;
	public var height(get, never):Int;

	public function new(data:String) {
		map = data.rtrim().split("\n").map(y -> y.split("").map(x -> switch (x) {
			case "S": -1;
			case "E": -2;
			default: x.charCodeAt(0) - charCode_a;
		}));
		for (y => row in map)
			for (x => pt in row)
				switch (pt) {
					case -1:
						map[y][x] = 0;
						start = {x: x, y: y};
					case -2:
						map[y][x] = 25;
						end = {x: x, y: y};
				}
		trace(width, height);
	}

	inline function get_width()
		return map[0].length;

	inline function get_height()
		return map.length;

	public function scanValid() {
		moves = [];
		isReverse = false;
		for (y => row in map)
			for (x => pt in row) {
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

	public function scanReverse() {
		moves = [];
		isReverse = true;
		for (y => row in map)
			for (x => pt in row) {
				var movesHere:Array<MoveDir> = [];
				if (y > 0 && map[y - 1][x] >= pt - 1)
					movesHere.push(Down(pt - map[y - 1][x]));
				if (x > 0 && map[y][x - 1] >= pt - 1)
					movesHere.push(Right(pt - map[y][x - 1]));
				if (y < height - 1 && map[y + 1][x] >= pt - 1)
					movesHere.push(Up(pt - map[y + 1][x]));
				if (x < width - 1 && map[y][x + 1] >= pt - 1)
					movesHere.push(Left(pt - map[y][x + 1]));
				if (movesHere.length > 0)
					moves['$x:$y'] = movesHere;
			}
		// trace(moves[end]);
		// var countMoves = 0;
		// for (space in moves)
		// 	for (_ in space)
		// 		countMoves++;
		// trace('$countMoves valid reverse moves'); // 111
	}

	public function pathReverse() {
		if (isReverse != true)
			throw "Saved scan is not for reverse moves";
		var moveStack = [];
		var bestSolution:Int = 9999999;

		function find(pos:Point) {
			var retval = false;
			if (moveStack.contains(pos) || !moves.exists(pos))
				return false;
			moveStack.push(pos);
			if (pos == start) {
				bestSolution = Math.round(Math.min(bestSolution, moveStack.length));
				retval = true;
			} else {
				var solved = false;
				var mv = moves[pos].slice(0);
				ArraySort.sort(mv, (l,r) -> l.diff - r.diff);
				var dx = pos.x - start.x, dy = pos.y - start.y;
				var prefDir:Null<String> = null;
				if (Math.abs(dy) > Math.abs(dx))
					prefDir = dy > 0 ? "Down" : "Up";
				else if (dy != 0)
					prefDir = dx > 0 ? "Right" : "Left";
				var prefIndex = mv.map(i -> i.dir).indexOf(prefDir);
				if (prefIndex > -1) solved = find(mv.splice(prefIndex, 1)[0].calcRevPos(pos));
				for (dir in mv) if (!solved || dir.diff >= -1) find(dir.calcRevPos(pos));
			}
			moveStack.pop();
			return retval;
		}
		find(end);
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
				expected: [31]
			}
		});
		new Day12(data, 12, tests);
	}

	function problem1(data:String) {
		var map = new HeightMap(data);
		map.scanReverse();
		return map.pathReverse();
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
