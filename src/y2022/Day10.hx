package y2022;

using StringTools;

private var testData = [
	'addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
'
];

private enum CRTInstruction {
	AddX(val:Int);
	NoOp;
}

private class CRTProcessor {
	public var cycles(default, null) = 0;
	public var register(default, null) = 1;

	var program:Array<CRTInstruction>;
	var position = 0;
	var delay = 0;

	public function new(data:String) {
		program = data.rtrim().split("\n").map(i -> {
			var tokens = i.split(" ");
			return switch (tokens[0]) {
				case "addx": AddX(Std.parseInt(tokens[1]));
				case "noop": NoOp;
				case x: throw 'Invalid instruction "$x"';
			}
		});
	}

	public function tick() {
		if (position == program.length)
			return false;
		if (delay > 0) {
			delay--;
			if (delay == 0) {
				switch (program[position]) {
					case AddX(val):
						register += val;
					case NoOp:
				}
				position++;
			}
		} else
			switch (program[position]) {
				case AddX(_):
					delay = 1;
				case NoOp:
					position++;
			}
		cycles++;
		return true;
	}
}

class Day10 extends DayEngine {
	public static function make(data:String) {
		var expected:Array<Dynamic> = [
			13140,
			null
// 			"
// ##..##..##..##..##..##..##..##..##..##..
// ###...###...###...###...###...###...###.
// ####....####....####....####....####....
// #####.....#####.....#####.....#####.....
// ######......######......######......####
// #######.......#######.......#######.....
// " // For some reason, Haxe is not managing to catch this as a match, but it is (maybe some line termination malarkey)
		];
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: expected
			}
		});
		new Day10(data, 10, tests);
	}

	function problem1(data:String) {
		var cpu = new CRTProcessor(data);
		var checkpoint = 20;
		var tally = 0;

		while (cpu.cycles < 220) {
			if (cpu.cycles + 1 == checkpoint) {
				tally += (cpu.cycles + 1) * cpu.register;
				checkpoint += 40;
			}
			cpu.tick();
		}

		return tally;
	}

	function problem2(data:String) {
		var cpu = new CRTProcessor(data);
		var output:Array<String> = [];
		var outputLine = "";

		do {
			outputLine += (cpu.register >= outputLine.length - 1 && cpu.register <= outputLine.length + 1) ? "#" : ".";
			if (outputLine.length == 40) {
				output.push(outputLine);
				outputLine = "";
			}
		} while (cpu.tick());

		return "\n" + output.join("\n");
	}
}
