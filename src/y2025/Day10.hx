package y2025;

using StringTools;
using Safety;

private var testData = [
	'[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
'
];

private typedef D10Panel = {
	goal:Int,
	buttons:Array<Int>,
	joltages:Array<Int>
};

class Day10 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [7, 33]
			}
		});
		new Day10(data, 10, tests);
	}

	function parse(data:String):Array<D10Panel> {
		return data.rtrim().split("\n").map(i -> {
			var tokens = i.split(" ");
			var retval:D10Panel = {
				goal: 0,
				joltages: tokens.pop().sure().substring(1).split(",").map(i -> Std.parseInt(i).sure()),
				buttons: tokens.slice(1).map(i -> {
					var button = 0;
					for (wire in i.substring(1).split(","))
						button |= 1 << Std.parseInt(wire).sure();
					return button;
				}),
			};

			for (x => ch in tokens[0].sure().substring(1).split(""))
				if (ch == "#")
					retval.goal |= 1 << x;

			return retval;
		});
	}

	function problem1(data:String) {
		var list = parse(data);
		var total = 0;
		for (panel in list) {
			var best = 0x7fffffff;
			for (x in 0...1 << panel.buttons.length) {
				var value = 0;
				var buttons = 0;
				for (y in 0...panel.buttons.length) {
					if ((x & (1 << y)) != 0){
						value ^= panel.buttons[y];
						buttons++;
					}
				}
				if (value == panel.goal && buttons < best)
					best = buttons;
			}

			total += best;
		}
		return total;
	}

	function problem2(data:String) {
		var list = parse(data);
		var total = 0;
		for (panel in list) {
			var best = 0x7fffffff;
			var pushes = [for (_ in panel.buttons) 0];
			var joltages = [for (_ in panel.joltages) 0];
			// for (x in 0...1 << panel.buttons.length) {
			// 	var value = 0;
			// 	var buttons = 0;
			// 	for (y in 0...panel.buttons.length) {
			// 		if ((x & (1 << y)) != 0){
			// 			value ^= panel.buttons[y];
			// 			buttons++;
			// 		}
			// 	}
			// 	if (value == panel.goal && buttons < best)
			// 		best = buttons;
			// }

			//total += best;
		}
		return total;
	}
}
