package y2022;

import y2022.DayEngine.TestData;

var testData = [
	'1000
2000
3000

4000

5000
6000

7000
8000
9000

10000

'
];

class Day1 extends DayEngine {
	public static function make(data:String) {
		var tests:Array<TestData> = testData.map(i -> {
			return {
				data: i,
				expected: [24000, 45000]
			}
		});
		new Day1(data, 1, tests);
	}

	function problem1(data:String) {
		var list = data.split("\n").map(d -> d == "" ? null : Std.parseInt(d));
		var cur = 0, most = 0;

		for (d in list) {
			if (d == null) {
				if (cur > most)
					most = cur;
				cur = 0;
			} else
				cur += d;
		}

		return most;
	}

	function problem2(data:String) {
		var list = data.split("\n").map(d -> d == "" ? null : Std.parseInt(d));
		var cur = 0, most = [0, 0, 0];

		for (d in list) {
			if (d == null) {
				for (x => mostx in most)
					if (cur > mostx) {
						var buf = cur;
						cur = most[x];
						most[x] = buf;
						if (cur == 0)
							break;
					}
				cur = 0;
			} else
				cur += d;
		}

		for (_ => mostx in most)
			cur += mostx;

		return cur;
	}
}
