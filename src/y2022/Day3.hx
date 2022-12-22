package y2022;

using StringTools;

private var testData = [
	'vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
'
];

class Day3 extends DayEngine {
	static var code_a = "a".charCodeAt(0);
	static var code_A = "A".charCodeAt(0);

	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [157, 70]
			}
		});
		new Day3(data, 3, tests);
	}

	static function itemToPriority(item:String) {
		var priority = item.charCodeAt(0) + 1;
		if (item >= "a")
			priority -= code_a;
		else
			priority -= code_A - 26;
		return priority;
	}

	function problem1(data:String) {
		var sets = data.trim().split("\n").map(d -> {
			var halflen = Math.round(d.length / 2);
			return [d.substr(0, halflen), d.substr(halflen)].map(dd -> dd.split(""));
		});
		var total = 0;
		for (set in sets) {
			for (item in set[0])
				if (set[1].contains(item)) {
					total += Day3.itemToPriority(item);
					break;
				}
		}
		return total;
	}

	function problem2(data:String) {
		var sets = data.trim().split("\n").map(d -> d.split(""));
		var groups:Array<Array<Array<String>>> = [];

		{
			var group:Array<Array<String>> = [];
			for (set in sets) {
				group.push(set);
				if (group.length == 3) {
					groups.push(group);
					group = [];
				}
			}
		}

		var total = 0;
		for (group in groups) {
			for (item in group[0]) {
				if (group[1].contains(item) && group[2].contains(item)) {
					total += Day3.itemToPriority(item);
					break;
				}
			}
		}
		return total;
	}
}
