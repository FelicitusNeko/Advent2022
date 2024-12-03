package y2024;

import haxe.ds.ArraySort;

using StringTools;

private var testData = [
	'3   4
4   3
2   5
1   3
3   9
3   3
'
];

class Day1 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [11, 31]
			}
		});
		new Day1(data, 1, tests);
	}

	function parse(data:String) {
		var left:Array<Int> = [], right:Array<Int> = [];
		for (line in data.rtrim().split("\n").map(i -> i.split("   "))) {
			left.push(Std.parseInt(line[0]));
			right.push(Std.parseInt(line[1]));
		}

		ArraySort.sort(left, (l, r) -> l - r);
		ArraySort.sort(right, (l, r) -> l - r);
		return [left, right];
	}

	function problem1(data:String) {
		var nums = parse(data);
		var retval = 0;
		for (i in 0...nums[0].length)
			retval += Math.round(Math.abs(nums[0][i] - nums[1][i]));
		return retval;
	}

	function problem2(data:String) {
		var nums = parse(data);
		var similar:Map<Int, Int> = [];
		var retval = 0;

		for (i in nums[1]) {
			if (similar.exists(i))
				similar[i]++;
			else
				similar.set(i, 1);
		}
		for (i in nums[0]) {
			if (similar.exists(i))
				retval += i * similar[i];
		}

		return retval;
	}
}
