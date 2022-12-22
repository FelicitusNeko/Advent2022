package y2022;

import haxe.Int64;

using StringTools;

private var testData = [
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

private abstract MonkeyOp(IMonkeyOp) from IMonkeyOp {
	public function new(op:IMonkeyOp)
		this = op;

	public function operate(ops:Map<String, MonkeyOp>):MonkeyOp
		return switch (this) {
			case Add(l, r):
				switch ([ops[l], ops[r]]) {
					case [Number(nl), Number(nr)]: Number(nl + nr);
					default: this;
				}
			case Sub(l, r):
				switch ([ops[l], ops[r]]) {
					case [Number(nl), Number(nr)]: Number(nl - nr);
					default: this;
				}
			case Mult(l, r):
				switch ([ops[l], ops[r]]) {
					case [Number(nl), Number(nr)]: Number(nl * nr);
					default: this;
				}
			case Div(l, r):
				switch ([ops[l], ops[r]]) {
					case [Number(nl), Number(nr)]: Number(nl / nr);
					default: this;
				}
			case Eq(l, r):
				switch ([ops[l], ops[r]]) {
					case [Number(nl), Number(nr)]: IsEqual(nl == nr);
					default: this;
				}
			default: this;
		}

	public function reverseOp(ops:Map<String, MonkeyOp>, carry:Int64)
		return switch (this) {
			case Add(l, r):
				switch ([ops[l].toInt64(), ops[r].toInt64()]) {
					case [null, null]: null; // H = ? + ?
					case [x, null]: {human: carry - x, recurse: r}; // H = N + ?
					case [null, y]: {human: carry - y, recurse: l}; // H = ? + N
					default: throw '$this op led to double-resolved operation'; // H = N + N
				}
			case Sub(l, r):
				switch ([ops[l].toInt64(), ops[r].toInt64()]) {
					case [null, null]: null; // H = ? - ?
					case [x, null]: {human: x - carry, recurse: r}; // H = N - ?
					case [null, y]: {human: carry + y, recurse: l}; // H = ? - N
					default: throw '$this op led to double-resolved operation'; // H = N - N
				}
			case Mult(l, r):
				switch ([ops[l].toInt64(), ops[r].toInt64()]) {
					case [null, null]: null; // H = ? * ?
					case [x, null]: {human: carry / x, recurse: r}; // H = N * ?
					case [null, y]: {human: carry / y, recurse: l}; // H = ? * N
					default: throw '$this op led to double-resolved operation'; // H = N * N
				}
			case Div(l, r):
				switch ([ops[l].toInt64(), ops[r].toInt64()]) {
					case [null, null]: null; // H = ? / ?
					case [x, null]: {human: x / carry, recurse: r}; // H = N / ?
					case [null, y]: {human: carry * y, recurse: l}; // H = ? / N
					default: throw '$this op led to double-resolved operation'; // H = N / N
				}
			case Eq(l, r):
				switch ([ops[l].toInt64(), ops[r].toInt64()]) {
					case [null, null]: null; // ? = ?
					case [x, null]: {human: x, recurse: r};
					case [null, x]: {human: x, recurse: l}; // N = H or H = N
					default: throw '$this op led to double-resolved operation'; // N = N
				}
			case x:
				throw 'Unexpected $x operation during reverseOp';
		}

	@:op(a == b)
	public function eqMonkeyOp(rhs:MonkeyOp)
		return switch ([this, rhs]) {
			case [Add(ll, lr), Add(rl, rr)] | [Mult(ll, lr), Mult(rl, rr)]: (ll == rl && lr == rr) || (ll == rr && rl == lr);
			case [Sub(ll, lr), Sub(rl, rr)] | [Div(ll, lr), Div(rl, rr)] | [Eq(ll, lr), Eq(rl, rr)]: (ll == rl && lr == rr);
			case [IsEqual(l), IsEqual(r)]: l == r;
			case [Number(l), Number(r)]: l == r;
			case [HumanInput, HumanInput]: true;
			default: false;
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

	function problem1(data:String) {
		var ops = parseOpList(data);

		var done = false;
		while (!done) {
			done = true;
			for (monkey => op in ops) {
				var result = op.operate(ops);
				if (op != result) {
					ops[monkey] = result;
					done = false;
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

		function humanScan():Null<Int64> {
			var scan = ops["root"];
			var human:Null<Int64> = null;
			var done = false;
			while (!done) {
				switch (scan) {
					case HumanInput:
						return human;
					case x:
						var result = x.reverseOp(ops, human);
						if (result == null)
							done = true;
						else {
							human = result.human;
							scan = ops[result.recurse];
						}
				}
			}
			return null;
		}

		var done = false;
		while (!done) {
			done = true;
			for (monkey => op in ops) {
				switch (op.operate(ops)) {
					case HumanInput:
						ops[monkey] = switch (humanScan()) {
							case null: HumanInput;
							case x: 
								done = false;
								Number(x);
						}
					case result:
						if (op != result) {
							ops[monkey] = result;
							done = false;
						}
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
