package y2022;

using StringTools;

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
	var isOpen:Bool;
	var exits:Array<ValveNode>;
	var bestDist:Null<Int>;
	var bestRelease:Null<Int>;
}

@:forward
abstract ValveNode(IValveNode) from IValveNode {
	@:to
	public inline function toString()
		return
			'Valve ${this.id} has flow rate=${this.flowRate}; ${this.exits.length == 1 ? "tunnel leads to valve" : "tunnels lead to valves"} ${this.exits.map(i -> i.id).join(", ")}';
}

class Day16 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [1651]
			}
		});
		new Day16(data, 16, tests, true);
	}

	function buildMap(data:String) {
		var nodes:Map<String, ValveNode> = [];
		var pattern = ~/^Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/;

		function getOrMakeNode(id:String, flowRate = -1) {
			var newNode:ValveNode = nodes.exists(id) ? nodes[id] : {
				id: id,
				flowRate: flowRate,
				isOpen: false,
				exits: [],
				bestDist: null,
				bestRelease: null
			};
			if (!nodes.exists(id))
				nodes[id] = newNode;
			else if (newNode.flowRate < 0)
				newNode.flowRate = flowRate;
			return newNode;
		}

		for (line in data.rtrim().split("\n"))
			if (pattern.match(line)) {
				var newNode = getOrMakeNode(pattern.matched(1), Std.parseInt(pattern.matched(2)));
				for (exit in pattern.matched(3).split(", "))
					newNode.exits.push(getOrMakeNode(exit));
			} else
				throw 'Invalid node description "$line"';

		// trace([for (_ => node in nodes) node].map(i -> i.toString()).join("\n"));
		var nodeArray = [for (_ => node in nodes) node];
		nodeArray.reverse();
		return {
			startNode: nodes["AA"],
			nodes: nodeArray
		};
	}

	function findBestMove(curMove:Int, curNode:ValveNode, nodes:Array<ValveNode>):Array<ValveNode> {
		var anyNodesLeft = false;
		for (node in nodes) {
			node.bestDist = null;
			node.bestRelease = null;
			anyNodesLeft = anyNodesLeft || (!node.isOpen && node.flowRate > 0);
		}
		if (!anyNodesLeft) {
			//trace("No nodes have any value left at all");
			return [];
		}

		var queue = [curNode];
		curNode.bestDist = 0;

		while (queue.length > 0) {
			var testNode = queue.shift();
			for (node in testNode.exits) {
				if (node.bestDist == null)
					queue.push(node);
				if (node.bestDist == null || node.bestDist > testNode.bestDist + 1)
					node.bestDist = testNode.bestDist + 1;
			}
		}
		for (node in nodes) {
			if (node.isOpen)
				continue;
			var eta = curMove + node.bestDist;
			if (eta < 29)
				node.bestRelease = node.flowRate * (29 - eta);
		}

		// for (node in nodes) {
		// 	if (node.bestRelease != null && node.bestRelease > 0)
		// 		Sys.println('Node ${node.id} (flow ${node.flowRate}) takes ${node.bestDist} move(s) to reach and could release ${node.bestRelease} pressure');
		// }

		var anyValueLeft = false;
		for (node in nodes)
			anyValueLeft = anyValueLeft || (node.bestRelease != null && node.bestRelease > 0);
		if (!anyValueLeft) {
			//trace("No nodes have any achievable value left that we can get to in time");
			return [];
		}

		var dest = curNode;
		for (node in nodes) 
			if ((dest.bestRelease == null && node.bestRelease != null) || (!node.isOpen && node.bestRelease > dest.bestRelease))
				dest = node;
		
		if (dest == curNode) {
			//trace("Path is leading back to same node (this is probably an error)");
			return [];
		}

		var move:Array<ValveNode> = [dest];
		var pathBack = dest;
		while (pathBack != curNode)
			for (node in pathBack.exits)
				if (node.bestDist == pathBack.bestDist - 1) {
					pathBack = node;
					if (node != curNode)
						move.unshift(node);
					break;
				}

		//Sys.println('Our move will be: ${move.map(i -> i.id).join(", ")}');
		return move;
	}

	function problem1(data:String) {
		var parsed = buildMap(data);
		var curNode = parsed.startNode, nodes = parsed.nodes;

		var curMove:Array<ValveNode> = [];
		var isMoving = false;
		var total = 0;
		var ratePerMinute = 0;
		var doneMoving = false;

		for (x in 0...30) {
			// Sys.println('== Minute ${x + 1} ==');
			// if (ratePerMinute == 0)
			// 	Sys.println('No valves are open.');
			// else
			// 	Sys.println('Open valves release $ratePerMinute pressure.');
			total += ratePerMinute;

			if (!doneMoving) {
				if (!isMoving) {
					curMove = findBestMove(x, curNode, nodes);
					isMoving = curMove.length > 0;
					doneMoving = !isMoving;
					// if (doneMoving)
					// 	Sys.println("There are no more moves worth making.");
				}
				if (isMoving) {
					if (curMove.length == 0) {
						if (curNode.isOpen)
							throw 'Trying to open already opened node ${curNode.id}';
						curNode.isOpen = true;
						ratePerMinute += curNode.flowRate;
						isMoving = false;
						//Sys.println('You open valve ${curNode.id}.');
					} else {
						curNode = curMove.shift();
						//Sys.println('You move to valve ${curNode.id}.');
					}
				}
			}

			//Sys.println("");
		}

		return total;
		// 1461 too low
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
