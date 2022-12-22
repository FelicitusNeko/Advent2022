package y2022;

import haxe.Serializer;
import haxe.Int64;
import utils.Point;

using utils.ArrayTools;
using StringTools;
using Safety;

private var testData = ['>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>'];
private var blockDefs = ["####", ".#./###/.#.", "..#/..#/###", "#/#/#/#", "##/##"];

private enum RTSpace {
	Empty;
	Rock(falling:Bool);
}

private enum RTMove {
	Left;
	Right;
	Down;
}

private class RockTetris {
	var blocks:Array<Array<Array<RTSpace>>> = [];
	var well:Array<Array<RTSpace>> = [];
	var moves:Array<RTMove> = [];

	public var moveCount(default, null):Int64 = 0;
	public var droppedRows(default, null):Int64 = 0;
	public var wellWidth(default, null) = 7;

	public var wellHeight(get, never):Int;
	public var wellRealHeight(get, never):Int64;
	public var topBlockRow(get, never):Int64;

	public var lastMoveSerialized(default, null) = "";

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
			if (row.reduce((r, i) -> r || i != Empty, false))
				break;
			else
				retval--;
		}
		// trace("topBlockRow", wellRealHeight, retval);
		return retval;
	}

	function shiftUp(rows = 1) {
		for (_ in 0...rows)
			well.unshift([for (_ in 0...wellWidth) Empty]);
		if (wellHeight > 500)
			throw "Well height exceeded 500";

		var fullcols = [for (_ in 0...wellWidth) false];
		for (y => row in well) {
			for (x => col in row)
				fullcols[x] = fullcols[x] || col != Empty;

			var done = false;
			while (!done) {
				done = true;
				for (x => col in fullcols)
					if (col && !(fullcols[x - 1].or(true) && fullcols[x + 1].or(true)) && row[x] == Empty) {
						fullcols[x] = false;
						done = false;
					}
			}
			// trace(fullcols.map(i -> i ? "#" : ".").join(""));

			if (fullcols.reduce((r, i) -> r && i)) {
				// trace('allCols at $y/$wellHeight');
				droppedRows += wellHeight - y;
				well = well.slice(0, y);
				break;
			}
		}
		// trace('Height: $wellHeight/$wellRealHeight');
	}

	public function dropBlock() {
		var s = new Serializer();
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

		s.serialize(curBlock);

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
			s.serialize(dir);
			moves.push(dir);

			if (canMove(Down))
				curPos.y++;
			else {
				lockDown();
				done = true;
			}
		}

		s.serialize(well);
		moveCount++;
		lastMoveSerialized = s.toString();

		blocks.push(curBlock);
	}

	public function analyseState(stateBank:Map<String, Int64>) {
		var retval:Null<Int64> = stateBank[lastMoveSerialized];
		stateBank.set(lastMoveSerialized, moveCount);
		//if (retval != null) trace('analyse', retval, moveCount);
		return retval;
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
				expected: []//[Int64.ofInt(3068), Int64.fromFloat(1514285714288)]
			}
		});
		new Day17(data, 17, tests);
	}

	function problem1(data:String) {
		var tetr = new RockTetris(data);
		for (_ in 0...2022)
			tetr.dropBlock();
		// var lhs:Int64 = 12345, rhs:Int64 = 12344;
		// trace(lhs == rhs + 1);
		return tetr.topBlockRow;
	}

	function problem2(data:String) {
		var tetr = new RockTetris(data);
		var stateBank:Map<String, Int64> = [];

		var target:Null<Int64> = null,
			split:Null<Int64> = null,
			heightMarker:Null<Int64> = null;
		var lastHit:Int64 = -5, consecutive = 0;
		var done = false;
		while (!done) {
			var analysis:Null<Int64> = null;

			// Keep dropping blocks until the analysis picks up a signature match
			do
				tetr.dropBlock() while ((analysis = tetr.analyseState(stateBank)) == null);

				// If we found a signature match
			if (analysis != null) {
				// If we don't have a loop target
				if (target == null) {
					// If the last signature match was one move after the current one
					if (lastHit == analysis - 1) {
						// If we have five consecutive signature matches
						if (++consecutive >= 5) {
							// Put a pin in it and make sure the loop is consistent
							//trace('Move ${tetr.moveCount} seems to have the same state and identical last move as move $analysis');
							heightMarker = tetr.topBlockRow;
							target = tetr.moveCount;
							split = tetr.moveCount - analysis;
							//for (_ in 0...split.low) tetr.dropBlock(); // attempted cheat - doesn't work
							//done = true;
						}
					} else {
						// Otherwise, start over in counting
						consecutive = 1;
					}
					// And set our last hit to the analysis value
					lastHit = analysis;
				} else if (analysis == target) {
					// ↑ If the last hit is the same as our target
					// ↓ If there's also the same number of moves between the first/second and second/third hits
					if (tetr.moveCount - analysis == split) {
						// Definitely a loop; proceed to final phase
						trace('Pattern seems to be confirmed! Move ${tetr.moveCount} seems to have the same state signature as $target, and each were $split moves apart.');
						done = true;
					} else {
						// Maybe not so much a loop?
						trace('Maybe not a pattern? Was expecting ${split} moves apart, but it\'s actually ${tetr.moveCount - analysis}');
					}
				} /*else if (analysis > target) {
					// ↑ If we missed our mark
					// Throw an error (probably a ghost pattern)
					throw 'We seem to have missed the target (it was $target, but we\'re at $analysis)';
					// heightMarker = tetr.topBlockRow;
					// target = tetr.moveCount;
					// split = tetr.moveCount - analysis;
				}*/
			} else
				// Otherwise (and this shouldn't happen; if it does 100,000 years from now, though, we probably have the answer the hard way unless something went wrong)
				throw 'Fell through the loop with null analysis';
		}

		// Count how many of our trillion moves are left
		var movesLeft = (Int64.ofInt(1000000) * 1000000) - tetr.moveCount;
		
		var fullLoops = movesLeft / split, // Count how many times we'd loop through our pattern,
			loopRemainder = movesLeft % split, // how many more moves are left from that,
			heightDiff = tetr.topBlockRow - heightMarker; // and how much of an impact that makes on well height
		// trace(movesLeft, fullLoops, loopRemainder);

		// Run through the remaining moves
		for (_ in 0...loopRemainder.low)
			tetr.dropBlock();

		// And derive the total number of rows based on how many more full loops we'd do
		return tetr.topBlockRow + (fullLoops * heightDiff);
		// 1_507_954_545_469 too low
	}
}
