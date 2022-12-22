package y2022;

import utils.Point;

using StringTools;
using utils.ArrayTools;
using Safety;

private var testData = [
	'        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5'
];

private enum PWSpace {
	MapEdge;
	Empty;
	Wall;
}

private enum PWTurn {
	Left;
	Right;
}

private enum PWInstruction {
	Move(steps:Int);
	Turn(dir:PWTurn);
}

private enum abstract Facing(Int) from Int to Int {
	var Right = 0;
	var Down = 1;
	var Left = 2;
	var Up = 3;

	@:op(a--)
	inline function decFacing() {
		if (--this < 0)
			this = 3;
		return this;
	}

	@:op(a++)
	inline function incFacing() {
		if (++this > 3)
			this = 0;
		return this;
	}

	public function applyToPoint(pt:Point) {
		return pt + switch (this) {
			case 0: {x: 1, y: 0};
			case 1: {x: 0, y: 1};
			case 2: {x: -1, y: 0};
			case 3: {x: 0, y: -1};
			default: throw 'Invalid direction $this';
		}
	}

	@:to
	public inline function toString()
		return switch (this) {
			case 0: "Right";
			case 1: "Down";
			case 2: "Left";
			case 3: "Up";
			default: "Unknown";
		}
}

private class PassMapper {
	var map:Array<Array<PWSpace>> = [];
	var instructions:Array<PWInstruction> = [];

	public var pos(default, null):Point;
	public var facing(default, null):Facing = Right;

	public var width(get, never):Int;
	public var height(get, never):Int;

	public function new(data:String) {
		var split = data.rtrim().split("\n\n");
		var mapLines = split[0].split("\n");
		var width = mapLines.reduce((r, i) -> r < i.length ? i.length : r, 0);

		map = [
			for (row in mapLines) [
				for (col in row.split(""))
					switch (col) {
						case ".":
							Empty;
						case "#":
							Wall;
						default:
							MapEdge;
					}
			]
		];
		for (row in map)
			while (row.length < width)
				row.push(MapEdge);

		var isNumber:Null<Bool> = null, curMatch = "";
		for (ch in(split[1] + "$").split("")) {
			var isDigit = Std.parseInt(ch) != null;
			switch ([isNumber, isDigit]) {
				case [true, false]:
					instructions.push(Move(Std.parseInt(curMatch)));
					curMatch = ch;
					isNumber = isDigit;
				case [false, true]:
					instructions.push(switch (curMatch) {
						case "L": Turn(Left);
						case "R": Turn(Right);
						case x: throw 'Invalid direction $x';
					});
					curMatch = ch;
					isNumber = isDigit;
				case [null, _]:
					curMatch = ch;
					isNumber = isDigit;
				default:
					curMatch += ch;
			}
		}

		var startX = -1;
		for (x => col in map[0])
			if (col == Empty) {
				startX = x;
				break;
			}
		if (startX < 0)
			throw 'Could not find starting position';
		pos = {x: startX, y: 0};
	}

	inline function get_width()
		return map[0].length;

	inline function get_height()
		return map.length;

	function getOppSide() {
		var npos:Point = switch (facing) {
			case Right: {x: -1, y: pos.y};
			case Down: {x: pos.x, y: -1};
			case Left: {x: width, y: pos.y};
			case Up: {x: pos.x, y: height};
		}, isWidthwise = [Right, Left].contains(facing);

		//trace('At $pos, $facing -  Checking from $npos');
		for (_ in 0...(isWidthwise ? width : height)) {
			npos = facing.applyToPoint(npos);
			//trace('Checking at $npos (${npos.arrayGet(map)})');
			if (npos.arrayGet(map).or(MapEdge) != MapEdge || pos == npos)
				return npos;
		}
		throw 'Unable to find suitable wraparound location from $pos, $facing';
	}

	public function step() {
		//trace('Starting at $pos');
		for (inst in instructions) {
			switch (inst) {
				case Move(steps):
					//trace('Pacing $steps');
					for (_ in 0...steps) {
						var dest = facing.applyToPoint(pos);
						//trace('At $dest is a ${dest.arrayGet(map).or(MapEdge)}');
						switch (dest.arrayGet(map).or(MapEdge)) {
							case Wall: break;
							case Empty: pos = dest;
							case MapEdge:
								dest = getOppSide();
								switch (dest.arrayGet(map)) {
									case Wall: break;
									case Empty: pos = dest;
									case MapEdge: throw 'Double-hit on map edge should not be possible';
								}
						}
					}
				case Turn(dir):
					//trace('Turning $dir');
					dir == Left ? facing-- : facing++;
			}
			//trace('Now at $pos facing $facing');
		}
	}

	public function toString()
		return map.map(i -> i.map(ii -> switch (ii) {
			case MapEdge: " ";
			case Empty: ".";
			case Wall: "#";
		}).join("")).join("\n") + "\n\n" + instructions.map(i -> switch (i) {
			case Move(steps): '$steps';
			case Turn(Left): "L";
			case Turn(Right): "R";
		}).join("") + '\n$pos, $facing';
}

class Day22 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [6032]
			}
		});
		new Day22(data, 22, tests);
	}

	function problem1(data:String) {
		var mapper = new PassMapper(data);
		mapper.step();
		//trace("\n" + mapper.toString());
		return ((mapper.pos.y + 1) * 1000) + ((mapper.pos.x + 1) * 4) + mapper.facing;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
