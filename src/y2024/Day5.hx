package y2024;

import haxe.Exception;

using StringTools;

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
				expected: [143]
			}
		});
		new Day5(data, 5, tests);
	}

	function parse(data:String) {
		var seg = data.rtrim().split("\n\n").map(i -> i.split("\n"));
		var rules:Map<Int, Array<Int>> = [];
		var sets = [for (line in seg[1]) line.split(",").map(Std.parseInt)];

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

		return {rules: rules, sets: sets};
	}

	function problem1(data:String) {
		var p = parse(data);
		var retval = 0;

		for (line in p.sets) {
			var valid = true;
			var check:Array<Int> = [];

			for (num in line) {
				if (check.length > 0 && p.rules.exists(num))
					for (c in check)
						if (p.rules[num].contains(c)) {
							valid = false;
							break;
						}
				if (!valid)
					break;
				check.push(num);
			}

			if (valid) 
				retval += line[Math.floor(line.length / 2)];
		}

		return retval;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
