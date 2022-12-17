package y2022;

import haxe.Int64;
import utils.Point;

using StringTools;
using Safety;

var testData = ['>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>'];
var blockDefs = ["####", ".#./###/.#.", "..#/..#/###", "#/#/#/#", "##/##"];

enum RTSpace {
	Empty;
	Rock(falling:Bool);
}

enum RTMove {
	Left;
	Right;
	Down;
}

class RockTetris {
	var blocks:Array<Array<Array<RTSpace>>> = [];
	var well:Array<Array<RTSpace>> = [];
	var moves:Array<RTMove> = [];
	var droppedRows:Int64 = 0;
	var wellWidth = 7;

	public var wellHeight(get, never):Int;
	public var wellRealHeight(get, never):Int64;
	public var topBlockRow(get, never):Int64;

	public function new(data:String) {
		for (def in blockDefs) {
			blocks.push(def.split("/").map(i -> i.split("").map(ii -> switch (ii) {
				case '.': Empty;
				case '#': Rock(true);
				case x: throw 'Unknown block character $x';
			})));
		}

		moves = data.rtrim().split("").map(i -> switch (i) {
			case "<": Left;
			case ">": Right;
			case x: throw 'Unknown move character $x';
		});

		shiftUp(15);
	}

	function get_wellHeight()
		return well.length;

	function get_wellRealHeight()
		return droppedRows + well.length;

	function get_topBlockRow() {
		var retval = wellRealHeight;
		for (row in well) {
			var hasBlock = false;
			for (sp in row)
				hasBlock = hasBlock || sp.getName() == "Rock";
			if (hasBlock)
				break;
			else
				retval--;
		}
		return retval;
	}

	function shiftUp(rows = 1) {
		for (_ in 0...rows)
			well.unshift([for (_ in 0...wellWidth) Empty]);

		var fullcols = [for (_ in 0...wellWidth) false];
		for (y => row in well) {
			for (x => col in row)
				fullcols[x] = fullcols[x] || col != Empty;

			var done = false;
			while (!done) {
				done = true;
				for (x => col in fullcols)
					if (col && (fullcols[x-1].or(false) || fullcols[x+1].or(false)) && row[x] == Empty) {
						fullcols[x] = false;
						done = false;
					}
			}
			
			var allCols = true;
			for (col in fullcols) allCols = allCols && col;
			if (allCols) {
				droppedRows += wellHeight - y;
				well = well.slice(0, y);
				break;
			}
		}
	}

	public function dropBlock() {
		var curPos = new Point(2, 0);
		var curBlock = blocks.shift();
		if (curBlock == null)
			throw "No blocks in queue"; // this shouldn't happen but just in case

		var blockHeight = curBlock.length, blockWidth = curBlock[0].length;

		var topRow = 0;
		for (row in well) {
			var hasBlock = false;
			for (sp in row)
				hasBlock = hasBlock || sp.getName() == "Rock";
			if (hasBlock)
				break;
			else
				topRow++;
		}
		// topRow -= topRow == wellHeight ? 4 : 3;
		topRow -= 3;
		curPos.y = topRow - curBlock.length;
		if (curPos.y < 0) {
			shiftUp(-curPos.y);
			curPos.y = 0;
		}

		function canMove(dir:RTMove) {
			var dest = curPos + switch (dir) {
				case Left: {x: -1, y: 0};
				case Right: {x: 1, y: 0};
				case Down: {x: 0, y: 1};
			}
			// trace(dest.x, dest.x < 0, dest.x + blockWidth, wellWidth, dest.x + blockWidth > wellWidth, dest.y + blockHeight, wellHeight, dest.y + blockHeight > wellHeight);
			if (dest.x < 0)
				return false;
			if (dest.x + blockWidth > wellWidth)
				return false;
			if (dest.y + blockHeight > wellHeight)
				return false;

			for (y => row in curBlock)
				for (x => bl in row) {
					switch (bl) {
						case Rock(_):
							var chk = (dest + {x: x, y: y});
							// trace('Checking at $chk');
							if (chk.arrayGet(well) != Empty)
								return false;
						default:
					}
				}
			return true;
		}

		function lockDown()
			for (y => row in curBlock)
				for (x => bl in row) {
					switch (bl) {
						case Rock(_):
							(curPos + {x: x, y: y}).arraySet(well, Rock(false));
						default:
					}
				}

		var done = false;
		while (!done) {
			var dir = moves.shift();
			if (canMove(dir))
				switch (dir) {
					case Left:
						curPos.x--;
					case Right:
						curPos.x++;
					case Down:
						throw 'Illegal Down instruction in move queue';
				}
			moves.push(dir);

			if (canMove(Down))
				curPos.y++;
			else {
				lockDown();
				done = true;
			}
		}

		blocks.push(curBlock);
	}

	public function toString()
		return [
			for (row in well)
				row.map(i -> switch (i) {
					case Empty: ".";
					case Rock(true): "@";
					case Rock(false): "#";
				}).join("")
		].join("\n");
}

class Day17 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [Int64.ofInt(3068), Int64.fromFloat(1514285714288)]
			}
		});
		new Day17(data, 17, tests);
	}

	function problem1(data:String) {
		var tetr = new RockTetris(data);
		for (_ in 0...2022)
			tetr.dropBlock();
		// trace("\n" + tetr.toString());
		return tetr.topBlockRow;
	}

	function problem2(data:String) {
		var tetr = new RockTetris(data);
		for (_ in 0...1000000)
			for (_ in 0...1000000)
				tetr.dropBlock();
		return null;
	}
}
