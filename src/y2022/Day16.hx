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
			if (pathBack == move[0]) throw 'Backstep node not found from ${pathBack.id} toward ${this.id}';
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
	var dest:Null<ValveNode>;
}

typedef IValveState = {
	var moves:Array<ValveMove>;
	var valvesOn:Array<ValveNode>;
	var curPos:ValveNode;
	var total:Int;
	var destQueue:Array<ValveNode>;
	var ?parent:ValveState;
}

abstract ValveState(IValveState) from IValveState {
	public var moves(get, never):Array<ValveMove>;
	public var valvesOn(get, never):Array<ValveNode>;
	public var curPos(get, never):ValveNode;
	public var total(get, never):Int;
	public var destQueue(get, never):Array<ValveNode>;
	public var parent(get, never):Null<ValveState>; // if I even need this

	public var ratePerMove(get, never):Int;
	public var moveCount(get, never):Int;

	inline function get_moves()
		return this.moves.slice(0);

	inline function get_valvesOn()
		return this.valvesOn.slice(0);

	inline function get_curPos()
		return this.curPos;

	inline function get_total()
		return this.total;

	inline function get_destQueue()
		return this.destQueue.slice(0);

	inline function get_parent()
		return this.parent;

	inline function get_ratePerMove() {
		var retval = 0;
		for (valve in this.valvesOn)
			retval += valve.flowRate;
		return retval;
	}

	inline function get_moveCount()
		return this.moves.length;

	public inline function getNextDest()
		return this.destQueue.shift();

	public inline function addMove(move:ValveMove, max:Int) {
		if (moveCount >= max)
			return false;
		this.moves.push(move);
		this.total += ratePerMove;
		switch (move) {
			case Open(node):
				this.destQueue = this.destQueue.filter(i -> i != node);
				this.valvesOn.push(node);
			case MoveTo(node):
				this.curPos = node;
			default:
		}
		return true;
	}

	public function clone(?parent:ValveState):IValveState {
		return {
			moves: moves,
			valvesOn: valvesOn,
			curPos: curPos,
			total: total,
			destQueue: destQueue,
			parent: parent.or(this)
		};
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
		new Day16(data, 16, tests, true);
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
		//trace(nodeArray.map(i -> i.toString()).join("\n"));
		return {
			startNode: nodes["AA"],
			nodes: nodeArray
		};
	}

	function planJourney(rules:ValveRules) {
		var valueNodes = rules.nodes.filter(i -> i.flowRate > 0);
		var states:Array<ValveState> = [
			{
				moves: [],
				valvesOn: [],
				curPos: rules.startPos,
				total: 0,
				destQueue: valueNodes.slice(0)
			}
		];
		var best:Null<ValveState> = null;
		var moveCache:Map<String, Array<ValveNode>> = [];

		while (states.length > 0) {
			var state = states.shift();
			for (dest in state.destQueue) {
				var move = moveCache['${state.curPos.id}:${dest.id}'].or(dest.pathFrom(state.curPos));
				moveCache['${state.curPos.id}:${dest.id}'] = move;

				var newState:ValveState = state.clone();

				for (node in move) {
					for (_ in 1...rules.costPerMove)
						newState.addMove(NoOp, rules.maxMoves);
					newState.addMove(MoveTo(node), rules.maxMoves);
				}
				for (_ in 1...rules.costPerOpen)
					newState.addMove(NoOp, rules.maxMoves);
				newState.addMove(Open(dest), rules.maxMoves);

				if (rules.maxMoves <= newState.moveCount) {
					if (best == null || newState.total > best.total)
						best = newState;
				} else
					states.unshift(newState);

			}

			while (state.addMove(NoOp, rules.maxMoves)) {};
			if (best == null || (state.moveCount >= rules.maxMoves && state.total > best.total))
				best = state;
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
		var list = data.rtrim().split("\n");
		return null;
	}
}
