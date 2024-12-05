package y2024;

import haxe.ds.ArraySort;
import haxe.Exception;

using StringTools;
using Safety;

private var testData = [
	'47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47'
];

class Day5 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [143, 123]
			}
		});
		new Day5(data, 5, tests);
	}

	function problem(data:String, proc:(Array<Int>, Bool, Map<Int, Array<Int>>) -> Int) {
		var seg = data.rtrim().split("\n\n").map(i -> i.split("\n"));
		var rules:Map<Int, Array<Int>> = [];
		var sets = [for (line in seg[1]) line.split(",").map(Std.parseInt)];
		var retval = 0;

		for (line in seg[0]) {
			var nums = line.split("|").map(Std.parseInt);
			for (num in nums)
				if (num == null)
					throw new Exception('Invalid rule definition: $line');
			if (rules.exists(nums[0]))
				rules[nums[0]].push(nums[1]);
			else
				rules.set(nums[0], [nums[1]]);
		}

		for (line in sets) {
			var valid = true;
			var check:Array<Int> = [];

			for (num in line) {
				if (check.length > 0 && rules.exists(num))
					for (c in check)
						if (rules[num].contains(c)) {
							valid = false;
							break;
						}
				if (!valid)
					break;
				check.push(num);
			}

			retval += proc(line.slice(0), valid, rules);
		}

		return retval;
	}

	function problem1(data:String)
		return problem(data, (line, valid, _) -> valid ? line[Math.floor(line.length / 2)] : 0);

	function problem2(data:String)
		return problem(data, (line, valid, rules) -> {
			if (!valid) {
				ArraySort.sort(line, (l, r) -> {
					if (rules[l].or([]).contains(r))
						return -1;
					if (rules[r].or([]).contains(l))
						return 1;
					return 0;
				});
				return line[Math.floor(line.length / 2)];
			} else return 0;
		});
}
