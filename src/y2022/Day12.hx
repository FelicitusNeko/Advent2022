package y2022;

using StringTools;

var testData = [''];

class Day12 extends DayEngine {
  public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: []
			}
		});
		new Day12(data, 12, tests);
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