package y2015;

import helder.Set;
import utils.Point;
import utils.Direction;

using StringTools;

private var testData = [''];

class Day3 extends DayEngine {
  public static function make(data:String) {
		var tests = [
			{
				data: ">", expected: [2]
			},
			{
				data: "^>v<", expected: [4, 3]
			},
			{
				data: "^v^v^v^v^v", expected: [2, 11]
			}
		];
		new Day3(data, 3, tests);
	}

  function problem1(data:String) {
    var list:Array<Direction> = data.rtrim().split("").map(ch -> switch (ch) {
			case "^": Up;
			case ">": Right;
			case "v": Down;
			case "<": Left;
			case x: throw 'Unrecognised direction symbol "$x"';
		});
		var pt = new Point(0,0);
		var stops = new Set<String>([pt]);

		for (move in list) {
			move.applyToPoint(pt);
			stops.add(pt);
		}

		return stops.length;
  }

  function problem2(data:String) {
    var list:Array<Direction> = data.rtrim().split("").map(ch -> switch (ch) {
			case "^": Up;
			case ">": Right;
			case "v": Down;
			case "<": Left;
			case x: throw 'Unrecognised direction symbol "$x"';
		});
		var pts = [new Point(0,0), new Point(0,0)];
		var stops = new Set<String>([pts[0]]);

		for (move in list) {
			var pt = pts.shift();
			move.applyToPoint(pt);
			stops.add(pt);
			pts.push(pt);
		}

		return stops.length;
 }
}