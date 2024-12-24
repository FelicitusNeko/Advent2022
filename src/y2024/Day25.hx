package y2024;

using StringTools;

private var testData = [''];

class Day25 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: []
			}
		});
		new Day25(data, 25, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n");

	function problem1(data:String) {
		var list = parse(data);
		return null;
	}

	function problem2(data:String) {
		trace("Day 25 Part 2 has no puzzle; get 49 stars!");
		return null;
	}
}
