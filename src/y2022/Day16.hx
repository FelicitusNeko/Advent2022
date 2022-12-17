package y2022;

using StringTools;
using Safety;

var testData = [
	'Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
'
];

typedef IValveNode = {
	var id:String;
	var flowRate:Int;
	var exits:Array<ValveNode>;
}

abstract ValveNode(IValveNode) from IValveNode {
	public var id(get, never):String;
	public var flowRate(get, set):Int;
	public var exits(get, never):Array<ValveNode>;

	inline function get_id()
		return this.id;

	inline function get_flowRate()
		return this.flowRate;

	inline function set_flowRate(flowRate:Int) {
		if (this.flowRate < 0)
			this.flowRate = flowRate;
		return this.flowRate;
	}

	inline function get_exits()
		return this.exits.slice(0);

	public inline function addExit(...exits:ValveNode)
		for (exit in exits)
			this.exits.push(exit);

	public function clone():IValveNode {
		return {
			id: this.id,
			flowRate: this.flowRate,
			exits: this.exits.slice(0)
		};
	}

	@:to
	public inline function toString()
		return
			'Valve ${this.id} has flow rate=${this.flowRate}; ${this.exits.length == 1 ? "tunnel leads to valve" : "tunnels lead to valves"} ${this.exits.map(i -> i.id).join(", ")}';

	public function pathTo(dest:ValveNode) {
		if (dest == this)
			return [];

		var bestDist:Map<String, Int> = [];

		var queue:Array<ValveNode> = [this];
		bestDist[this.id] = 0;

		while (queue.length > 0) {
			var source = queue.shift();
			for (dest in source.exits) {
				if (bestDist[dest.id] == null)
					queue.push(dest);
				bestDist[dest.id] = Math.round(Math.min(bestDist[dest.id].or(999), bestDist[source.id] + 1));
			}
		}

		var move:Array<ValveNode> = [];
		var pathBack = dest;
		while (pathBack.id != this.id) {
			move.unshift(pathBack);
			for (exit in pathBack.exits) {
				if (bestDist[exit.id] == bestDist[pathBack.id] - 1) {
					pathBack = exit;
					break;
				}
			}
			if (pathBack == move[0])
				throw 'Backstep node not found from ${pathBack.id} toward ${this.id}';
		}

		return move;
	}

	public function pathFrom(start:ValveNode)
		return start.pathTo(this);
}

enum IValveMove {
	NoOp;
	MoveTo(node:ValveNode);
	Open(node:ValveNode);
}

abstract ValveMove(IValveMove) from IValveMove {
	@:to
	public function toString()
		return switch (this) {
			case NoOp: "Time passes";
			case MoveTo(node): 'Move to ${node.id}';
			case Open(node): 'Open ${node.id}';
		}
}

typedef ValveRules = {
	var maxMoves:Int;
	var costPerMove:Int;
	var costPerOpen:Int;
	var nodes:Array<ValveNode>;
	var startPos:ValveNode;
	var players:Int;
}

typedef ValvePlayer = {
	var curPos:ValveNode;
	var moves:Array<ValveMove>;
	var queue:Array<ValveMove>;
}

typedef IValveState = {
	var players:Array<ValvePlayer>;
	var valvesOn:Array<ValveNode>;
	var total:Int;
	var destQueue:Array<ValveNode>;
}

enum ValveMoveResult {
	Good(moveCount:Int);
	NeedInput(player:Int);
}

abstract ValveState(IValveState) from IValveState {
	public var valvesOn(get, never):Array<ValveNode>;
	public var total(get, never):Int;
	public var destQueue(get, never):Array<ValveNode>;

	public var ratePerMove(get, never):Int;
	public var moveCount(get, never):Int;

	inline function get_valvesOn()
		return this.valvesOn.slice(0);

	inline function get_total()
		return this.total;

	inline function get_destQueue()
		return this.destQueue.slice(0);

	inline function get_ratePerMove() {
		var retval = 0;
		for (valve in this.valvesOn)
			retval += valve.flowRate;
		return retval;
	}

	inline function get_moveCount()
		return this.players[0].moves.length;

	public function setDest(player:Int, dest:ValveNode, rules:ValveRules, ?cache:Map<String, Array<ValveNode>>) {
		if (player < 0 || player > this.players.length - 1)
			throw 'Player $player out of range 0-${this.players.length - 1}';
		if (!this.destQueue.contains(dest))
			throw 'Invalid destination ${dest.id}';

		var p = this.players[player];
		var moveDef = '${p.curPos.id}:${dest.id}';
		var trajectory = cache.or([])[moveDef].or(dest.pathFrom(p.curPos));
		if (cache != null && !cache.exists(moveDef))
			cache[moveDef] = trajectory;
		p.queue = [];
		for (move in trajectory)
			p.queue.push(MoveTo(move));
		p.queue.push(Open(dest));
		while (p.moves.length + p.queue.length > rules.maxMoves)
			if (p.queue.pop() == null)
				throw 'Unable to pop from queue'; // this shouldn't happen
		this.destQueue = this.destQueue.filter(i -> i != dest);
	}

	public function makeMove() {
		for (x => player in this.players)
			if (player.queue.length == 0)
				return NeedInput(x);
		this.total += ratePerMove;
		for (player in this.players) {
			var move = player.queue.shift();
			switch (move) {
				case Open(node):
					if (this.valvesOn.contains(node))
						throw 'Trying to open already open node';
					this.valvesOn.push(node);
				case MoveTo(node):
					player.curPos = node;
				default:
			}
			player.moves.push(move);
		}
		return Good(moveCount);
	}

	public function stallOut(max:Int) {
		while (moveCount < max)
			switch makeMove() {
				case NeedInput(player):
					this.players[player].queue.push(NoOp);
				case Good(_):
			}
	}

	public function clone():IValveState {
		var retval:IValveState = {
			players: [],
			valvesOn: valvesOn,
			total: total,
			destQueue: destQueue,
		};
		for (player in this.players)
			retval.players.push({
				curPos: player.curPos,
				moves: player.moves.slice(0),
				queue: player.queue.slice(0)
			});

		return retval;
	}
}

class Day16 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [1651, 1707]
			}
		});
		new Day16(data, 16, tests);
	}

	function buildMap(data:String) {
		var nodes:Map<String, ValveNode> = [];
		var pattern = ~/^Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/;

		function getOrMakeNode(id:String, flowRate = -1):ValveNode {
			var newNode:ValveNode = nodes[id].or({
				id: id,
				flowRate: flowRate,
				exits: []
			});
			newNode.flowRate = flowRate;
			return nodes[id] = newNode;
		}

		for (line in data.rtrim().split("\n"))
			if (pattern.match(line)) {
				var newNode = getOrMakeNode(pattern.matched(1), Std.parseInt(pattern.matched(2)));
				for (exit in pattern.matched(3).split(", "))
					newNode.addExit(getOrMakeNode(exit));
			} else
				throw 'Invalid node description "$line"';

		var nodeArray = [for (_ => node in nodes) node];
		nodeArray.reverse();
		// trace(nodeArray.map(i -> i.toString()).join("\n"));
		return {
			startNode: nodes["AA"],
			nodes: nodeArray
		};
	}

	function planJourney(rules:ValveRules) {
		var valueNodes = rules.nodes.filter(i -> i.flowRate > 0);
		var states:Array<ValveState> = [
			{
				players: [
					for (_ in 0...rules.players)
						{
							curPos: rules.startPos,
							moves: [],
							queue: []
						}
				],
				valvesOn: [],
				total: 0,
				destQueue: valueNodes.slice(0)
			}
		];
		var best:Null<ValveState> = null;
		var moveCache:Map<String, Array<ValveNode>> = [];

		while (states.length > 0) {
			var state = states.shift();
			while (state.moveCount < rules.maxMoves)
				switch (state.makeMove()) {
					case NeedInput(player):
						for (dest in state.destQueue) {
							var newState:ValveState = state.clone();
							newState.setDest(player, dest, rules, moveCache);
							states.unshift(newState);
						}

						state.stallOut(rules.maxMoves);
						if (best == null || (state.moveCount >= rules.maxMoves && state.total > best.total))
							best = state;
					case Good(_):
				}
		}
		return best;
	}

	function problem1(data:String) {
		var parsed = buildMap(data);
		var best = planJourney({
			maxMoves: 30,
			costPerMove: 1,
			costPerOpen: 1,
			nodes: parsed.nodes,
			startPos: parsed.startNode,
			players: 1
		});

		return cast(best == null ? null : best.total);
	}

	function problem2(data:String) {
		var parsed = buildMap(data);
		var best = planJourney({
			maxMoves: 26,
			costPerMove: 1,
			costPerOpen: 1,
			nodes: parsed.nodes,
			startPos: parsed.startNode,
			players: 2
		});

		return cast(best == null ? null : best.total);
	}
}
