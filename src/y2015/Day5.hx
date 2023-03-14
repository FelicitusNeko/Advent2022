package y2015;

using StringTools;

class Day5 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: "ugknbfddgicrmopn",
				expected: [1]
			},
			{
				data: "aaa",
				expected: [1]
			},
			{
				data: "jchzalrnumimnmhp",
				expected: [0]
			},
			{
				data: "haegwjzuvuyypxyu",
				expected: [0]
			},
			{
				data: "dvszwmarrgswjxmb",
				expected: [0]
			},
			{
				data: "qjhvhtzxzqqjkmpb",
				expected: [null, 1]
			},
			{
				data: "xxyxx",
				expected: [null, 1]
			},
			{
				data: "uurcxstgmygtbstg",
				expected: [null, 0]
			},
			{
				data: "ieodomkazucvgmuy",
				expected: [null, 0]
			}
		];
		new Day5(data, 5, tests);
	}

	function problem1(data:String) {
		var list = data.rtrim().split("\n").map(i -> {
			return {
				s: i,
				c: i.split("")
			}
		});

		var naughty = ["ab", "cd", "pq", "xy"];
		var vowels = ["a", "e", "i", "o", "u"];
		var nice = 0;
		for (str in list) {
			var isNaughty = false;
			for (tok in naughty)
				isNaughty = isNaughty || (str.s.indexOf(tok) >= 0);
			if (isNaughty)
				continue;

			var vowel = 0;
			var double = 0;
			for (x => ch in str.c) {
				if (vowels.contains(ch))
					vowel++;
				if (x < str.s.length - 1 && ch == str.c[x + 1])
					double++;
			}

			if (vowel >= 3 && double >= 1)
				nice++;
		}

		return nice;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n").map(i -> {
			var chs = i.split("");
			return {
				s: i,
				c: chs,
				p: [for (x in 0...chs.length - 1) chs[x] + chs[x + 1]]
			};
		});

		var nice = 0;
		for (str in list) {
			var hasABA = false;
			var hasRepeatPair = false;

			for (x => ch in str.c)
				if (ch == str.c[x + 2]) {
					hasABA = true;
					break;
				}
			for (x => p in str.p)
				if (str.p.slice(x + 2).contains(p)) {
					hasRepeatPair = true;
					break;
				}
			if (hasABA && hasRepeatPair)
				nice++;
		}

		return nice;
	}
}
