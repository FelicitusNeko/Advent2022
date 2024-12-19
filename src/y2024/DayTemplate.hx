package y2024;

using StringTools;

private var testData = [''];

class Day extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: []
			}
		});
		new Day(data, , tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n");

	function problem1(data:String) {
		var list = parse(data);
		return null;
	}

	function problem2(data:String) {
		var list = parse(data);
		return null;
	}
}
