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

abstract private class PassMapper {
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

	abstract public function step():Void;

	public function toString()
		return map.map(i -> i.map(ii -> switch (ii) {
			case MapEdge: " ";
			case Empty: ".";
			case Wall: "#";
		}).join("")).join("\n")
			+ "\n\n"
			+ instructions.map(i -> switch (i) {
				case Move(steps): '$steps';
				case Turn(Left): "L";
				case Turn(Right): "R";
			}).join("")
			+ '\n$pos, $facing';
}

private class PassMapper2D extends PassMapper {
	function getOppSide() {
		var npos:Point = switch (facing) {
			case Right: {x: -1, y: pos.y};
			case Down: {x: pos.x, y: -1};
			case Left: {x: width, y: pos.y};
			case Up: {x: pos.x, y: height};
		}, isWidthwise = [Right, Left].contains(facing);

		// trace('At $pos, $facing -  Checking from $npos');
		for (_ in 0...(isWidthwise ? width : height)) {
			npos = facing.applyToPoint(npos);
			// trace('Checking at $npos (${npos.arrayGet(map)})');
			if (npos.arrayGet(map).or(MapEdge) != MapEdge || pos == npos)
				return npos;
		}
		throw 'Unable to find suitable wraparound location from $pos, $facing';
	}

	public function step() {
		// trace('Starting at $pos');
		for (inst in instructions) {
			switch (inst) {
				case Move(steps):
					// trace('Pacing $steps');
					for (_ in 0...steps) {
						var dest = facing.applyToPoint(pos);
						// trace('At $dest is a ${dest.arrayGet(map).or(MapEdge)}');
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
					// trace('Turning $dir');
					dir == Left ? facing-- : facing++;
			}
			// trace('Now at $pos facing $facing');
		}
	}
}

private enum IPageLink {
	TopOf(page:PM3DPage);
	BottomOf(page:PM3DPage);
	LeftOf(page:PM3DPage);
	RightOf(page:PM3DPage);
	Unlinked;
}

private abstract PageLink(IPageLink) from IPageLink {
	@:to
	public function toString()
		return switch (this) {
			case TopOf(page): 'Top of ${page.pageCoord}';
			case BottomOf(page): 'Bottom of ${page.pageCoord}';
			case LeftOf(page): 'Left of ${page.pageCoord}';
			case RightOf(page): 'Right of ${page.pageCoord}';
			case Unlinked: "Unlinked";
		}
}

private enum RelativePos {
	Within;
	Above;
	Below;
	ToLeft;
	ToRight;
}

private typedef IPM3DPage = {
	var pageCoord:Point;
	var pageSize:Int;
	var ?topTo:PageLink;
	var ?btmTo:PageLink;
	var ?leftTo:PageLink;
	var ?rightTo:PageLink;
}

@:forward
private abstract PM3DPage(IPM3DPage) from IPM3DPage {
	public var tl(get, never):Point;
	public var br(get, never):Point;

	inline function get_tl()
		return {x: this.pageCoord.x * this.pageSize, y: this.pageCoord.y * this.pageSize};

	inline function get_br()
		return {x: (this.pageCoord.x + 1) * this.pageSize - 1, y: (this.pageCoord.y + 1) * this.pageSize - 1};

	public function checkPos(pt:Point) {
		var ltl = tl, lbr = br;
		// trace(pt, ltl, lbr, ltl.y>pt.y, lbr.y<pt.y, ltl.x>pt.x, lbr.x<pt.x);
		if (ltl.y > pt.y)
			return Above;
		if (lbr.y < pt.y)
			return Below;
		if (ltl.x > pt.x)
			return ToLeft;
		if (lbr.x < pt.x)
			return ToRight;
		return Within;
	}

	@:to
	public function toString()
		return 'Page ${this.pageCoord}:\n  Top leads to ${this.topTo}\n  Bottom leads to ${this.btmTo}\n  Left leads to ${this.leftTo}\n  Right leads to ${this.rightTo}';
}

@:generic
private inline function traceAndReturn<T>(v:T) {
	trace(v);
	return v;
}

private class PassMapper3D extends PassMapper {
	public var pageSize(default, null):Int;
	public var pagesWide(get, never):Int;
	public var pagesHigh(get, never):Int;

	var pages:Array<PM3DPage> = [];
	var curPage:PM3DPage;

	public function new(data:String) {
		super(data);

		pageSize = Math.round(Math.sqrt(width * height / 12));
		// trace(pageSize);

		for (y in 0...Math.round(height / pageSize)) {
			for (x in 0...Math.round(width / pageSize)) {
				pages.push({
					pageCoord: {x: x, y: y},
					pageSize: pageSize
				});
			}
		}

		var pageMap:Map<String, PM3DPage> = [];
		pages = pages.filter(i -> i.tl.arrayGet(map).or(MapEdge) != MapEdge);
		for (page in pages)
			pageMap.set(page.pageCoord, page);

		for (page in pages) {
			if (curPage == null && page.checkPos(pos) == Within)
				curPage = page;

			page.topTo = (() -> {
				var up = page.pageCoord + {x: 0, y: -1};
				if (up.y < 0)
					up.y += pagesHigh;
				if (pageMap.exists(up))
					return BottomOf(pageMap[up]);
				up.x = (up.x + 1) % 4;
				if (pageMap.exists(up))
					return RightOf(pageMap[up]);
				up.x = ((up.x + 4) - 2) % 4;
				if (pageMap.exists(up))
					return LeftOf(pageMap[up]);
				up.x = (up.x + 3) % 4;
				if (pageMap.exists(up))
					return TopOf(pageMap[up]);
				up.x = ((up.x + 4) - 4) % 4;
				if (pageMap.exists(up))
					return TopOf(pageMap[up]);
				throw 'Could not find linking page for top side of ${page.pageCoord}';
			})();
			page.btmTo = (() -> {
				var down = page.pageCoord + {x: 0, y: 1};
				if (down.y >= pagesHigh)
					down.y = 0;
				if (pageMap.exists(down))
					return TopOf(pageMap[down]);
				down.x = (down.x + 1) % 4;
				if (pageMap.exists(down))
					return LeftOf(pageMap[down]);
				down.x = ((down.x + 4) - 2) % 4;
				if (pageMap.exists(down))
					return RightOf(pageMap[down]);
				down.x = (down.x + 3) % 4;
				if (pageMap.exists(down))
					return BottomOf(pageMap[down]);
				down.x = ((down.x + 4) - 4) % 4;
				if (pageMap.exists(down))
					return BottomOf(pageMap[down]);
				throw 'Could not find linking page for bottom side of ${page.pageCoord}';
			})();
			page.leftTo = (() -> {
				var left = page.pageCoord + {x: -1, y: 0};
				if (left.x < 0)
					left.x += pagesWide;
				if (pageMap.exists(left))
					return RightOf(pageMap[left]);
				left.y = (left.y + 1) % 4;
				if (pageMap.exists(left))
					return BottomOf(pageMap[left]);
				left.y = ((left.y + 4) - 2) % 4;
				if (pageMap.exists(left))
					return TopOf(pageMap[left]);
				left.y = (left.y + 3) % 4;
				if (pageMap.exists(left))
					return LeftOf(pageMap[left]);
				left.y = ((left.y + 4) - 4) % 4;
				if (pageMap.exists(left))
					return LeftOf(pageMap[left]);
				throw 'Could not find linking page for left side of ${page.pageCoord}';
			})();
			page.rightTo = (() -> {
				var right = page.pageCoord + {x: 1, y: 0};
				if (right.x >= pagesWide)
					right.x = 0;
				if (pageMap.exists(right))
					return LeftOf(pageMap[right]);
				right.y = (right.y + 1) % 4;
				if (pageMap.exists(right))
					return TopOf(pageMap[right]);
				right.y = ((right.y + 4) - 2) % 4;
				if (pageMap.exists(right))
					return BottomOf(pageMap[right]);
				right.y = (right.y + 3) % 4;
				if (pageMap.exists(right))
					return RightOf(pageMap[right]);
				right.y = ((right.y + 4) - 4) % 4;
				if (pageMap.exists(right))
					return RightOf(pageMap[right]);
				throw 'Could not find linking page for right side of ${page.pageCoord}';
			})();
		}

		for (page in pages) trace(page);
		//trace(curPage);
	}

	inline function get_pagesWide()
		return Math.round(width / pageSize);

	inline function get_pagesHigh()
		return Math.round(height / pageSize);

	public function step() {
		for (inst in instructions) {
			switch (inst) {
				case Move(steps):
					// trace('Pacing $steps');
					for (_ in 0...steps) {
						var dest = facing.applyToPoint(pos);
						// TODO: this is where to check if we're stepping off the page
						// trace('At $dest is a ${dest.arrayGet(map).or(MapEdge)}');
						switch (dest.arrayGet(map).or(MapEdge)) {
							case Wall: break;
							case Empty: pos = dest;
							case MapEdge: throw 'Stepped into a map edge (should not be possible in 3D mapper)';
						}
					}
				case Turn(dir):
					// trace('Turning $dir');
					dir == Left ? facing-- : facing++;
			}
			// trace('Now at $pos facing $facing');
		}
	}
}

class Day22 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [6032, 5031]
			}
		});
		new Day22(data, 22, tests);
	}

	function problem1(data:String) {
		var mapper = new PassMapper2D(data);
		mapper.step();
		// trace("\n" + mapper.toString());
		return ((mapper.pos.y + 1) * 1000) + ((mapper.pos.x + 1) * 4) + mapper.facing;
	}

	function problem2(data:String) {
		var mapper = new PassMapper3D(data);
		return null;
	}
}
