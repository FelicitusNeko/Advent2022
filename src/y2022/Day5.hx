package y2022;

import haxe.Exception;

using StringTools;

typedef StackInstruction = {
	var qty:Int;
	var from:Int;
	var to:Int;
}

class StackRunner {
	var stacks:Array<Array<String>> = [];
	var instructions:Array<StackInstruction> = [];

  public var stackTops(get, never):String;

	public function new(data:String) {
		var parts = data.rtrim().split("\n\n");

		// part 0 is the stack data
		var stackData = parts[0].split("\n");
		var numStackPattern = ~/(\d+)\s*$/;
		var numStacks = switch (numStackPattern.match(stackData.pop())) {
			case true: Std.parseInt(numStackPattern.matched(1));
			default: throw new Exception("Error trying to read number of stacks in stack data");
		}
		for (_ in 0...numStacks)
			stacks.push([]);
		for (line in stackData) {
			for (x in 0...numStacks) {
				var box = line.charAt(1 + (x * 4));
				if (box != " ")
					stacks[x].unshift(box);
			}
		}

		// part 1 is the instruction data
		instructions = parts[1].split("\n").map(i -> {
			var pattern = ~/^move (\d+) from (\d+) to (\d+)$/;
			if (pattern.match(i))
				return {
					qty: Std.parseInt(pattern.matched(1)),
					from: Std.parseInt(pattern.matched(2)),
					to: Std.parseInt(pattern.matched(3))
				};
			else
				throw new Exception('Invalid instruction "$i"');
		});
	}

  public function runOneByOne() {
    for (instruction in instructions)
      for (_ in 0...instruction.qty)
        stacks[instruction.to - 1].push(stacks[instruction.from - 1].pop());
  }

  public function runMultiple() {
    for (instruction in instructions){
      var buf:Array<String> = [];
      for (_ in 0...instruction.qty)
        buf.push(stacks[instruction.from - 1].pop());
      while (buf.length > 0) 
        stacks[instruction.to - 1].push(buf.pop());
    }
  }

  function get_stackTops() {
    var retval = "";
    for (stack in stacks) retval += stack[stack.length - 1];
    return retval;
  }
}

class Day5 {
	public static function problem1(data:String) {
		var runner = new StackRunner(data);
    runner.runOneByOne();
		return runner.stackTops;
	}

	public static function problem2(data:String) {
		var runner = new StackRunner(data);
    runner.runMultiple();
		return runner.stackTops;
	}
}
