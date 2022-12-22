package y2022;

import haxe.Int64;

using StringTools;

var testData = [
	'root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32'
];

private enum IMonkeyOp {
	Number(num:Int64);
	Add(lhs:String, rhs:String);
	Sub(lhs:String, rhs:String);
	Mult(lhs:String, rhs:String);
	Div(lhs:String, rhs:String);
	Eq(lhs:String, rhs:String);
	IsEqual(result:Bool);
	HumanInput;
}

abstract MonkeyOp(IMonkeyOp) from IMonkeyOp {
	public function new(op:IMonkeyOp)
		this = op;

	public function operate(ops:Map<String, MonkeyOp>) {
		
	}

	public function reverseOp(ops:Map<String, MonkeyOp>, carry:Int64) {

	}

	@:from
	public static function fromString(opstr:String) {
		var opPattern = ~/^([a-z]{4}) ([\+\-\*\/]) ([a-z]{4})$/;
		if (opPattern.match(opstr))
			return new MonkeyOp(switch (opPattern.matched(2)) {
				case "+": Add(opPattern.matched(1), opPattern.matched(3));
				case "-": Sub(opPattern.matched(1), opPattern.matched(3));
				case "*": Mult(opPattern.matched(1), opPattern.matched(3));
				case "/": Div(opPattern.matched(1), opPattern.matched(3));
				case x: throw 'Invalid operand $x in "$opstr"';
			});
		else
			return new MonkeyOp(Number(Std.parseInt(opstr)));
	}

	@:to
	public inline function toInt64()
		return switch (this) {
			case Number(num): num;
			default: null;
		}
}

class Day21 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [] // [152, 301]
			}
		});
		new Day21(data, 21, tests);
	}

	function parseOpList(data:String) {
		var ops:Map<String, MonkeyOp> = [];
		var basePattern = ~/^([a-z]{4}): (.*)$/;
		for (line in data.rtrim().split("\n")) {
			if (basePattern.match(line))
				ops.set(basePattern.matched(1), basePattern.matched(2));
			else
				throw 'Invalid monkey operation: "$line"';
		}
		return ops;
	}

	function operate(ops:Map<String, MonkeyOp>, lhs:String, rhs:String, cb:(Int64, Int64) -> Int64)
		return switch (ops[lhs]) {
			case Number(lnum): switch (ops[rhs]) {
					case Number(rnum): cb(lnum, rnum);
					default: null;
				}
			default: null;
		}

	function problem1(data:String) {
		var ops = parseOpList(data);

		var done = false;
		while (!done) {
			done = true;
			for (monkey => op in ops) {
				var result:Null<Int64> = switch (op) {
					case Add(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l + r);
					case Sub(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l - r);
					case Mult(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l * r);
					case Div(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l / r);
					default: null;
				}
				if (result != null) {
					done = false;
					ops[monkey] = Number(result);
				}
			}
		}

		return cast switch (ops["root"]) {
			case Number(num): num;
			default: null;
		}
	}

	function problem2(data:String) {
		var ops = parseOpList(data);

		switch (ops["root"]) {
			case Add(lhs, rhs) | Sub(lhs, rhs) | Mult(lhs, rhs) | Div(lhs, rhs):
				ops["root"] = Eq(lhs, rhs);
			case x:
				throw 'Invalid operation $x on root monkey';
		}
		ops["humn"] = HumanInput;

		function reverseOp(human:Int64, op:MonkeyOp)
			return switch (op) {
				case Add(l, r):
					// trace('$human = ${ops[l].toInt64()} + ${ops[r].toInt64()}');
					switch ([ops[l].toInt64(), ops[r].toInt64()]) {
						case [null, null]: null; // H = ? + ?
						case [x, null]: {human: human - x, recurse: r}; // H = N + ?
						case [null, y]: {human: human - y, recurse: l}; // H = ? + N
						case [_, _]: null; // H = N + N
					}
				case Sub(l, r):
					// trace('$human = ${ops[l].toInt64()} - ${ops[r].toInt64()}');
					switch ([ops[l].toInt64(), ops[r].toInt64()]) {
						case [null, null]: null; // H = ? - ?
						case [x, null]: {human: x - human, recurse: r}; // H = N - ?
						case [null, y]: {human: human + y, recurse: l}; // H = ? - N
						case [_, _]: null; // H = N - N
					}
				case Mult(l, r):
					// trace('$human = ${ops[l].toInt64()} * ${ops[r].toInt64()}');
					switch ([ops[l].toInt64(), ops[r].toInt64()]) {
						case [null, null]: null; // H = ? * ?
						case [x, null]: {human: human / x, recurse: r}; // H = N * ?
						case [null, y]: {human: human / y, recurse: l}; // H = ? * N
						case [_, _]: null; // H = N * N
					}
				case Div(l, r):
					// trace('$human = ${ops[l].toInt64()} / ${ops[r].toInt64()}');
					switch ([ops[l].toInt64(), ops[r].toInt64()]) {
						case [null, null]: null; // H = ? / ?
						case [x, null]: {human: x / human, recurse: r}; // H = N / ?
						case [null, y]: {human: human * y, recurse: l}; // H = ? / N
						case [_, _]: null; // H = N / N
					}
				case Eq(l, r):
					// trace('${ops[l].toInt64()} = ${ops[r].toInt64()}');
					switch ([ops[l].toInt64(), ops[r].toInt64()]) {
						case [null, null]: null; // ? = ?
						case [x, null]: {human: x, recurse: r};
						case [null, x]: {human: x, recurse: l}; // N = H or H = N
						case [_, _]: null; // N = N (which shouldn't happen)
					}

				case x:
					throw 'Unexpected $x operation during reverseOp';
			}

		function humanScan():Null<Int64> {
			var scan = ops["root"];
			var human:Null<Int64> = null;
			var done = false;
			while (!done) {
				switch (scan) {
					case HumanInput:
						// trace('Found the answer $human');
						return human;
					case x = IsEqual(_) | Number(_):
						throw 'Unexpected $x operation during humanScan';
					case x:
						// trace('Operating on $x');
						var result = reverseOp(human, x);
						if (result == null) {
							// trace("No answer yet.");
							done = true;
						} else {
							human = result.human;
							scan = ops[result.recurse];
							// trace('The running count is now $human');
						}
				}
			}
			return null;
		}

		var done = false;
		while (!done) {
			done = true;
			for (monkey => op in ops) {
				var eqCheck = false;
				var result:Null<Int64> = switch (op) {
					case Number(_) | IsEqual(_): null;
					case Add(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l + r);
					case Sub(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l - r);
					case Mult(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l * r);
					case Div(lhs, rhs): operate(ops, lhs, rhs, (l, r) -> l / r);
					case Eq(lhs, rhs):
						eqCheck = true;
						// trace('Root monkey is attempting to compare $lhs (${ops[lhs]}) to $rhs (${ops[rhs]}) for equality');
						operate(ops, lhs, rhs, (l, r) -> l == r ? 1 : 0);
					case HumanInput: humanScan();
				}
				if (result != null) {
					done = false;
					ops[monkey] = eqCheck ? IsEqual(result == 1) : Number(result);
				}
			}
		}

		switch (ops["root"]) {
			case IsEqual(result):
				if (!result) {
					trace(ops);
					throw 'Root monkey operation failed';
				}
			default:
				throw 'Root monkey not reporting on equation';
		}

		return cast switch (ops["humn"]) {
			case Number(num): num;
			default: null;
		}
	}
}
