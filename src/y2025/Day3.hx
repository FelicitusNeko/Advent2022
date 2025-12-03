package y2025;

import haxe.Int64Helper;
import haxe.Int64;

using StringTools;

private var testData = [
	'987654321111111
811111111111119
234234234234278
818181911112111
'
];

class Day3 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [Int64.ofInt(357), Int64Helper.parseString('3121910778619')]
			}
		});
		new Day3(data, 3, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(i -> i.split('').map(Std.parseInt));

	function problemCommon(data:String, length:Int) {
		// NOTE: this takes ~5:40 in HL on my computer for length 12
		var list = parse(data);
		var total:Int64 = 0;

		for (line in list) {
			var best:Array<Int> = [for (_ in 0...length) 0];
			function scan(slice:Array<Null<Int>>, index:Int) {
				if (index >= length) {
					trace('index $index exceeds length $length, aborting');
					return;
				}

				var end:Null<Int> = index - length + 1;
				if (end == 0)
					end = null;
				for (ix => x in slice.slice(0, end)) {
					if (x > best[index]) {
						best[index] = x;
						for (z in index + 1...length)
							best[z] = 0;
					}
					if (x == best[index] && index + 1 < length)
						scan(slice.slice(ix + 1), index + 1);
				}
			}
			scan(line, 0);
			total += Int64Helper.parseString(best.join(''));
		}
		return total;
	}

	function problem1(data:String)
		return problemCommon(data, 2);

	function problem2(data:String)
		return problemCommon(data, 12);
}
