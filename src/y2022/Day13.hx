package y2022;

import haxe.ds.ArraySort;
import haxe.Json;

using StringTools;

private var testData = [
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

private typedef IDataPair = {
	var first:Array<Dynamic>;
	var second:Array<Dynamic>;
}

@:forward
private abstract DataPair(IDataPair) from IDataPair to IDataPair {
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
		var fc = first.slice(0), sc = second.slice(0);
		var fi:Dynamic, si:Dynamic;

		while (fc.length > 0 && sc.length > 0) {
			fi = fc.shift();
			si = sc.shift();

			var firstIsNum = Std.isOfType(fi, Int),
				secondIsNum = Std.isOfType(si, Int);
			if (firstIsNum != secondIsNum) {
				if (firstIsNum)
					fi = [fi];
				else
					si = [si];
				firstIsNum = secondIsNum = false;
			}
			if (firstIsNum) {
				if (fi < si)
					return -1;
				else if (fi > si)
					return 1;
			} else
				switch (determineOrder(fi, si)) {
					case 0:
					case x = 1 | -1:
						return x;
				}
		}

		return fc.length == 0 ? (sc.length == 0 ? 0 : -1) : 1;
	}

	function problem1(data:String) {
		var pairs = data.rtrim().split("\n\n").map(DataPair.fromString);
		var correctOrder:Array<Int> = [];
		for (x => pair in pairs)
			if (determineOrder(pair.first, pair.second) != 1) {
				correctOrder.push(x + 1);
			}

		var retval = 0;
		for (order in correctOrder)
			retval += order;
		return retval;
	}

	function problem2(data:String) {
		var list:Array<Dynamic> = data.rtrim().split("\n").filter(i -> i.length > 0).map(Json.parse);
		var dividers = [[[2]], [[6]]];
		for (divider in dividers)
			list.push(divider);
		ArraySort.sort(list, determineOrder);
		return (list.indexOf(dividers[0]) + 1) * (list.indexOf(dividers[1]) + 1);
	}
}
