package y2024;

import haxe.Int64;
import haxe.ds.ArraySort;

using StringTools;

private var testData = [
	'r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
'
];

class Day19 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [6, 16]
			}
		});
		new Day19(data, 19, tests);
	}

	function parse(data:String) {
		var split = data.rtrim().split("\n\n");
		return {
			towels: split[0].split(", "),
			patterns: split[1].split("\n")
		};
	}

	function problem1(data:String) {
		var p = parse(data);
		var retval = 0;

		function evalPattern(pattern:String) {
			for (t in p.towels) {
				if (pattern == t)
					return true;
				else if (pattern.startsWith(t))
					if (evalPattern(pattern.substring(t.length)))
						return true;
			}
			return false;
		}

		for (ptn in p.patterns)
			if (evalPattern(ptn))
				retval++;

		return retval;
	}

	function problem2(data:String) {
		var p = parse(data);
		var retval:Int64 = 0;

		var tfl:Map<String, Array<String>> = [];
		var cache:Map<String, Int64> = [];

		for (t in p.towels) {
			if (tfl.exists(t.charAt(0)))
				tfl[t.charAt(0)].push(t);
			else
				tfl[t.charAt(0)] = [t];
		}

		function evalPattern(pattern:String) {
			if (cache.exists(pattern))
				return cache[pattern];
			else {
				var retval:Int64 = 0;
				for (t in tfl[pattern.charAt(0)] ?? []) {
					if (pattern == t)
						retval++;
					else if (pattern.startsWith(t))
						retval += evalPattern(pattern.substring(t.length));
				}
				cache[pattern] = retval;
				return retval;
			}
		}

		for (x => ptn in p.patterns)
			retval += evalPattern(ptn);

		if (Int64.neq(retval, 16))
			Sys.println('WORKAROUND: Use this response → $retval'); // use the value this outputs as the solution
		return retval.low;
	}
}
