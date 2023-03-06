package y2015;

import haxe.crypto.Md5;

using StringTools;

class Day4 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: "abcdef",
				expected: [609043]
			},
			{
				data: "pqrstuv",
				expected: [1048970]
			}
		];
		new Day4(data, 4, tests);
	}

	function problem1(data:String) {
		var key = data.rtrim();
		var resp = 0, sum = "";
		do
			sum = Md5.encode('$key${++resp}') while (!sum.startsWith("00000"));
		return resp;
	}

	function problem2(data:String) {
		var key = data.rtrim();
		var resp = 0, sum = "";
		do
			sum = Md5.encode('$key${++resp}') while (!sum.startsWith("000000"));
		return resp;
	}
}
