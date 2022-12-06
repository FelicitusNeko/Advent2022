package y2022;

import haxe.Exception;

using StringTools;

var testData = [
	'2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
'
];

typedef IElfAssignment = {
	var low1:Int;
	var hi1:Int;
	var low2:Int;
	var hi2:Int;
}

@:forward
abstract ElfAssignment(IElfAssignment) from IElfAssignment {
	public function new(low1:Int, hi1:Int, low2:Int, hi2:Int) {
		if (low1 > hi1) {
			var buf = low1;
			low1 = hi1;
			hi1 = buf;
		}
		if (low2 > hi2) {
			var buf = low2;
			low2 = hi2;
			hi2 = buf;
		}
		this = {
			low1: low1,
			hi1: hi1,
			low2: low2,
			hi2: hi2
		};
	}

	@:from
	public static function fromString(data:String) {
		var read = ~/(\d+)-(\d+),(\d+)-(\d+)/;
		if (read.match(data)) {
			return new ElfAssignment(Std.parseInt(read.matched(1)), Std.parseInt(read.matched(2)), Std.parseInt(read.matched(3)),
				Std.parseInt(read.matched(4)));
		} else
			throw new Exception('Invalid data "$data"');
	}

	public inline function hasFullOverlap()
		return (this.low1 >= this.low2 && this.hi1 <= this.hi2) || (this.low2 >= this.low1 && this.hi2 <= this.hi1);

	public function hasAnyOverlap() {
		var elf1 = [for (x in this.low1...this.hi1 + 1) x];
		var elf2 = [for (x in this.low2...this.hi2 + 1) x];
		for (x in elf1)
			if (elf2.contains(x))
				return true;
		return false;
	}
}

class Day4 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [2, 4]
			}
		});
		new Day4(data, 4, tests);
	}

	function problem1(data:String) {
		var list = data.trim().split("\n").map(ElfAssignment.fromString);
		var count = 0;
		for (assignment in list)
			if (assignment.hasFullOverlap())
				count++;
		return count;
	}

	function problem2(data:String) {
		var list = data.trim().split("\n").map(ElfAssignment.fromString);
		var count = 0;
		for (assignment in list)
			if (assignment.hasAnyOverlap())
				count++;
		return count;
	}
}
