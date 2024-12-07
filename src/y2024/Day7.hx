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

	private static function recursiveMath(ops:Int, target:Int64, current:Int64, values:Array<Int64>) {
		if (values.length == 0)
			return target == current;
		for (op in 0...ops) {
			var result = switch (op) {
				case 0: recursiveMath(ops, target, current + values[0], values.slice(1));
				case 1: recursiveMath(ops, target, current * values[0], values.slice(1));
				case 2: recursiveMath(ops, target, Int64Helper.parseString('$current${values[0]}'), values.slice(1));
				default: false;
			}
			if (result)
				return true;
		}
		return false;
	}

	function problem(data:String, ops:Int, test:Int) {
		var list = [
			for (line in data.rtrim().split("\n")) {
				var split = line.split(': ');
				{
					target: Int64Helper.parseString(split[0]),
					vals: split[1].split(" ").map(Int64Helper.parseString)
				};
			}
		];
		var retval:Int64 = 0;

		for (entry in list)
			if (recursiveMath(ops, entry.target, 0, entry.vals))
				retval += entry.target;

		if (Int64.neq(retval, test))
			Sys.println('WORKAROUND: Use this response → $retval'); // use the value this outputs as the solution
		return retval.low; // HACK: because Haxe hates Int64
	}

	function problem1(data:String)
		return problem(data, 2, 3749);

	function problem2(data:String)
		return problem(data, 3, 11387);
}
