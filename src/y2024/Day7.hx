package y2024;

import haxe.Int64;
import haxe.Int64Helper;

using StringTools;

private var testData = [
	'190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
'
];

class Day7 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [3749, 11387]
			}
		});
		new Day7(data, 7, tests);
	}

	function parse(data:String)
		return [
			for (line in data.rtrim().split("\n")) {
				var split = line.split(': ');
				{
					target: Int64Helper.parseString(split[0]),
					vals: split[1].split(" ").map(Int64Helper.parseString)
				};
			}
		];

	function problem1(data:String) {
		var list = parse(data);
		var retval:Int64 = 0;

		function recursiveMath(target:Int64, current:Int64, values:Array<Int64>) {
			if (values.length == 0)
				return target == current;
			for (op in 0...2) {
				var result = switch (op) {
					case 0: recursiveMath(target, current + values[0], values.slice(1));
					case 1: recursiveMath(target, current * values[0], values.slice(1));
					default: false;
				}
				if (result)
					return true;
			}
			return false;
		}

		for (entry in list)
			if (recursiveMath(entry.target, 0, entry.vals))
				retval += entry.target;

		if (Int64.neq(retval, 3749))
			trace(retval); // use the value this outputs as the solution
		return retval.low; // HACK: because Haxe hates Int64
	}

	function problem2(data:String) {
		var list = parse(data);
		var retval:Int64 = 0;

		function recursiveMath(target:Int64, current:Int64, values:Array<Int64>) {
			if (values.length == 0)
				return target == current;
			for (op in 0...3) {
				var result = switch (op) {
					case 0: recursiveMath(target, current + values[0], values.slice(1));
					case 1: recursiveMath(target, current * values[0], values.slice(1));
					case 2: recursiveMath(target, Int64Helper.parseString('$current${values[0]}'), values.slice(1));
					default: false;
				}
				if (result)
					return true;
			}
			return false;
		}

		for (x => entry in list) {
			trace(x);
			if (recursiveMath(entry.target, 0, entry.vals))
				retval += entry.target;
		}

		if (Int64.neq(retval, 11387))
			trace(retval); // use the value this outputs as the solution
		return retval.low; // HACK: because Haxe hates Int64
	}
}
