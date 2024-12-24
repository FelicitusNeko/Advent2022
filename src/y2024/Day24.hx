package y2024;

import haxe.Int64;
import haxe.ds.ArraySort;
import haxe.Exception;

using StringTools;

private var testData = [''];

private enum Wire {
	And(l:String, r:String);
	Or(l:String, r:String);
	Xor(l:String, r:String);
	Value(v:Bool);
}

class Day24 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: 'x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02
',
				expected: [4]
			},
			{
				data: 'x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
',
				expected: [2024]
			}
		];
		new Day24(data, 24, tests);
	}

	function parse(data:String) {
		var setPtn = ~/^([a-z\d]{3}): ([01])$/;
		var gatePtn = ~/^([a-z\d]{3}) (AND|X?OR) ([a-z\d]{3}) -> ([a-z\d]{3})$/;

		var split = data.rtrim().split("\n\n");
		var map:Map<String, Wire> = [];

		for (set in split[0].split("\n"))
			if (setPtn.match(set))
				map[setPtn.matched(1)] = Value(setPtn.matched(2) == "1");
			else
				throw new Exception('Invalid set-value pattern "$set"');

		for (gate in split[1].split("\n"))
			if (gatePtn.match(gate))
				map[gatePtn.matched(4)] = switch (gatePtn.matched(2)) {
					case "AND": And(gatePtn.matched(1), gatePtn.matched(3));
					case "OR": Or(gatePtn.matched(1), gatePtn.matched(3));
					case "XOR": Xor(gatePtn.matched(1), gatePtn.matched(3));
					case x: throw new Exception('Invalid operator $x in "$gate"');
				}
			else
				throw new Exception('Invalid gate pattern "$gate"');

		return map;
	}

	function resolve(gates:Map<String, Wire>, id:String) {
		var ptn = new EReg('$id\\d\\d', '');
		var read = [for (k in gates.keys()) k].filter(i -> ptn.match(i));
		var output:Array<Null<Bool>> = [for (_ in read) null];
		for (z in read) {
			var i = Std.parseInt(z.substring(1));
			switch (gates[z]) {
				case Value(v):
					output[i] = v;
				default:
					throw new Exception('Unresolved output gate at $z');
			}
		}
		output.reverse();
		var retval:Int64 = 0;
		for (v in output) {
			retval <<= 1;
			switch (v) {
				case true:
					retval++;
				case null:
					throw new Exception('Unexpected null output');
				case false:
			}
		}
		return retval;
	}

	function problem1(data:String) {
		var gates = parse(data);
		var done = false;
		var didAnything = false;
		while (!done) {
			done = true;
			didAnything = false;
			for (wire => val in gates)
				switch (val) {
					case And(l, r), Or(l, r), Xor(l, r):
						var op = val.getName();
						switch ([gates[l], gates[r]]) {
							case [Value(vl), Value(vr)]:
								gates[wire] = Value(switch (op) {
									case "And": vl && vr;
									case "Or": vl || vr;
									case "Xor": (vl || vr) && !(vl && vr);
									default: throw new Exception("This is a bug");
								});
								didAnything = true;
							default: done = false;
						}
					case Value(_):
				}
			if (!didAnything)
				throw new Exception("Infinite loop");
		}

		var retval = resolve(gates, "z");
		trace(retval);
		return retval.low;
	}

	function problem2(data:String) {
		var list = parse(data);
		return null;
	}
}
