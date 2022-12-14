package y2022;

import utils.Point;

using StringTools;

var testData = [
	'498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
'
];

enum IContent {
	Empty;
	Wall;
	Sand;
}

abstract Content(IContent) from IContent to IContent {
	@:to
	public function toString()
		return switch (this) {
			case Empty: ".";
			case Wall: "#";
			case Sand: "o";
		}
}

class WallSystem {
	var list:Array<Array<Point>> = [];
	var map:Array<Array<Content>> = [];
	var sandX = 500;
	var offsetX = 500;

	public var width(get, never):Int;
	public var height(get, never):Int;

	public function new(data:String, abyss = true) {
		var list = data.rtrim()
			.split("\n")
			.map(i -> i.split(" -> ").map(ii -> ii.split(",")).map(ii -> new utils.Point(Std.parseInt(ii[0]), Std.parseInt(ii[1]))));
		var maxX = 500, maxY = 0;
		for (wall in list)
			for (vertex in wall) {
				if (offsetX > vertex.x)
					offsetX = vertex.x;
				if (maxX < vertex.x)
					maxX = vertex.x;
				if (maxY < vertex.y)
					maxY = vertex.y;
			}
		if (abyss) {
			sandX -= offsetX;
			for (wall in list)
				for (vertex in wall) {
					vertex.x -= offsetX;
				}
		} else {
			offsetX = 0;
			maxX = 999;
		}

		for (_ in 0...maxY + 1)
			map.push([for (_ in 0...maxX - offsetX + 1) Empty]);
		if (!abyss) {
			map.push([for (_ in 0...1000) Empty]);
			map.push([for (_ in 0...1000) Wall]);
		}

		for (wall in list) {
			var curPos = wall[0];
			curPos.arraySet(map, Wall);
			for (vertex in wall)
				while (curPos != vertex) {
					if (curPos.x < vertex.x) curPos.x++;
					else if (curPos.x > vertex.x) curPos.x--;
					if (curPos.y < vertex.y) curPos.y++;
					else if (curPos.y > vertex.y) curPos.y--;
					curPos.arraySet(map, Wall);
				}
		}

		//trace("\n" + map.map(i -> i.map(i -> i.toString()).join("")).join("\n"));
	}

	inline function get_width()
		return map[0].length;

	inline function get_height()
		return map.length;

	public function dropSand() {
		var sandPos = new Point(sandX, 0);
		if (sandPos.arrayGet(map) != Empty) return null; // because the sand entry point is blocked

		for (y in 1...height) {
			if (map[y][sandPos.x] == Empty) sandPos.y++;
			else if (sandPos.x == 0) return null; // because it fell off the left side of the world
			else if (map[y][sandPos.x - 1] == Empty) {
				sandPos.y++;
				sandPos.x--;
			}
			else if (sandPos.x + 1 == width) return null; // because it fell off the right side of the world
			else if (map[y][sandPos.x + 1] == Empty) {
				sandPos.y++;
				sandPos.x++;
			}
			else {
				sandPos.arraySet(map, Sand);
				return sandPos; // because it settled somewhere
			}
		}

		return null; // because it fell off the bottom of the world
	}

	public inline function toString()
		return map.map(i -> i.map(i -> i.toString()).join("")).join("\n");
}

class Day14 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [24, 93]
			}
		});
		new Day14(data, 14, tests);
	}

	function problem1(data:String) {
		var walls = new WallSystem(data);
		var sandPos:Null<Point>, sandCount = 0;
		while ((sandPos = walls.dropSand()) != null) sandCount++;
		return sandCount;
	}

	function problem2(data:String) {
		var walls = new WallSystem(data, false);
		var sandPos:Null<Point>, sandCount = 0;
		while ((sandPos = walls.dropSand()) != null) sandCount++;
		return sandCount;
	}
}
