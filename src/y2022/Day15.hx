package y2022;

import haxe.ds.ArraySort;
import utils.HugeNumber;
import utils.Point;

using StringTools;

var testData = [
	'Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
'
];

typedef ISensor = {
	var loc:Point;
	var nearBeacon:Point;
};

@:forward
abstract Sensor(ISensor) from ISensor to ISensor {
	public var manhattan(get, never):Int;

	inline function get_manhattan()
		return Math.round(Math.abs(this.loc.x - this.nearBeacon.x) + Math.abs(this.loc.y - this.nearBeacon.y));
}

typedef IRange = {
	var low:Int;
	var high:Int;
}

@:forward
abstract Range(IRange) from IRange to IRange {
	public var size(get, never):Int;

	inline function get_size()
		return this.high - this.low + 1;

	@:op(a == b)
	public inline function eqInt(num:Int)
		return num >= this.low && num <= this.high;

	@:op(a < b)
	public inline function ltInt(num:Int)
		return num < this.low;

	@:op(a > b)
	public inline function gtInt(num:Int)
		return num > this.high;

	@:to
	public inline function toString()
		return '${this.low}...${this.high}';
}

class Day15 extends DayEngine {
	public static function make(data:String) {
		var expected:Array<Dynamic> = [26, "56,000,011"];
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: expected
			}
		});
		new Day15(data, 15, tests, false);
	}

	var isTest = true;

	function parseSensors(data:String) {
		var pattern = ~/^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/;
		var beacons:Map<String, Point> = [];
		var list:Array<Sensor> = data.rtrim().split("\n").map(i -> {
			if (pattern.match(i)) {
				var beaconPos = '${pattern.matched(3)}:${pattern.matched(4)}';
				var beacon = beacons.exists(beaconPos) ? beacons[beaconPos] : Point.fromString(beaconPos);
				if (isTest)
					isTest = beacon.y < 40;
				if (!beacons.exists(beaconPos))
					beacons[beaconPos] = beacon;
				return {
					loc: Point.fromString('${pattern.matched(1)}:${pattern.matched(2)}'),
					nearBeacon: beacon
				};
			} else
				throw 'Invalid reading "$i"';
		});
		return {
			list: list,
			beacons: beacons
		};
	}

	function problem1(data:String) {
		isTest = true;
		var parsed = parseSensors(data);
		var list = parsed.list, beacons = parsed.beacons;
		var refY = isTest ? 10 : 2000000;
		var lowest = 9999999, highest = -9999999;
		var ranges:Array<Range> = [];

		for (sensor in list) {
			var distFromRef = Math.round(Math.abs(sensor.loc.y - refY)),
				manhattan = sensor.manhattan,
				distDiff = manhattan - distFromRef;
			if (distDiff >= 0) {
				var newRange:Range = {low: sensor.loc.x - distDiff, high: sensor.loc.x + distDiff};
				if (newRange.low < lowest)
					lowest = newRange.low;
				if (newRange.high > highest)
					highest = newRange.high;
				ranges.push(newRange);
			}
		}

		var total = 0;
		var x = lowest;
		while (x < highest) {
			for (range in ranges) {
				if (range == x) {
					total += (range.high - x + 1);
					x = range.high;
					break;
				}
			}
			x++;
		}

		for (_ => beacon in beacons) {
			if (beacon.y != refY) continue;
			for (range in ranges) {
				if (range == beacon.x) {
					total--;
					break;
				}
			}
		}

		return total;
	}

	function problem2(data:String) {
		isTest = true;
		var parsed = parseSensors(data);
		var list = parsed.list;
		var highest = isTest ? 20 : 4000000;
		
		for (refY in 0...highest + 1) {
			var ranges:Array<Range> = [];

			for (sensor in list) {
				var distFromRef = Math.round(Math.abs(sensor.loc.y - refY)),
					manhattan = sensor.manhattan,
					distDiff = manhattan - distFromRef;
				if (distDiff >= 0) {
					var newRange:Range = {low: sensor.loc.x - distDiff, high: sensor.loc.x + distDiff};
					ranges.push(newRange);
				}
			}
	
			var x = 0;
			while (x < highest + 1) {
				var intersect = false;
				for (range in ranges) {
					if (range == x) {
						intersect = true;
						x = range.high;
						break;
					}
				}
				if (!intersect) {
					trace('$x:$refY');
					var result = HugeNumber.fromInt(x) * 4000000;
					return (result + refY).toString();
				}
				x++;
			}
		}

		trace('not found');
		return null;
	}
}
