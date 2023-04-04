package y2015;

using StringTools;

private var testData = [''];

class Day8 extends DayEngine {
  public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: []
			}
		});
		new Day8(data, 8, tests);
	}

  function problem1(data:String) {
    var list = data.rtrim().split("\n");
		// This requires reading a quoted, escaped string and parsing the escapes
		// I don't know how to do this in Haxe, straight-up
		return null;
  }

  function problem2(data:String) {
    var list = data.rtrim().split("\n");
		return null;
  }
}