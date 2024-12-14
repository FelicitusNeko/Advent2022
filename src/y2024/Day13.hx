package y2024;

import haxe.Int64Helper;
import haxe.Int64;
import utils.Point;
import utils.Point64;
import haxe.Exception;

using StringTools;

private var testData = [
	'Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279'
];

class Day13 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [480]
			}
		});
		new Day13(data, 13, tests);
	}

	function parse(data:String)
		return [
			for (entry in data.rtrim().split("\n\n")) {
				static var ptnButton = ~/Button [A-Z]: X([+-]\d+), Y([+-]\d+)/;
				static var ptnPrize = ~/Prize: X=(\d+), Y=(\d+)/;
				var parsed = [
					for (x => line in entry.split("\n")) {
						var ptn = (x < 2 ? ptnButton : ptnPrize);
						if (ptn.match(line)) [ptn.matched(1), ptn.matched(2)].map(Std.parseInt); else throw new Exception('Failed to match pattern $x: $line');
					}
				].map(i -> Point.fromArray([i[0], i[1]]));
				{
					buttons: parsed.slice(0, 2),
					prize: parsed[2]
				};
			}
		];

	function problem1(data:String) {
		var list = parse(data);
		var retval = 0;

		for (entry in list) {
			var pt:Point = [0, 0];
			var pushesPerBtn = [0, 0];
			var bestScore:Null<Int> = null;

			while (pt.x < entry.prize.x && pt.y < entry.prize.y) {
				pt += entry.buttons[0];
				pushesPerBtn[0]++;
			}
			if (pt == entry.prize && pushesPerBtn[0] <= 100)
				bestScore = pushesPerBtn[0] * 3;
			while (pushesPerBtn[0] > 0) {
				pt -= entry.buttons[0];
				pushesPerBtn[0]--;
				while (pt.x < entry.prize.x && pt.y < entry.prize.y) {
					pt += entry.buttons[1];
					pushesPerBtn[1]++;
				}
				if (pt == entry.prize && pushesPerBtn[0] <= 100 && pushesPerBtn[1] <= 100) {
					var newScore = (pushesPerBtn[0] * 3) + (pushesPerBtn[1]);
					bestScore = (bestScore == null) ? newScore : Math.round(Math.min(bestScore, newScore));
				}
			}

			if (bestScore != null)
				retval += bestScore;
		}

		return retval;
	}

	function problem2(data:String) { // maybe???
		var list = [
			for (i in parse(data))
				{
					buttons: i.buttons,
					prize: i.prize.toPoint64() + [
						Int64Helper.parseString("10000000000000"),
						Int64Helper.parseString("10000000000000")
					]
				}
		];
		var retval:Int64 = 0;

		for (z => entry in list) {
			Sys.println('$z...');
			var pt:Point64 = [0, 0];
			var pushesPerBtn:Array<Int64> = [0, 0];
			var bestScore:Null<Int64> = null;

			pushesPerBtn[0] = entry.prize.x / entry.buttons[0].x;
			pt = entry.buttons[0].toPoint64() * pushesPerBtn[0];

			while (pt.x < entry.prize.x && pt.y < entry.prize.y) {
				pt += entry.buttons[0];
				pushesPerBtn[0]++;
			}
			if (pt == entry.prize)
				bestScore = pushesPerBtn[0] * 3;
			while (pushesPerBtn[0] > 0) {
				pt -= entry.buttons[0];
				pushesPerBtn[0]--;
				while (pt.x < entry.prize.x && pt.y < entry.prize.y) {
					pt += entry.buttons[1];
					pushesPerBtn[1]++;
				}
				if (pt == entry.prize) {
					var newScore = (pushesPerBtn[0] * 3) + (pushesPerBtn[1]);
					Sys.print('Hit $newScore');
					if (bestScore == null)
						bestScore = newScore;
					else if (newScore < bestScore)
						bestScore = newScore;
				}
				Sys.sleep(0.001);
			}

			if (bestScore != null)
				retval += bestScore;
		}
		return retval;
	}
}
