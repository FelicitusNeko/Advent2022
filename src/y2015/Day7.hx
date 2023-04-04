package y2015;

using StringTools;
using Safety;

private var testData = [''];

private enum ID7Value {
	Number(v:Int);
	Register(r:String);
}

private abstract D7Value(ID7Value) from ID7Value {
	private static var numPattern = ~/^\d+$/;

	private function new(v:ID7Value)
		this = v;

	@:from
	public static function fromInt(v:Int)
		return new D7Value(Number(v));

	@:from
	public static function fromString(v:String)
		return new D7Value(numPattern.match(v) ? Number(Std.parseInt(v)) : Register(v));

	public function getValue(reg:Map<String, Int>)
		return switch (this) {
			case Number(v): v;
			case Register(r): reg[r];
		}

	@:to
	public function toString()
		return switch (this) {
			case Number(v): '$v';
			case Register(r): r;
		}
}

private enum ID7Instruction {
	Set(v:D7Value, d:String);
	And(l:D7Value, r:D7Value, d:String);
	Or(l:D7Value, r:D7Value, d:String);
	LShift(l:D7Value, r:D7Value, d:String);
	RShift(l:D7Value, r:D7Value, d:String);
	Not(v:D7Value, d:String);
}

private abstract D7Instruction(ID7Instruction) from ID7Instruction {
	private static var i16max = 65535;

	public var dest(get, never):String;

	private function new(v:ID7Instruction)
		this = v;

	function get_dest():String
		return cast this.getParameters().pop();

	public function process(reg:Map<String, Int>)
		return switch (this) {
			case Set(v, d):
				reg[d] = v.getValue(reg);
			case And(l, r, d):
				reg[d] = l.getValue(reg) & r.getValue(reg);
			case Or(l, r, d):
				reg[d] = l.getValue(reg) | r.getValue(reg);
			case LShift(l, r, d):
				reg[d] = (l.getValue(reg) << r.getValue(reg)) % (i16max + 1);
			case RShift(l, r, d):
				reg[d] = (l.getValue(reg) >> r.getValue(reg)) % (i16max + 1);
			case Not(v, d):
				reg[d] = ~v.getValue(reg) % (i16max + 1);
		};

	public function resolvable(reg:Map<String, Int>)
		return switch (this) {
			case Set(v, _) | Not(v, _):
				v.getValue(reg) != null;
			case And(l, r, _) | Or(l, r, _) | LShift(l, r, _) | RShift(l, r, _): l.getValue(reg) != null && r.getValue(reg) != null;
		}

	@:from
	public static function fromString(s:String) {
		var parts = s.trim().split(" -> ");
		var equation = parts[0].split(" ");

		return new D7Instruction(switch (equation.length) {
			case 1:
				Set(equation[0], parts[1]);
			case 2:
				if (equation[0] != "NOT")
					throw "(1) Unrecognised operand in " + s;
				Not(equation[1], parts[1]);
			case 3:
				switch (equation[1]) {
					case "AND": And(equation[0], equation[2], parts[1]);
					case "OR": Or(equation[0], equation[2], parts[1]);
					case "LSHIFT": LShift(equation[0], equation[2], parts[1]);
					case "RSHIFT": RShift(equation[0], equation[2], parts[1]);
					default: throw "(2) Unrecognised operand in " + s;
				}
			default:
				throw "Unrecognised equation in " + s;
		});
	}

	@:to
	public function toString()
		return switch (this) {
			case Set(v, d): '$v -> $d';
			case And(l, r, d): '$l AND $r -> $d';
			case Or(l, r, d): '$l OR $r -> $d';
			case LShift(l, r, d): '$l LSHIFT $r -> $d';
			case RShift(l, r, d): '$l RSHIFT $r -> $d';
			case Not(v, d): 'NOT $v -> $d';
		}
}

class Day7 extends DayEngine {
	public static function make(data:String) {
		new Day7(data, 7);
	}

	function problem1(data:String) {
		var list = data.rtrim().split("\n").map(D7Instruction.fromString);
		var reg:Map<String, Int> = [];

		var remain = list.slice(0);
		while (remain.length > 0)
			remain = remain.filter(i -> {
				if (i.resolvable(reg)) {
					i.process(reg);
					return false;
				}
				return true;
			});

		return reg["a"].or(-1);
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		// BUG: I don't understand what the problem description is trying to convey
		return null;
	}
}
