package y2022;

import haxe.io.Bytes;
import haxe.crypto.Crc32;
import haxe.Serializer;
import haxe.ds.HashMap;

using StringTools;
using Safety;
using utils.ArrayTools;

private var testData = [
	'Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.'
];

private typedef IBlueprint = {
	var id:Int;
	var orebot:Int;
	var claybot:Int;
	var obsbot:{
		var ore:Int;
		var clay:Int;
	};
	var geobot:{
		var ore:Int;
		var obs:Int;
	};
}

@:forward
private abstract Blueprint(IBlueprint) from IBlueprint {
	static var pattern = ~/^Blueprint (\d+): Each ore robot costs (\d+) ore\.\s+Each clay robot costs (\d+) ore\.\s+Each obsidian robot costs (\d+) ore and (\d+) clay\.\s+Each geode robot costs (\d+) ore and (\d+) obsidian\.$/;

	public inline function new(id:Int, orebot:Int, claybot:Int, obsbotOre:Int, obsbotClay:Int, geobotOre:Int, geobotObs:Int)
		this = {
			id: id,
			orebot: orebot,
			claybot: claybot,
			obsbot: {
				ore: obsbotOre,
				clay: obsbotClay
			},
			geobot: {
				ore: geobotOre,
				obs: geobotObs
			}
		};

	@:from
	public static function fromString(data:String) {
		if (pattern.match(data)) {
			var match = [for (x in 1...8) pattern.matched(x)].map(Std.parseInt);
			return new Blueprint(match[0], match[1], match[2], match[3], match[4], match[5], match[6]);
		} else
			throw 'Invalid blueprint definition:\n$data';
	}

	@:to
	public function toString()
		return 'Blueprint ${this.id}: Each ore robot costs ${this.orebot} ore. Each clay robot costs ${this.claybot} clay. '
			+
			'Each obsidian robot costs ${this.obsbot.ore} ore and ${this.obsbot.clay} clay. Each geode robot costs ${this.geobot.ore} ore and ${this.geobot.obs} obsidian.';

	public function canBuild(bot:OreType, s:FactoryState)
		return switch (bot) {
			case Ore: s.resources[Ore] >= this.orebot;
			case Clay: s.resources[Ore] >= this.claybot;
			case Obsidian: s.resources[Ore] >= this.obsbot.ore && s.resources[Clay] >= this.obsbot.clay;
			case Geode: s.resources[Ore] >= this.geobot.ore && s.resources[Obsidian] >= this.geobot.obs;
			case x: throw 'Invalid ore type $x';
		}

	public function spend(bot:OreType, s:FactoryState)
		if (canBuild(bot, s))
			switch (bot) {
				case Ore:
					s.resources[Ore] -= this.orebot;
				case Clay:
					s.resources[Ore] -= this.claybot;
				case Obsidian:
					s.resources[Ore] -= this.obsbot.ore;
					s.resources[Clay] -= this.obsbot.clay;
				case Geode:
					s.resources[Ore] -= this.geobot.ore;
					s.resources[Obsidian] -= this.geobot.obs;
				case x:
					throw 'Invalid ore type $x';
			}
}

private enum abstract OreType(Int) from Int to Int {
	var Ore = 0;
	var Clay;
	var Obsidian;
	var Geode;

	@:to
	public inline function toString()
		return switch (this) {
			case 0: "Ore";
			case 1: "Clay";
			case 2: "Obsidian";
			case 3: "Geode";
			case x: 'Unknown ($x)';
		};
}

@:structInit
private class FactoryState {
	public var minutes:Int;
	public var bots:Array<Int>;
	public var resources:Array<Int>;
	public var queue:Null<OreType>;

	public function new(minutes:Int, bots:Array<Int>, resources:Array<Int>, ?queue:OreType) {
		this.minutes = minutes;
		this.bots = bots.slice(0);
		this.resources = resources.slice(0);
		this.queue = queue;
	}

	public function clone(?queue:OreType)
		return new FactoryState(minutes, bots.slice(0), resources.slice(0), queue.or(this.queue));

	public function hashCode() {
		var s = new Serializer();
		s.serialize(minutes);
		s.serialize(bots);
		s.serialize(resources);
		s.serialize(queue);
		return Crc32.make(Bytes.ofString(s.toString()));
	}
}

private class RobotFactory {
	var blueprints:Array<Blueprint>;

	public var blueprintIndex(default, set):Int;
	public var blueprintId(get, set):Int;
	public var blueprintCount(get, never):Int;

	var curBlueprint(get, never):Blueprint;

	var cache = new HashMap<FactoryState, Int>();

	public function new(data:String) {
		blueprints = data.rtrim().split("\n").map(i -> Blueprint.fromString(i));
		blueprintIndex = 0;
		for (b in blueprints)
			trace(b);
	}

	inline function set_blueprintIndex(blueprintIndex:Int) {
		if (blueprintIndex < 0 || blueprintIndex >= blueprintCount)
			throw 'Blueprint index out of range';
		return this.blueprintIndex = blueprintIndex;
	}

	inline function get_blueprintId() {
		if (blueprints[blueprintIndex] == null)
			throw 'Invalid blueprint selected (probably out of range)';
		return blueprints[blueprintIndex].id;
	}

	function set_blueprintId(useBlueprint:Int) {
		for (x => blueprint in blueprints)
			if (blueprint.id == useBlueprint) {
				blueprintIndex = x;
				return blueprint.id;
			}
		throw 'Blueprint id $useBlueprint not found';
	}

	inline function get_blueprintCount()
		return blueprints.length;

	inline function get_curBlueprint()
		return blueprints[blueprintIndex];

	public function runSimOld(minutes:Int) {
		var states:Array<FactoryState> = [
			{
				minutes: 0,
				bots: [1, 0, 0, 0],
				resources: [0, 0, 0, 0]
			}
		];
		var max = 0;

		while (states.length > 0) {
			var s = states.shift();

			while (s.minutes < minutes) {
				if (s.queue == null) {
					if (s.resources[Ore] >= curBlueprint.geobot.ore && s.resources[Obsidian] >= curBlueprint.geobot.obs)
						states.push(s.clone(Geode));
					if (s.resources[Ore] >= curBlueprint.obsbot.ore && s.resources[Clay] >= curBlueprint.obsbot.clay)
						states.push(s.clone(Obsidian));
					if (s.resources[Ore] >= curBlueprint.claybot)
						states.push(s.clone(Clay));
					if (s.resources[Ore] >= curBlueprint.orebot)
						states.push(s.clone(Ore));
				} else
					switch (s.queue) {
						case Geode:
							s.resources[Ore] -= curBlueprint.geobot.ore;
							s.resources[Obsidian] -= curBlueprint.geobot.obs;
						case Obsidian:
							s.resources[Ore] -= curBlueprint.obsbot.ore;
							s.resources[Obsidian] -= curBlueprint.obsbot.clay;
						case Clay:
							s.resources[Ore] -= curBlueprint.claybot;
						case Ore:
							s.resources[Ore] -= curBlueprint.orebot;
						case x:
							throw 'Unknown ore type $x';
					}

				for (x => count in s.bots)
					s.resources[x] += count;

				if (s.queue != null) {
					s.bots[s.queue]++;
					s.queue = null;
				}

				s.minutes++;
			}

			var geode = s.resources[Geode];
			if (max < geode)
				max = geode;
		}

		return max;
	}

	function runState(s:FactoryState, cache:HashMap<FactoryState, Int>, minutes:Int) {
		if (s.minutes == minutes)
			return s.resources[Geode];

		var maxOre = [
			curBlueprint.orebot,
			curBlueprint.claybot,
			curBlueprint.obsbot.ore,
			curBlueprint.geobot.ore
		].reduce((r, i) -> r > i ? r : i);
		if (s.queue == Ore
			&& s.resources[Ore] >= maxOre
			|| s.queue == Clay
			&& s.resources[Clay] >= curBlueprint.obsbot.clay
			|| s.queue == Obsidian
			&& (s.resources[Obsidian] >= curBlueprint.geobot.obs || s.resources[Clay] == 0)
			|| s.queue == Geode
			&& s.resources[Obsidian] == 0)
			return 0;

		if (cache.exists(s))
			return cache[s];

		var max = 0;
		while (s.minutes < minutes) {
			if (s.queue == Ore && s.resources[Ore] >= curBlueprint.orebot) {
				var tmpMax = 0;
				// for (newGoal)
			}
		}

		return 0;
	}

	public function runSim(cache:HashMap<FactoryState, Int>, minutes:Int) {
		return 0;
	}
}

class Day19_2 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [33]
			}
		});
		new Day19_2(data, 19, tests, true);
	}

	function problem1(data:String) {
		var factory = new RobotFactory(data);
		return null;
		var total = 0;
		var cache = new HashMap<FactoryState, Int>();

		for (b in 0...factory.blueprintCount) {
			factory.blueprintIndex = b;
			total += factory.runSim(cache, 24) * factory.blueprintId;
		}
		return total;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
