package y2022;

import haxe.ds.ArraySort;
import haxe.Json;

using StringTools;

var testData = [
	'[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
'
];

// typedef DistressData = Array<Int|DistressData>;
typedef IDataPair = {
	var first:Array<Dynamic>;
	var second:Array<Dynamic>;
}

@:forward
abstract DataPair(IDataPair) from IDataPair to IDataPair {
	public function new(first:Array<Dynamic>, second:Array<Dynamic>)
		this = {
			first: first,
			second: second
		};

	@:from
	public static function fromString(data:String) {
		var lines = data.split("\n");
		return new DataPair(Json.parse(lines[0]), Json.parse(lines[1]));
	}
}

class Day13 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [13, 140]
			}
		});
		new Day13(data, 13, tests, false);
	}

	function determineOrder(first:Array<Dynamic>, second:Array<Dynamic>) {
		// Pair 2: Compare [[1],[2,3,4]] vs [[1],4]
		var fc = first.slice(0), sc = second.slice(0);
		var fi:Dynamic, si:Dynamic;

		// if (debug != null) trace('P$debug: checking $fc vs $sc');
		while (fc.length > 0 && sc.length > 0) {
			fi = fc.shift();
			si = sc.shift();

			var firstIsNum = Std.isOfType(fi, Int),
				secondIsNum = Std.isOfType(si, Int);
			if (firstIsNum != secondIsNum) {
				// if (debug != null)
				// 	trace('P$debug: Type mismatch ($fi vs $si), converting ${firstIsNum ? "first" : "second"} item to array');
				if (firstIsNum)
					fi = [fi];
				else
					si = [si];
				firstIsNum = secondIsNum = false;
			}
			if (firstIsNum) {
				// if (debug != null)
				// 	trace('P$debug: Checking for $fi <=> $si');
				if (fi < si) {
					// if (debug != null)
					// 	trace('✅Check passed $fi < $si on pair $debug');
					return -1;
				} else if (fi > si) {
					// if (debug != null)
					// 	trace('❌Check failed $fi > $si on pair $debug');
					return 1;
				}
			} else {
				// if (debug != null)
				// 	trace('P$debug: Recursing determineOrder');
				switch (determineOrder(fi, si)) {
					case 0:
						// if (debug != null)
						// 	trace('P$debug: Recursive determineOrder was inconclusive, continuing');
					case x = 1 | -1:
						// if (debug != null)
						// 	trace('P$debug: Recursive determineOrder returned $x');
						return x;
				}
			}
		}

		// if (debug != null) {
		// 	if (fc.length > 0)
		// 		trace('❌First line did not run out first on pair $debug');
		// 	else if (sc.length > 0)
		// 		trace('✅First line ran out first on pair $debug');
		// 	else
		// 		trace('P$debug: Both lines ran out; check continues');
		// 	trace('P$debug: Returning ${fc.length == 0 ? (sc.length == 0 ? null : true) : false} at end of function');
		// }
		return fc.length == 0 ? (sc.length == 0 ? 0 : -1) : 1;
	}

	function problem1(data:String) {
		var pairs = data.rtrim().split("\n\n").map(DataPair.fromString);
		// trace(pairs);
		var correctOrder:Array<Int> = [];
		for (x => pair in pairs)
			if (determineOrder(pair.first, pair.second) != 1) {
				// trace('✅✅Valid pair on pair ${x + 1}');
				correctOrder.push(x + 1);
			}

		// trace(correctOrder);
		var retval = 0;
		for (order in correctOrder)
			retval += order;
		return retval;
	}

	function problem2(data:String) {
		var list:Array<Dynamic> = data.rtrim().split("\n").filter(i -> i.length > 0).map(Json.parse);
		var dividers = [[[2]], [[6]]];
		for (divider in dividers) list.push(divider);
		ArraySort.sort(list, determineOrder);
		//trace(Json.stringify(list.map(i -> Json.stringify(i)), null, "  "));
		return (list.indexOf(dividers[0]) + 1) * (list.indexOf(dividers[1]) + 1);
	}
}
