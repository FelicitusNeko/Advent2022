package y2024;

import haxe.DynamicAccess;
import haxe.Exception;
import haxe.Json;
import haxe.ds.ArraySort;
import sys.io.File;

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

		// build the rule set based on the first part of the data
		for (line in seg[0]) {
			var nums = line.split("|").map(Std.parseInt);
			for (num in nums)
				if (num == null)
					throw new Exception('Invalid rule definition: $line');
			if (rules.exists(nums[0]))
				rules[nums[0]].push(nums[1]);
			else
				rules.set(nums[0], [nums[1]]);
			if (!rules.exists(nums[1])) // so that every mentioned page number is added to the keys
				rules.set(nums[1], []);
		}

		// assert that the number of rules matches the puzzle input
		var ruleCount = 0;
		for (v in rules)
			ruleCount += v.length;
		if (ruleCount != seg[0].length)
			throw new Exception('Not all rules accounted for (expected ${seg[0].length}, got $ruleCount)');

		// create a master list of page numbers
		var masterList = [for (k in rules.keys()) k]; // and that's why we add blank arrays

		// sort the master list based on the rule set
		ArraySort.sort(masterList, (l, r) -> {
			if (rules[l].contains(r))
				return -1;
			if (rules[r].contains(l))
				return 1;
			return 0;
		});

		// assert that every possible page order is accounted for
		var otherlist:Map<Int, Bool> = [];
		var worklist = [masterList[0]]; // this is done after sorting the list so that (theoretically) the first page processed has the most rules and should touch as many pages as possible
		while (worklist.length > 0) {
			var num = worklist.shift();
			if (num == null || !rules.exists(num))
				continue;
			otherlist.set(num, true);
			for (x in rules[num])
				if (!otherlist.exists(x))
					worklist.push(x);
		}
		var otherlistdone = [for (k in otherlist.keys()) k];
		if (masterList.length != otherlistdone.length)
			throw new Exception('Not all page numbers accounted for (${masterList.length} != ${otherlistdone.length})');

		// assert the order of the master list
		for (x in 0...masterList.length - 1)
			if (rules[masterList[x + 1]].contains(masterList[x]))
				throw new Exception('Fault in master list: ${masterList[x]} should not come before ${masterList[x + 1]}');

		// // output test data to file
		// var ruleList:DynamicAccess<Array<Int>> = {};
		// for (k => v in rules) {
		// 	ruleList.set(Std.string(k), v);
		// }
		// File.saveContent("test.json", Json.stringify({rules: ruleList, masterList: masterList, sets: sets}));

		return {masterList: masterList, sets: sets};
	}

	function problem1(data:String) {
		var p = parse(data);
		var retval = 0;

		// trace(p.masterList);
		for (line in p.sets) {
			var lastIndex = -1;
			var valid = true;

			for (num in line) {
				var i = p.masterList.indexOf(num);
				if (i == -1)
					continue;
				else if (lastIndex >= i) {
					// trace('❌ ${line.join(",")} is NOT valid');
					// trace(' - ${num} should not come after ${p.masterList[lastIndex]}');
					valid = false;
					break;
				} else
					lastIndex = i;
			}

			if (valid) {
				// var addval = line[Math.floor(line.length / 2)];
				// trace('✔️ ${line.join(",")} is valid');
				// if (line.length % 2 == 0)
				// 	trace(' - ⚠️ but the length of this line is even (${line.length})');
				// trace(' - so $addval gets added to retval ($retval + $addval = ${retval + addval})');
				retval += line[Math.floor(line.length / 2)];
			}
		}

		return retval;
		// 396 too low
		// it is not fucking 396 but every assert I throw at it says there's no reason it shouldn't be
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
