package y2022;

import haxe.ds.ArraySort;
import haxe.Unserializer;
import helder.Set;
import haxe.Serializer;
import utils.Point;

using StringTools;

private enum IBlizzardDir {
	Up;
	Left;
	Down;
	Right;
}

private abstract BlizzardDir(IBlizzardDir) from IBlizzardDir {
	public inline function apply(pt:Point)
		return pt + switch (this) {
			case Up: {x: 0, y: -1};
			case Left: {x: -1, y: 0};
			case Down: {x: 0, y: 1};
			case Right: {x: 1, y: 0};
		}

	@:to
	public inline function toString()
		return switch (this) {
			case Up: "^";
			case Left: "<";
			case Down: "v";
			case Right: ">";
		}
}

private typedef IBlizzard = {
	var pos:Point;
	var dir:BlizzardDir;
}

@:forward
private abstract Blizzard(IBlizzard) from IBlizzard {
	public inline function new(x:Int, y:Int, dir:BlizzardDir)
		this = {pos: {x: x, y: y}, dir: dir};

	public inline function forward()
		return this.dir.apply(this.pos);

	public inline function clone()
		return new Blizzard(this.pos.x, this.pos.y, this.dir);
}

private typedef BlizzardState = {
	var pos:Point;
	var move:Int;
}

private class BlizzardEngine {
	static var dirs:Array<Point> = [{x: -1, y: 0}, {x: 0, y: -1}, {x: 0, y: 0}, {x: 0, y: 1}, {x: 1, y: 0}];
	static var startDirs:Array<Point> = [{x: 0, y: 0}, {x: 0, y: 1}];

	var blizzards:Array<Blizzard> = [];
	var blizzLocs = new Set<String>();

	var pos:Point = {x: 0, y: -1};
	var posCache:Array<String> = [];

	public var width(default, null) = 0;
	public var height(default, null) = 0;
	public var moves(default, null) = 0;

	public function new(data:String) {
		var list = data.rtrim().split("\n").filter(i -> !i.startsWith("###") && !i.endsWith("###"));
		height = list.length;
		width = list[0].length - 2;
		for (y => row in list)
			for (x => ch in row.split("").filter(i -> i != "#"))
				if (ch != ".")
					blizzards.push({
						pos: {x: x, y: y},
						dir: switch (ch) {
							case "^": Up;
							case "<": Left;
							case "v": Down;
							case ">": Right;
							case x: throw 'Unknown character $x';
						}
					});

		blizzLocs = new Set(blizzards.map(i -> i.pos.toString()));

		var s = new Serializer();
		s.serialize(blizzards);
		s.serialize(blizzLocs);
		posCache.push(s.toString());
	}

	function advance(?to:Int) {
		if (to == moves)
			return;
		if (to == null)
			to = moves + 1;

		moves = Math.round(Math.min(to, posCache.length - 1));
		var u = new Unserializer(posCache[moves]);
		blizzards = u.unserialize();
		blizzLocs = u.unserialize();

		while (moves < to) {
			moves++;
			for (blizz in blizzards) {
				var dest = blizz.forward();
				if (dest.x < 0)
					dest.x = width - 1;
				if (dest.y < 0)
					dest.y = height - 1;
				if (dest.x >= width)
					dest.x = 0;
				if (dest.y >= height)
					dest.y = 0;
				blizz.pos = dest;
			}
			blizzLocs = new Set(blizzards.map(i -> i.pos.toString()));

			var s = new Serializer();
			s.serialize(blizzards);
			s.serialize(blizzLocs);
			posCache.push(s.toString());
		}
	}

	public function work(?toEnd = true, ?from = 0) {
		var start:Point = toEnd ? {x: 0, y: -1} : {x: width - 1, y: height};
		var oneFromGoal:Point = toEnd ? {x: width - 1, y: height - 1} : {x: 0, y: 0};
		var goal:Point = toEnd ? {x: width - 1, y: height} : {x: 0, y: -1};
		var cache = new Set<String>();
		var best:Null<Int> = null;
		var sortDelay = 0;
		var wdirs = dirs.slice(0);
		var states:Array<BlizzardState> = [
			{
				pos: start,
				move: from
			}
		];

		if (!toEnd) wdirs.reverse();

		var wStartDirs = wdirs.slice(2, 4);

		while (states.length > 0) {
			sortDelay++;
			if (sortDelay >= Math.round(Math.min(states.length / 2, best == null ? 10 : 200))) {
				if (best != null)
					states.reverse();
				ArraySort.sort(states, (lhs, rhs) -> lhs.pos.manhattan(goal) - rhs.pos.manhattan(goal));
				// trace(best, states.length, states.map(i -> i.pos.manhattan(goal)));
			}

			var st = states.shift();
			if (best != null) {
				// Might not be a bad idea to count the Manhattan distance to the exit; if it's going to take us longer to get there than our best path, prune the state entirely
				// This will get rid of a lot of useless states, ideally
				var manhattan = st.pos.manhattan(goal);
				if (st.move + manhattan >= best) {
					// trace('dropping a move (${st.move} + $manhattan >= $best)');
					continue;
				}
			}

			advance(st.move + 1);
			// var sc = states.length;
			if (st.pos == start) {
				// Here, our only valid moves are down or wait
				//for (step in startDirs.map(i -> st.pos + i))
				for (step in wStartDirs.map(i -> st.pos + i))
					if (!blizzLocs.exists(step))
						states.unshift({
							pos: step,
							move: st.move + 1
						});
			} else if (st.pos == oneFromGoal) {
				// There's only one good move here, and there will never be a blizzard at the exit
				// Score this path as best (make sure it *is* best for good measure)
				var finalMoves = st.move + 1;
				if (best == null || best > finalMoves) {
					best = finalMoves;
					// Immediately filter out paths that are not good enough
					var count = states.length;
					states = states.filter(i -> i.pos.manhattan(goal) + i.move < best);
					trace('new best path: $best; pruned ${count - states.length}/$count state(s) sure to be too long');
				}
			} else {
				// We need to skip any directions that take us past the board boundary
				//for (step in dirs.map(i -> st.pos + i).filter(i -> i.x >= 0 && i.y >= 0 && i.x < width && i.y < height))
				for (step in wdirs.map(i -> st.pos + i).filter(i -> i.x >= 0 && i.y >= 0 && i.x < width && i.y < height))
					if (!blizzLocs.exists(step)) {
						var newState:BlizzardState = {
							pos: step,
							move: st.move + 1
						}, stateSig = '${newState.pos}.${newState.move.hex()}';
						if (!cache.exists(stateSig)) {
							cache.add(stateSig);
							if (best == null)
								states.unshift(newState);
							else
								states.push(newState);
						}
					}
			}
			// if (states.length > sc) trace('added ${states.length - sc} state(s); now at ${states.length}');
		}
		// trace(cache);
		return best;
	}

	public function visualise(?move:Int) {
		if (move != null)
			advance(move);

		var map:Map<String, Array<Blizzard>> = [];
		for (blizz in blizzards) {
			if (!map.exists(blizz.pos))
				map.set(blizz.pos, [blizz]);
			else
				map[blizz.pos].push(blizz);
		}

		var retval = "";
		for (y in 0...height) {
			for (x in 0...width) {
				if (!map.exists('$x:$y'))
					retval += ".";
				else
					retval += switch (map['$x:$y'].length) {
						case 1:
							map['$x:$y'][0].dir.toString();
						case x > 9 => true: "*";
						case x: '$x';
					}
			}
			retval += "\n";
		}
		return retval;
	}
}

class Day24 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			// 			{
			// 				data: '#.#####
			// #.....#
			// #>....#
			// #.....#
			// #...v.#
			// #.....#
			// #####.#',
			// 				expected: [10]
			// 			},
			{
				data: '#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#',
				expected: [18, 54]
			}
		];
		new Day24(data, 24, tests);
	}

	function problem1(data:String) {
		var beng = new BlizzardEngine(data);
		return cast beng.work();
	}

	function problem2(data:String) {
		var beng = new BlizzardEngine(data);
		var path1 = beng.work();
		if (path1 == null) throw '"There" failed to find a path';
		var path2 = beng.work(false, cast path1);
		if (path2 == null) throw '"Back again" failed to find a path';
		return cast beng.work(true, path2);
	}
}
