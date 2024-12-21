package y2024;

import utils.Point;
import haxe.Exception;
import utils.Direction;

using StringTools;

private var testData = [
	'029A
980A
179A
456A
379A'
];

/**
 * 
 * Numeric keypad:
 * +---+---+---+
 * | 7 | 8 | 9 |
 * +---+---+---+
 * | 4 | 5 | 6 |
 * +---+---+---+
 * | 1 | 2 | 3 |
 * +---+---+---+
 *     | 0 | A |
 *     +---+---+
 * 
 * Directional keypad:
 *     +---+---+
 *     | ^ | A |
 * +---+---+---+
 * | < | v | > |
 * +---+---+---+
 * 
 */
private enum IInstruction {
	Num(n:Int);
	Dir(d:Direction);
	Activate;
	Gap;
	Moves(q:Int, pt:Point);
}

@:forward
private abstract Instruction(IInstruction) from IInstruction to IInstruction {
	public var qty(get, never):Int;

	inline function new(i:IInstruction)
		this = i;

	function get_qty()
		return switch (this) {
			case Moves(q, _): q;
			default: 1;
		}

	@:op(a == b)
	function cmpInt(i:Int)
		return switch (this) {
			case Num(n): i == n;
			default: false;
		}

	@:op(a == b)
	function cmpDir(d:Direction)
		return switch (this) {
			case Dir(dd): d == dd;
			default: false;
		}

	@:op(a == b)
	function cmpNBool(b:Null<Bool>)
		return switch (this) {
			case Activate: b == true;
			case Gap: b != true;
			default: false;
		}

	@:op(a == b)
	inline function cmpInstruction(i:IInstruction)
		return this == i;

	@:op(a == b)
	function cmpString(s:String)
		return this == fromString(s);

	@:to
	public function toString()
		return switch (this) {
			case Num(n): '$n';
			case Dir(d): d.c;
			case Activate: "A";
			case Gap: " ";
			case Moves(q, pt): '{$q=>${pt.toString()}}';
		}

	@:from
	public static function fromString(s:String) {
		if (s.length != 1)
			throw new Exception("Instruction must be exactly one character");
		if (~/^[\d]$/.match(s))
			return new Instruction(Num(Std.parseInt(s)));
		else
			return new Instruction(switch (s) {
				case "^":
					Dir(Up);
				case ">":
					Dir(Right);
				case "v":
					Dir(Down);
				case "<":
					Dir(Left);
				case "A":
					Activate;
				case " ":
					Gap;
				case x:
					throw new Exception('Unknown instruction $x');
			});
	}
}

class Day21 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [126384]
			}
		});
		new Day21(data, 21, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n");

	function problem1(data:String) {
		var list = parse(data);
		var retval = 0;

		var bots = 3;
		var cache:Array<Map<String, Int>> = [for (_ in 0...bots) []];

		for (z => code in list) {
			function nav(bot:Int, inst:Array<Instruction>) {
				if (bot >= bots)
					return inst;
				var gaprow = bot == 0 ? 3 : 0;
				var pt:Point = [2, gaprow];
				// 789 / 456 / 123 / x0A
				// x^A / <v>

				var warp:Array<Int> = [];
				var dstlist = [
					for (z => i in inst)
						Point.fromArray(switch (i) {
							case Num(n): [n == 0 ? 1 : ((n - 1) % 3), 3 - Math.ceil(n / 3)];
							case Dir(d): switch (d) {
									case Up: [1, 0];
									case Left: [0, 1];
									case Down: [1, 1];
									case Right: [2, 1];
								}
							case Activate: [2, gaprow];
							case Moves(_, pt):
								warp.push(z);
								[pt.x, pt.y];
							case Gap: throw new Exception("Instruction cannot be gap");
						})
				];
				if (bot == 0)
					trace(code, pt, dstlist);

				var retval:Array<Instruction> = [];
				for (z => dst in dstlist) {
					if (warp.contains(z)) {} else {
						inline function move(f:Int, t:Int, d:Array<Direction>)
							for (_ in 0...Math.round(Math.abs(f - t)))
								retval.push(Dir(d[f > t ? 0 : 1]));
						var yfirst = pt.y == gaprow;
						if (yfirst)
							move(pt.y, dst.y, [Up, Down]);
						move(pt.x, dst.x, [Left, Right]);
						if (!yfirst)
							move(pt.y, dst.y, [Up, Down]);
						retval.push(Activate);
						pt = dst;
					}
				}

				if (bot < 2)
					trace(retval.map(i -> i.toString()).join(""));
				return nav(bot + 1, retval);
			}

			var myinput = nav(0, code.split("").map(Instruction.fromString));
			// trace(myinput.length, Std.parseInt(code), myinput.length * Std.parseInt(code));
			retval += myinput.length * Std.parseInt(code);
		}

		return retval;
		// 94758 too high
	}

	function problem2(data:String) {
		var list = parse(data);
		return null;
	}
}
