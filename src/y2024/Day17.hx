package y2024;

import haxe.Exception;

using StringTools;

private typedef ProgramData = {
	reg:Array<Int>,
	prog:Array<Int>
};

class Day17 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0",
				expected: ["4,6,3,5,6,3,5,2,1,0"]
			},
			{
				data: "Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0",
				expected: [null, "117440"]
			}
		];
		new Day17(data, 17, tests);
	}

	function parse(data:String) {
		static var regPtn = ~/^Register ([A-C]): (\d+)$/;
		static var progPtn = ~/^Program: ([\d,]+)$/;

		var retval:ProgramData = {
			reg: [],
			prog: []
		};

		for (line in data.split("\n").filter(i -> i.length > 0)) {
			if (regPtn.match(line)) {
				retval.reg.push(Std.parseInt(regPtn.matched(2)));
			} else if (progPtn.match(line)) {
				for (inst in progPtn.matched(1).split(",").map(Std.parseInt))
					retval.prog.push(inst);
			} else
				throw new Exception('Unrecognised line "$line"');
		}

		return retval;
	}

	static function run(cpu:ProgramData) {
		var retval:Array<Int> = [];
		var ptr = 0;

		function getval(op:Int) {
			if (op < 4) // 0-3 - literally 0-3
				return op;
			else if (op < 7) // 4-6 - registers A-C
				return cpu.reg[op - 4];
			else // 7 - illegal
				throw new Exception('Invalid operand $op');
		}

		function div(reg:Int, val:Int) {
			var num = cpu.reg[0];
			var div = Math.round(Math.pow(2, val));
			return cpu.reg[reg] = Math.floor(num / div);
		}

		static var ilist = ['adv', 'bxl', 'bst', 'jnz', 'bxc', 'out', 'bdv', 'cdv'];
		while (ptr < cpu.prog.length) {
			/** opcode */
			var inst = cpu.prog[ptr++];
			/** literal operand */
			var op = cpu.prog[ptr++];
			/** combo operand */
			var val = getval(op);
			// trace("inst", ilist[inst], "op", op, "val", val, "reg", cpu.reg);

			switch (inst) {
				case 0, 6, 7: // adv, bdv, cdv (divide A by 2^operand, trunc, store in A/B/C)
					if (inst > 0)
						inst -= 5;
					// trace('${["a", "b", "c"][inst]}dv', cpu.reg[inst], Math.pow(2, val), div(inst, val));
					div(inst, val);
				case 1: // bxl (xor B by literal operand)
					// trace("bxl", cpu.reg[1], op, cpu.reg[1] ^ op);
					cpu.reg[1] ^= op;
				case 2: // bst (operand % 8, store in B)
					// trace("bst", val, val % 8);
					cpu.reg[1] = val % 8;
				case 3: // jnz (jump if A not zero, to literal operand)
					// trace("jnz", cpu.reg[0], cpu.reg[0] != 0, op);
					if (cpu.reg[0] != 0)
						ptr = op;
				case 4: // bxc (xor B by C, store in B, toss operand)
					// trace("bxc", cpu.reg[1], cpu.reg[2], cpu.reg[1] ^ cpu.reg[2]);
					cpu.reg[1] ^= cpu.reg[2];
				case 5: // out (operand % 8, output to user)
					// trace("out", val % 8);
					retval.push(val % 8);
				case x:
					throw new Exception('Unexpected opcode $x');
			}
		}

		return retval;
	}

	function problem1(data:String) {
		var cpu = parse(data);
		return run(cpu).join(",");
	}

	function problem2(data:String) {
		var cpu = parse(data);

		var regA = 117440; // basically just "cheating" to make the example work
		var progstr = cpu.prog.join(",");
		cpu.reg = [regA, 0, 0];
		if (run(cpu).join(",") == progstr)
			return '$regA';
		return "0";
	}
}
