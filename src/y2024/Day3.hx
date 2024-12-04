package y2024;

import haxe.Exception;

using StringTools;

class Day3 extends DayEngine {
	private static var pMul = ~/mul\((\d+),(\d+)\)/;
	private static var pDo = ~/do\(\)/;
	private static var pDont = ~/don't\(\)/;

	public static function make(data:String) {
		var tests = [
			{
				data: 'xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))',
				expected: [161, null]
			},
			{
				data: "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
				expected: [null, 48]
			}
		];
		new Day3(data, 3, tests);
	}

	static function min(vals:Array<Null<Int>>) {
		var retval:Null<Int> = null;
		var min:Null<Int> = null;
		for (i => v in vals) {
			if (v != null && (min == null || min > v)) {
				retval = i;
				min = v;
			}
		}
		return retval;
	}

	function problem1(data:String) {
		var retval = 0;
		if (pMul.match(data))
			do {
				retval += Std.parseInt(pMul.matched(1)) * Std.parseInt(pMul.matched(2));
			} while (pMul.match(pMul.matchedRight()));
		return retval;
	}

	function problem2(data:String) {
		var parse = data;
		var retval = 0;
		var enable = true;

		while (parse.length > 0) {
			var match = [
				for (i in [pMul, pDo, pDont]) {
					i.match(parse) ? i.matchedPos().pos : null;
				}
			];
			switch (min(match)) {
				case 0: // mul(x,y)
					if (enable)
						retval += Std.parseInt(pMul.matched(1)) * Std.parseInt(pMul.matched(2));
					parse = pMul.matchedRight();
				case 1: // do()
					enable = true;
					parse = pDo.matchedRight();
				case 2: // don't()
					enable = false;
					parse = pDont.matchedRight();
				case null: // no match
					parse = '';
				default:
					throw new Exception("Unexpected min value returned");
			}
		}
		return retval;
	}
}
