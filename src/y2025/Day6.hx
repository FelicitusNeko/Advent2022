package y2025;

import haxe.Int64;
import haxe.Int64Helper;

using StringTools;
using Safety;

private var testData = [
	'123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  
'
];

private typedef D6IOperation = {
	values:Array<Int>,
	isMult:Bool
};

@:follow
private abstract D6Operation(D6IOperation) from D6IOperation to D6IOperation {
	public function new(input:D6IOperation)
		this = input;

	public function solve() {
		var retval:Int64 = this.isMult ? 1 : 0;
		for (value in this.values) {
			// var parseval = Int64.ofInt(value);
			if (this.isMult)
				retval *= value;
			else
				retval += value;
		}
		return retval;
	}
}

class Day6 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [4277556, 3263827].map(Int64.ofInt)
			}
		});
		new Day6(data, 6, tests);
	}

	function parse(data:String, ?part2:Bool) {
		var retval:Array<D6Operation> = [];
		var lines = data.rtrim().split("\n");
		var pos = 0, max = 0;
		for (line in lines)
			if (line.length > max)
				max = line.length;
		var operators = lines.pop().sure();

		while (pos < max) {
			var nextpos = pos, values:Array<String> = [];
			while (++nextpos < max) {
				var ch = operators.charAt(nextpos);
				if (!(ch == "" || ch == " "))
					break;
			}
			if (nextpos >= max)
				nextpos = max + 1;

			for (x => line in lines)
				values.push(line.substring(pos, nextpos - 1));

			if (part2) {
				var p2vals:Array<String> = [for (_ in 0...(values[0].length)) ""];
				for (value in values)
					for (x => ch in value.split(""))
						p2vals[x] += ch;
				p2vals.reverse();
				values = p2vals;
			}
			retval.push({
				values: values.map(i -> Std.parseInt(i).sure()),
				isMult: operators.charAt(pos) == "*"
			});
			pos = nextpos;
		}
		if (part2)
			retval.reverse();
		return retval;
	}

	function problemCommon(data:String, part2:Bool) {
		var total:Int64 = 0;
		for (op in parse(data, part2))
			total += op.solve();
		return total;
	}

	function problem1(data:String)
		return problemCommon(data, false);

	function problem2(data:String)
		return problemCommon(data, true);
}
