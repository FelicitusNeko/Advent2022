package y2022;

using StringTools;

var testData = [''];

class Day extends DayEngine {
  public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: []
			}
		});
		new Day(data, 0, tests);
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