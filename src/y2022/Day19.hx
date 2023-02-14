package y2022;

import haxe.ds.ArraySort;
import helder.Set;

using StringTools;
using Safety;

private var testData = [
	'Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.'
];

private typedef IState = {
	var minutes:Int;
	var bots:Array<Int>;
	var ores:Array<Int>;
	var ?queue:OreType;
}

@:forward
private abstract State(IState) from IState {
	public var botValue(get, never):Int;
	public var oreValue(get, never):Int;

	public inline function new(minutes:Int, bots:Array<Int>, ores:Array<Int>, ?queue:OreType)
		this = {
			minutes: minutes,
			bots: bots.slice(0),
			ores: ores.slice(0),
			queue: queue
		};

	public inline function clone()
		return new State(this.minutes, this.bots, this.ores, this.queue);

	function get_botValue() {
		var retval = 0;
		for (x => ct in this.bots)
			retval += (x + 1) * ct;
		if (this.queue != null)
			retval += this.queue + 1;
		return retval;
	}

	function get_oreValue() {
		var retval = 0;
		for (x => ct in this.ores)
			retval += (x + 1) * ct;
		return retval;
	}

	@:to
	public inline function toString()
		return '${this.minutes.hex()}:${this.bots.map(i -> i.hex()).join(".")}#${this.ores.map(i -> i.hex()).join(".")}:${this.queue}';
}

private typedef IBlueprint = {
	var id:Int;
	var req:Array<Array<Int>>;
}

private abstract Blueprint(IBlueprint) from IBlueprint {
	static var pattern = ~/^Blueprint (\d+):\s+Each ore robot costs (\d+) ore\.\s+Each clay robot costs (\d+) ore\.\s+Each obsidian robot costs (\d+) ore and (\d+) clay\.\s+Each geode robot costs (\d+) ore and (\d+) obsidian\.$/;

	public var maxOres(get, never):Int;
	public var id(get, never):Int;

	public inline function new(id:Int, req:Array<Array<Int>>)
		this = {
			id: id,
			req: req
		};

	inline function get_id()
		return this.id;

	inline function get_maxOres()
		return max(Ore);

	public inline function spend(s:State, ore:OreType)
		for (x => ct in this.req[ore])
			s.ores[x] -= ct;

	public inline function max(ore:OreType) {
		var retval = 0;
		for (r in this.req)
			if (r[ore].or(0) > retval)
				retval = r[ore].or(0);
		return retval;
	}

	@:from
	public static function fromString(data:String) {
		if (pattern.match(data)) {
			var v = [for (x in 1...8) Std.parseInt(pattern.matched(x))];
			return new Blueprint(v[0], [[v[1], 0, 0, 0], [v[2], 0, 0, 0], [v[3], v[4], 0, 0], [v[5], 0, v[6], 0]]);
		} else
			throw 'Invalid blueprint definition: "$data"';
	}

	@:to
	public inline function toString()
		return
			'Blueprint $id: Each ore robot costs ${this.req[Ore][Ore]} ore. Each clay robot costs ${this.req[Clay][Ore]} ore. Each obsidian robot costs ${this.req[Obsidian][Ore]} ore and ${this.req[Obsidian][Clay]} clay. Each geode robot costs ${this.req[Geode][Ore]} ore and ${this.req[Geode][Obsidian]} obsidian.';

	public function canBuild(s:State) {
		var retval:Array<OreType> = [];
		for (x => type in this.req) {
			var can = true;
			for (y => ct in type)
				if (s.ores[y] < ct) {
					can = false;
					break;
				}
			if (can)
				retval.push(x);
		}
		retval.reverse();
		return retval;
	}

	public static function tri(x:Int) {
		if (x <= 0) return 0;

		var retval = 0;
		for (y in 1...x + 1) retval += y;
		return retval;
	}

	public function run(minutes:Int) {
		var mx = [for (x in 0...4) max(x)];
		var states:Array<State> = [
			{
				minutes: minutes,
				bots: [1, 0, 0, 0],
				ores: [0, 0, 0, 0]
			}
		];
		var cache = new Set<String>();
		var sortDelay = 0;

		var best:Null<Int> = 0;

		while (states.length > 0) {
			sortDelay++;
			if (sortDelay >= 50) {
				sortDelay = 0;
				ArraySort.sort(states, (lhs, rhs) -> {
					var botComp = rhs.botValue - lhs.botValue;
					return (botComp == 0) ? rhs.oreValue - lhs.oreValue : botComp;
				});
				trace(states.map(i -> '${i.minutes}:${i.botValue}:${i.oreValue}'));
			}

			var s = states.shift();
			while (s.minutes > 0) {
				// If we've decided to build, spend here
				if (s.queue != null)
					spend(s, s.queue);

				// Mine ore
				for (x => ct in s.bots)
					s.ores[x] += ct;

				// If we've decided to build, finish building and add the bot to the fleet
				if (s.queue != null) {
					s.bots[s.queue]++;
					s.queue = null;
				}

				// Minute tick
				s.minutes--;

				// if we've been here before, don't do any more work on this thread
				if (cache.exists(s))
					break;
				cache.add(s);

				// don't bother building anything else if we're on the last minute
				if (minutes > 0) {
					// assuming we'd end up building a geode bot every turn, whether or not that's possible,
					// if we can't beat the best score, don't bother to try
					if (best >= s.ores[Geode] + (s.bots[Geode] * s.minutes) + tri(s.minutes)) {
						trace('nope', s.ores[Geode] + (s.bots[Geode] * s.minutes) + tri(s.minutes), best, states.length);
						break;
					}

					// figure out what we can build with what we got
					var cb = canBuild(s);
					if (cb.length > 0) {
						for (type in cb) {
							// don't build the thing if we can already mine enough resource to build one per turn
							if (mx[type] <= s.bots[type])
								continue;
							var ns = s.clone();
							ns.queue = type;
	
							states.push(ns);
						}
						s.minutes = -1; // if we can build anything, then don't waste time building nothing
					}
				} else {
					trace('done: ${s.ores}');
					if (s.ores[Geode] > best) {
						best = s.ores[Geode];
						trace('New best: $best');
					}
				}
			}
		}
		trace(cache);

		return best;
	}
}

private enum abstract OreType(Int) from Int to Int {
	var Ore = 0;
	var Clay = 1;
	var Obsidian = 2;
	var Geode = 3;

	@:to
	public inline function toString()
		return switch (this) {
			case 0: "Ore";
			case 1: "Clay";
			case 2: "Obsidian";
			case 3: "Geode";
			case x: 'Unknown ($x)';
		}
}

class Day19 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [33]
			}
		});
		new Day19(data, 19, tests);
	}

	function problem1(data:String) {
		var list = data.rtrim().split("\n").map(Blueprint.fromString);
		for (b in list)
			trace(b.run(24));
		return null;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
