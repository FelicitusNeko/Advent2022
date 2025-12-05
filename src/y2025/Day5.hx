package y2025;

import haxe.ds.ArraySort;
import haxe.Int64Helper;
import haxe.Int64;

using StringTools;
using Safety;

private var testData = [
	'3-5
10-14
16-20
12-18

1
5
8
11
17
32
'
];

private typedef D5IRange = {
	start:Int64,
	end:Int64
}

@:forward
private abstract D5Range(D5IRange) from D5IRange to D5IRange {
	public var length(get, never):Int64;

	private function new(input:D5IRange)
		this = input;

	private function get_length()
		return this.end - this.start + 1;

	@:from
	static public function fromString(input:String) {
		var split = input.split('-');
		return new D5Range({
			start: Int64Helper.parseString(split[0]),
			end: Int64Helper.parseString(split[1])
		});
	}

	public function isInRange(input:Int64)
		return input >= this.start && input <= this.end;

	public function mergeIfOverlap(rhs:D5Range):Null<D5Range>
		return (isInRange(rhs.start) || isInRange(rhs.end)) ? new D5Range({
			start: this.start < rhs.start ? this.start : rhs.start,
			end: this.end > rhs.end ? this.end : rhs.end
		}) : null;
}

private typedef D5Data = {
	fresh:Array<D5Range>,
	available:Array<Int64>
}

class Day5 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [3, 14].map(Int64.ofInt)
			}
		});
		new Day5(data, 5, tests);
	}

	function parse(data:String):D5Data {
		var parts = data.rtrim().split("\n\n");
		return {
			fresh: parts[0].split('\n').map(D5Range.fromString),
			available: parts[1].split('\n').map(i -> Int64Helper.parseString(i))
		};
	}

	function problem1(data:String) {
		var list = parse(data);
		var retval:Int64 = 0;
		for (item in list.available)
			for (range in list.fresh) {
				if (range.isInRange(item)) {
					retval++;
					break;
				}
			}
		return retval;
	}

	function problem2(data:String) {
		var list = parse(data).fresh;
		var retval:Int64 = 0;
		var done = false;

		// TODO: cleanup code so sort isn't necessary
		ArraySort.sort(list, (lhs, rhs) -> {
			if (lhs.start < rhs.start) return -1;
			if (lhs.start > rhs.start) return 1;
			if (lhs.end < rhs.end) return -1;
			if (lhs.end > rhs.end) return 1;
			return 0;
		});

		while (!done) {
			done = true;

			var worklist = list.slice(0);
			var x = 0;
			while (x < worklist.length) {
				var newlist:Array<D5Range> = [], lhs = worklist[x];
				for (y in x + 1...worklist.length) {
					var merge = lhs.mergeIfOverlap(worklist[y]);
					if (merge == null)
						newlist.push(worklist[y]);
					else {
						lhs = merge;
						done = false;
					}
				}
				worklist = worklist.slice(0, x).concat([lhs]).concat(newlist);
				x++;
			}
			list = worklist;
		}

		for (range in list)
			retval += range.length;

		return retval;
		// 357485433193284 correct for my puzzle input,
		// but ideally shouldn't have to sort to get there
	}
}
