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
		new Day(data, 1, tests);
	}

  function problem1(data:String) {
    var list = data.rtrim().split("\n");
		return null;
  }

  function problem2(data:String) {
    var list = data.rtrim().split("\n");
		return null;
  }
}