package y2022;

import haxe.ds.ArraySort;

using StringTools;

var testData = [
	'Monkey 0:
Starting items: 79, 98
Operation: new = old * 19
Test: divisible by 23
	If true: throw to monkey 2
	If false: throw to monkey 3

Monkey 1:
Starting items: 54, 65, 75, 74
Operation: new = old + 6
Test: divisible by 19
	If true: throw to monkey 2
	If false: throw to monkey 0

Monkey 2:
Starting items: 79, 60, 97
Operation: new = old * old
Test: divisible by 13
	If true: throw to monkey 1
	If false: throw to monkey 3

Monkey 3:
Starting items: 74
Operation: new = old + 3
Test: divisible by 17
	If true: throw to monkey 0
	If false: throw to monkey 1
'
];

typedef Throw = {
	var item:Int;
	var dest:Int;
}

enum WorryOp {
	Add(lhs:Null<Int>, rhs:Null<Int>);
	Mult(lhs:Null<Int>, rhs:Null<Int>);
}

class Monkey {
	public var id(default, null):Int;

	var items:Array<Int> = [];
	var worryOp:WorryOp;
	var superWorry:Bool;

	public var testDivisor(default, null):Int;

	public var destTrue(default, null):Int;
	public var destFalse(default, null):Int;

	public var business(default, null) = 0;

	public function new(data:String, superWorry = false) {
		var pattern = ~/Monkey (\d+):\s+Starting items: ([\d ,]+\s+Operation: new = (old|\d+) ([+\-*\/])) (old|\d+)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d+)\s+If false: throw to monkey (\d+)/;
		if (pattern.match(data)) {
			/*
				0: Full string
				1: Monkey ID
				2: List of starting items
				3: First value
				4: Operand
				5: Second value
				6: Test condition
				7: If true dest
				8: If false dest
			 */
			id = Std.parseInt(pattern.matched(1));
			items = pattern.matched(2).split(", ").map(Std.parseInt);

			var lhs = pattern.matched(3), rhs = pattern.matched(5);
			worryOp = switch (pattern.matched(4)) {
				case "+": Add(lhs == "old" ? null : Std.parseInt(lhs), rhs == "old" ? null : Std.parseInt(rhs));
				case "*": Mult(lhs == "old" ? null : Std.parseInt(lhs), rhs == "old" ? null : Std.parseInt(rhs));
				case x: throw 'Invalid operand $x for monkey $id';
			}

			this.superWorry = superWorry;

			testDivisor = Std.parseInt(pattern.matched(6));
			destTrue = Std.parseInt(pattern.matched(7));
			destFalse = Std.parseInt(pattern.matched(8));
		} else
			throw 'Invalid data for ${data.split("\n").shift()}';
	}

	public function checkAndChuck():Null<Throw> {
		var item = items.shift();
		if (item == null)
			return null;
		business++;

		var newWorry = switch (worryOp) {
			case Add(lhs, rhs):
				if (lhs == null)
					lhs = item;
				if (rhs == null)
					rhs = item;
				lhs + rhs;
			case Mult(lhs, rhs):
				if (lhs == null)
					lhs = item;
				if (rhs == null)
					rhs = item;
				lhs * rhs;
		};
		if (!superWorry)
			newWorry = Math.floor(newWorry / 3);

		return {
			item: newWorry,
			dest: newWorry % testDivisor == 0 ? destTrue : destFalse
		};
	}

	public inline function give(item:Int)
		items.push(item);

	public inline function toString()
		return
			'Monkey $id:\n  Current items: ${items.join(", ")}\n  Operation: new = $worryOp\n  Test: divisible by $testDivisor\n    If true: throw to monkey $destTrue\n    If false: throw to monkey $destFalse';
}

class MonkeyGroup {
	public var monkeys(get, null):Array<Monkey>;

	public function new(data:String, superWorry = false) {
		monkeys = data.rtrim().split("\n\n").map(i -> new Monkey(i, superWorry));
	}

	inline function get_monkeys()
		return monkeys.slice(0);

	function findMonkey(id:Int) {
		for (monkey in monkeys)
			if (monkey.id == id)
				return monkey;
		throw 'Monkey $id not found';
	}

	public function runRound() {
		for (monkey in monkeys) {
			var throwData:Throw;
			while ((throwData = monkey.checkAndChuck()) != null) {
				findMonkey(throwData.dest).give(throwData.item);
			}
		}
	}

	public inline function toString()
		return monkeys.map(i -> i.toString()).join("\n\n");
}

class Day11_2 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [10605]
			}
		});
		new Day11_2(data, 11, tests);
	}

	function problem1(data:String) {
		var group = new MonkeyGroup(data);
		// Sys.println(group.toString());
		// if (Sys.getChar(false) == 3)
		// 	return null;
		var mod = 1;
		for (monkey in group.monkeys)
			mod *= monkey.testDivisor;
		for (_ in 0...20) {
			group.runRound();
			// Sys.println(group.toString());
			// if (Sys.getChar(false) == 3) return null;
		}

		var business = group.monkeys.map(i -> i.business);
		ArraySort.sort(business, (lhs, rhs) -> lhs - rhs);

		return business.pop() * business.pop();
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n");
		return null;
	}
}
