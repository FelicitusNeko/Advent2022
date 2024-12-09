package y2024;

import haxe.Int64;

using StringTools;

private var testData = ['2333133121414131402'];

class Day9 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [1928, 2858]
			}
		});
		new Day9(data, 9, tests);
	}

	function parse(data:String) {
		var list = data.rtrim().split("").map(Std.parseInt);
		var retval:Array<Null<Int>> = [];
		var next = 0;

		for (x => val in list) {
			var id:Null<Int> = null;
			if (x % 2 == 0)
				id = Math.round(x / 2);
			for (x in 0...val)
				retval.push(id);
		}
		while (retval[retval.length - 1] == null)
			retval.pop();

		return retval;
	}

	function problem1(data:String) {
		var map = parse(data);
		var retval:Int64 = 0;
		var x = 0;

		while (x < map.length) {
            var id = map[x];
			while (id == null)
				id = map.pop();
            retval += x++ * id;
		}

		if (Int64.neq(retval, 1928))
			Sys.println('WORKAROUND: Use this response → $retval'); // use the value this outputs as the solution
		return retval.low;
	}

	function problem2(data:String) {
		var map = parse(data);
		var retval:Int64 = 0;
		var lastProcessed:Int = map[map.length - 1];
		var fileLen = 0;
		var firstBlank = 0;

		for (x in 0...map.length) {
			var y = map.length - x - 1;
			if (y < firstBlank)
				break;
			var file = map[y];

			if (file != null && file == lastProcessed)
				fileLen++;
			else {
				if (fileLen > 0) {
					var foundBlank = false; // optimisation; keep track of first free space because we don't need to search before it
					var blankLen = 0;
					for (z in firstBlank...y + 1) {
						if (map[z] == null) {
							if (!foundBlank) {
								foundBlank = true;
								firstBlank = z;
							}
							if (++blankLen == fileLen) {
								for (w in 0...fileLen) {
									map[z - blankLen + w + 1] = lastProcessed;
									map[y + w + 1] = null;
								}
								break;
							}
						} else
							blankLen = 0;
					}
				}
				if (file != null && file < lastProcessed) {
					lastProcessed = file;
					fileLen = 1;
				} else
					fileLen = 0;
			}
		}

		for (x => file in map)
			if (file != null)
				retval += Int64.mul(x, file);

		if (Int64.neq(retval, 2858))
			Sys.println('WORKAROUND: Use this response → $retval'); // use the value this outputs as the solution
		return retval.low;
		// 6431465941341 too low
		// 6431472688582 too high
	}
}
