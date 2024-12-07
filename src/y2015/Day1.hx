package y2015;

using StringTools;

private var testData = ['))((((('];

class Day1 extends DayEngine {
  public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [3, 1]
			}
		});
		new Day1(data, 1, tests);
	}

  function problem1(data:String) {
		var floor = 0;
		for (ch in data.rtrim().split("")) switch (ch) {
			case "(": floor++;
			case ")": floor--;
		}
		return floor;
  }

  function problem2(data:String) {
		var floor = 0;
		for (x => ch in data.rtrim().split("")) switch (ch) {
			case "(": floor++;
			case ")":
				floor--;
				if (floor < 0) return x + 1;
		}
		#if hl
		return 0;
		#else
		return null;
		#end
  }
}