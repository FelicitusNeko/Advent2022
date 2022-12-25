package y2022;

import haxe.Int64;

using StringTools;

private abstract SNAFUNumber(Int64) from Int64 to Int64 {
	inline function new(val:Int64)
		this = val;

	@:from
	public static function fromNotation(snafu:String) {
		var val = 0;
		for (ch in snafu.trim().split("")) {
			val *= 5;
			val += switch (ch) {
				case "2": 2;
				case "1": 1;
				case "0": 0;
				case "-": -1;
				case "=": -2;
				case x: throw 'Unrecognised character $x';
			}
			trace(val);
		}
		return new SNAFUNumber(val);
	}

	@:to
	public function toNotation() {
		var retval:Array<String> = [];
		var work = this.copy();
		while (work > 0) {
			trace(work, ((work + 2) % 5), ((work + 2) % 5).low, (work % 5).low + 2);
			retval.unshift(switch (((work % 5).low + 2) % 5) {
				case 4: "2";
				case 3: "1";
				case 2: "0";
				case 1: "-";
				case 0: "=";
				case x: throw 'Somehow ended up with $x in a modulo 5 (how, though?)';
			});
			trace('work before: $work, char extracted: ${retval[0]}');
			work /= 5;
			if (["-", "="].contains(retval[0])) work++;
			trace('work after: $work');
		}
		return retval.join("");
	}
}

class Day25 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: '1121-1110-1=0', // 314159265
				expected: ["1121-1110-1=0"]
			},
			{
				data: "1-=0-00----022121=0=",
				expected: ["1-=0-00----022121=0="]
			},
			{
				data: '1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122',
				expected: ["2=-1=0"]
			}
		];
		new Day25(data, 25, tests);
	}

	function problem1(data:String) {
		var list = data.rtrim().split("\n").map(i -> SNAFUNumber.fromNotation(i));
		trace(list);
		var total:Int64 = 0;
		for (i in list)
			total += i;
		return cast(total, SNAFUNumber).toNotation();
	}

	function problem2(data:String) {
		trace("No part 2 puzzle for day 25");
		return null;
	}
}
