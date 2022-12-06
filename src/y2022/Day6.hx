package y2022;

import y2022.DayEngine.TestData;
using StringTools;

class Day6 extends DayEngine {
	public static function make(data:String) {
		var tests:Array<TestData> = [
			{data: "mjqjpqmgbljsphdztnvjfqwrcgsmlb", expected: ["7", "19"]},
			{data: "bvwbjplbgvbhsrlpgdmjqwftvncz", expected: ["5", "23"]},
			{data: "nppdvjthqldpwncqszvftbrmjlhg", expected: ["6", "23"]},
			{data: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", expected: ["10", "29"]},
			{data: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", expected: ["11", "26"]}
		];
		new Day6(data, 6, tests);
	}

	function problem1(data:String) {
		var list = data.rtrim().split("");
		var buf:Array<String> = [];

		var match = false;
		for (x => char in list) {
			buf.push(char);
			while (buf.length > 4)
				buf.shift();
			if (buf.length == 4) {
				match = true;
				for (y in 0...3)
					for (z in y+1...4) 
						if (buf[y] == buf[z]) {
							match = false;
							break;
						}
					
			}
			if (match)
				return Std.string(x+1);
		}

		return null;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("");
		var buf:Array<String> = [];

		var match = false;
		for (x => char in list) {
			buf.push(char);
			while (buf.length > 14)
				buf.shift();
			if (buf.length == 14) {
				match = true;
				for (y in 0...13)
					for (z in y+1...14) 
						if (buf[y] == buf[z]) {
							match = false;
							break;
						}
					
			}
			if (match)
				return Std.string(x+1);
		}

		return null;
	}
}
