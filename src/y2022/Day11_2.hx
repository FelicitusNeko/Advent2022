package y2022;

import haxe.Int64;
import haxe.ds.ArraySort;

using StringTools;

private var testData = [
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

private typedef Throw = {
	var item:Int64;
	var dest:Int;
}

private enum IWorryOp {
	Add(rhs:Int64);
	Mult(rhs:Int64);
	Square;
}

private abstract WorryOp(IWorryOp) from IWorryOp to IWorryOp {
	public function new(op:IWorryOp)
		this = op;

	@:from
	public static function fromString(op:String) {
		var pattern = ~/old ([+*]) (old|\d+)/;
		if (pattern.match(op)) {
			var rhs = pattern.matched(2);
			return switch (pattern.matched(1)) {
				case "+": new WorryOp(Add(Std.parseInt(rhs)));
				case "*": new WorryOp(rhs == "old" ? Square : Mult(Std.parseInt(rhs)));
				case x: throw 'Invalid operand $x';
			}
		} else throw 'Invalid operation $op';
	}

	@:to
	public inline function toString()
		return "old " + switch (this) {
			case Add(rhs): '+ $rhs';
			case Mult(rhs): '* $rhs';
			case Square: "* old";
		}

	public function apply(lhs:Int64)
		return switch (this) {
			case Add(rhs): lhs + rhs;
			case Mult(rhs): lhs * rhs;
			case Square: lhs * lhs;
		}
}

private class Monkey {
	public var id(default, null):Int;

	var items:Array<Int64> = [];
	var worryOp:WorryOp;
	var superWorry:Bool;

	public var testDivisor(default, null):Int;

	public var destTrue(default, null):Int;
	public var destFalse(default, null):Int;

	public var business(default, null) = 0;

	public function new(data:String, superWorry = false) {
		var pattern = ~/Monkey (\d+):\s+Starting items: ([\d ,]+\s+Operation: new = old ([+\-*\/])) (old|\d+)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d+)\s+If false: throw to monkey (\d+)/;
		if (pattern.match(data)) {
			/*
				0: Full string
				1: Monkey ID
				2: List of starting items
				3: Operand
				4: Second value
				5: Test condition
				6: If true dest
				7: If false dest
			 */
			id = Std.parseInt(pattern.matched(1));
			items = pattern.matched(2).split(", ").map(Std.parseInt).map(Int64.ofInt);

			var rhs = pattern.matched(4);
			worryOp = switch (pattern.matched(3)) {
				case "+": Add(Std.parseInt(rhs));
				case "*": rhs == "old" ? Square : Mult(Std.parseInt(rhs));
				case x: throw 'Invalid operand $x for monkey $id';
			}

			this.superWorry = superWorry;

			testDivisor = Std.parseInt(pattern.matched(5));
			destTrue = Std.parseInt(pattern.matched(6));
			destFalse = Std.parseInt(pattern.matched(7));
		} else
			throw 'Invalid data for ${data.split("\n").shift()}';
	}

	public function checkAndChuck():Null<Throw> {
		var item = items.shift();
		if (item == null)
			return null;
		business++;

		var newWorry = worryOp.apply(item);
		if (!superWorry)
			newWorry = newWorry / 3;

		return {
			item: newWorry,
			dest: newWorry % testDivisor == 0 ? destTrue : destFalse
		};
	}

	public inline function give(item:Int64)
		items.push(item);

	public inline function toString()
		return 'Monkey $id:
  Current items: ${items.join(", ")}
  Operation: new = $worryOp
  Test: divisible by $testDivisor
    If true: throw to monkey $destTrue
    If false: throw to monkey $destFalse
  Amount of business: $business';
}

private class MonkeyGroup {
	public var monkeys(get, null):Array<Monkey>;

	var mod:Int64 = 1;

	public function new(data:String, superWorry = false) {
		monkeys = data.rtrim().split("\n\n").map(i -> new Monkey(i, superWorry));
		for (monkey in monkeys)
			mod *= monkey.testDivisor;
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
				findMonkey(throwData.dest).give(throwData.item % mod);
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
				expected: []//[Int64.ofInt(10605), Int64.fromFloat(2713310158)]
			}
		});
		new Day11_2(data, 11, tests);
	}

	function problem1(data:String) {
		var group = new MonkeyGroup(data);
		// Sys.println(group.toString());
		// if (Sys.getChar(false) == 3)
		//   return null;
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
		var group = new MonkeyGroup(data, true);
		// var test = [
		// 	[2, 4, 3, 6],
		// 	[99, 97, 8, 103],
		// 	[5204, 4792, 199, 5192],
		// 	[10419, 9577, 392, 10391],
		// 	[15638, 14358, 587, 15593]
		// ], testPoints = [0, 19, 999, 1999, 2999];
		for (x in 0...10000) {
			group.runRound();
			// if (testPoints.contains(x)) {
			// 	var good = true;
			// 	var testGroup = test[testPoints.indexOf(x)],
			// 		testBusiness = group.monkeys.map(i -> i.business);
			// 	for (y => testNum in testGroup)
			// 		try
			// 			Sure.sure(testBusiness[y] == testNum)
			// 		catch (e:Exception) {
			// 			Sys.println(e.message);
			// 			good = false;
			// 		}
			// 	if (!good) {
			// 		Sys.println('$testGroup (exp.) did not match $testBusiness (act.) at round ${x + 1}');
			// 		return null;
			// 	}
			// }
		}

		var business = group.monkeys.map(i -> i.business);
		//trace(business);
		ArraySort.sort(business, (lhs, rhs) -> lhs - rhs);

		return Int64.ofInt(business.pop()) * Int64.ofInt(business.pop());
	}
}
