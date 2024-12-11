package y2024;

import haxe.Int64;
import haxe.Int64Helper;

using StringTools;

private var testData = ['125 17'];

private enum ValueType {
	Value(i:Int64);
	NilPattern(i:Int);
}

class Day11 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [55312]
			}
		});
		new Day11(data, 11, tests);
	}

	function problem(data:String, iterations:Int) {
		// this program implodes for part 2
		// TODO: keep patterns for every digit 0-9

		var list = data.rtrim().split(" ").map(i -> switch (i) {
			case "0": NilPattern(0);
			case "1": NilPattern(1);
			case "2024": NilPattern(2);
			default: Value(Int64Helper.parseString(i));
		});
		var nilPattern:Array<ValueType> = [Value(2), NilPattern(0), Value(2), Value(4)];
		var nilPatternLengths = [1, 1, 1, 2, 4];

		function iterate(list:Array<ValueType>) {
			list.reverse();
			var retval:Array<ValueType> = [];
			while (list.length > 0) {
				var item = list.pop();
				switch (item) {
					case Value(i):
						var str = Std.string(i);
						if (str.length % 2 == 0) {
							var halflen = str.length >> 1;
							for (i in [str.substring(0, halflen), str.substring(halflen)].map(Int64Helper.parseString))
								retval.push(switch (i) {
									case 0: NilPattern(0);
									case 1: NilPattern(1);
									case 2024: NilPattern(2);
									default: Value(i);
								});
						} else
							retval.push(Value(i * 2024));
					case NilPattern(i):
						retval.push(NilPattern(i + 1));
				}
			}
			return retval;
		}

		function countLength(list:Array<ValueType>) {
			var retval = 0;
			for (item in list) {
				retval += switch (item) {
					case Value(_): 1;
					case NilPattern(i):
						while (i >= nilPatternLengths.length) {
							nilPattern = iterate(nilPattern);
							nilPatternLengths.push(countLength(nilPattern));
						}
						nilPatternLengths[i];
				};
			}
			return retval;
		}

		for (_ in 0...iterations) {
			list = iterate(list);
		}

		return countLength(list);
	}

	function problem1(data:String)
		return problem(data, 25);

	function problem2(data:String)
		return problem(data, 75);
}
