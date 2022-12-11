/**--------- INCOMPLETE ----------**/

package y2022;

import haxe.ds.ArraySort;
import Sure.sure;

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

abstract HugeNumber(Array<Int>) {
	public function new(num:Array<Int>) {
		this = num;
	}

	inline function getThis() return this.slice(0);

	@:op(a + b)
	public static function addHuge(lhs:HugeNumber, rhs:HugeNumber) {
		var lhsStack = lhs.getThis(), rhsStack = rhs.getThis();
		var newThis:Array<Int> = [];
		var carry = 0;
		
		while (lhsStack.length > rhsStack.length) rhsStack.unshift(0);
		while (rhsStack.length > lhsStack.length) lhsStack.unshift(0);
		while (lhsStack.length > 0) { // these should be the same length now
			var newSeg = lhsStack.pop() + rhsStack.pop() + carry;
			carry = Math.floor(newSeg / 1000);
			newThis.unshift(newSeg % 1000);
		}
		if (carry > 0) newThis.unshift(carry);
		return new HugeNumber(newThis);
	}

	@:op(a + b)
	public static function addInt(lhs:HugeNumber, rhs:Int)
		return HugeNumber.addHuge(lhs, HugeNumber.fromInt(rhs));

	@:op(a * b)
	public static function multHuge(lhs:HugeNumber, rhs:HugeNumber) {
		var lhsStack = lhs.getThis(), rhsStack = rhs.getThis();
		var addBatch:Array<HugeNumber> = [];
		
		lhsStack.reverse();
		rhsStack.reverse();
		for (x => lseg in lhsStack) {
			var carry = 0;
			var op = [for (_ in 0...x) 0];
			for (rseg in rhsStack) {
				var newSeg = (lseg * rseg) + carry;
				carry = Math.floor(newSeg / 1000);
				op.unshift(newSeg % 1000);
			}
			if (carry > 0) op.unshift(carry);
			addBatch.push(new HugeNumber(op));
		}

		var retval = addBatch.shift();
		while (addBatch.length > 0) retval += addBatch.shift();
		return retval;
	}

	@:op(a * b)
	public static function multInt(lhs:HugeNumber, rhs:Int)
		return HugeNumber.multHuge(lhs, HugeNumber.fromInt(rhs));

	@:op(a / b)
	public static function divHuge(lhs:HugeNumber, rhs:Int) {
		// we're just gonna deal with dividing by ints here 'cause that's all we need to do for this puzzle
		var newThis:Array<Int> = [];

		var mod = 0;
		for (lseg in lhs.getThis()) {
			var oseg = lseg + (mod * 1000);
			newThis.push(Math.floor(oseg / rhs));
			mod = oseg % rhs;
		}
		while (newThis[0] == 0) newThis.shift();
		return new HugeNumber(newThis);
	}

	@:op(a % b)
	public static function modHuge(lhs:HugeNumber, rhs:Int) {
		var mod = 0;
		for (lseg in lhs.getThis()) {
			mod = (lseg + (mod * 1000)) % rhs;
		}
		return mod;
	}

	@:from
	public static function fromInt(num:Int) {
		var stack:Array<Int> = [];
		while (num > 0) {
			stack.unshift(num % 1000);
			num = Math.floor(num / 1000);
		}
		return new HugeNumber(stack);
	}

	@:to
	public inline function toString()
		return this.length == 0 ? "0" : Std.string(this[0]) + "," + this.slice(1).map(i -> Std.string(i).lpad("0", 3)).join(",");
}

typedef ISuperMod = {
	var mod:Int;
	var stack:Array<Int>;
}

//@:forward
abstract SuperMod(ISuperMod) from ISuperMod {
	public var mod(get, never):Int;
	public var stack(get, never):Array<Int>;

	public function new(mod:Int, stack:Array<Int>) {
		this = {
			mod: mod,
			stack: stack
		};
	}

	inline function get_mod() return this.mod;
	inline function get_stack() {
		if (this.stack.length == 0) return [0];
		return this.stack.slice(0);
	}

	inline function getThis() return {
		mod: this.mod,
		stack: this.stack.slice(0)
	};

	@:op(a + b)
	public static function addHuge(lhs:SuperMod, rhs:SuperMod) {
		if (lhs.mod != rhs.mod) throw 'Unequal mods';
		var lhsStack = lhs.stack, rhsStack = rhs.stack;
		var newThis:Array<Int> = [];
		var carry = 0;
		
		while (lhsStack.length > rhsStack.length) rhsStack.unshift(0);
		while (rhsStack.length > lhsStack.length) lhsStack.unshift(0);
		while (lhsStack.length > 0) {
			var newSeg = lhsStack.pop() + rhsStack.pop() + carry;
			carry = Math.floor(newSeg / lhs.mod);
			newThis.unshift(newSeg % lhs.mod);
		}
		if (carry > 0) newThis.unshift(carry);
		return new SuperMod(lhs.mod, newThis);
	}

	@:op(a + b)
	public static function addInt(lhs:SuperMod, rhs:Int)
		return SuperMod.addHuge(lhs, SuperMod.fromInt(lhs.mod, rhs));

	@:op(a * b)
	public static function multHuge(lhs:SuperMod, rhs:SuperMod) {
		if (lhs.mod != rhs.mod) throw 'Unequal mods';
		var lhsStack = lhs.stack, rhsStack = rhs.stack;
		var addBatch:Array<SuperMod> = [];
		
		lhsStack.reverse();
		rhsStack.reverse();
		for (x => lseg in lhsStack) {
			var carry = 0;
			var op = [for (_ in 0...x) 0];
			for (rseg in rhsStack) {
				var newSeg = (lseg * rseg) + carry;
				carry = Math.floor(newSeg / lhs.mod);
				op.unshift(newSeg % lhs.mod);
			}
			if (carry > 0) op.unshift(carry);
			addBatch.push(new SuperMod(lhs.mod, op));
		}

		var retval = addBatch.shift();
		while (addBatch.length > 0) retval += addBatch.shift();
		return retval;
	}

	@:op(a * b)
	public static function multInt(lhs:SuperMod, rhs:Int)
		return SuperMod.multHuge(lhs, SuperMod.fromInt(lhs.mod, rhs));

	@:op(a / b)
	public static function divHuge(lhs:SuperMod, rhs:Int) {
		var newThis:Array<Int> = [];

		var mod = 0;
		for (lseg in lhs.stack) {
			var oseg = lseg + (mod * lhs.mod);
			newThis.push(Math.floor(oseg / rhs));
			mod = oseg % rhs;
		}
		while (newThis[0] == 0) newThis.shift();
		return new SuperMod(lhs.mod, newThis);
	}

	@:op(a % b)
	public static function modHuge(lhs:SuperMod, rhs:Int) {
		var mod = 0;
		for (lseg in lhs.stack) {
			mod = (lseg + (mod * lhs.mod)) % rhs;
		}
		return mod;
	}

	public inline function isDivisible(rhs:Int)
		return stack[stack.length - 1] % rhs == mod % rhs;

	//@:from
	public static function fromInt(mod:Int, num:Int) {
		var stack:Array<Int> = [];
		while (num > 0) {
			stack.unshift(num % mod);
			num = Math.floor(num / mod);
		}
		return new SuperMod(mod, stack);
	}

	@:to
	public function toHugeNumber() {
		var revstack = stack;
		var retval = new HugeNumber([0]);
		revstack.reverse();
		while (revstack.length > 0) {
			retval *= mod;
			retval += revstack.shift();
		}
		return retval;
	}

	@:to
	public inline function toString()
		//return this.length == 0 ? "0" : Std.string(this[0]) + "," + this.slice(1).map(i -> Std.string(i).lpad("0", 3)).join(",");
		return toHugeNumber().toString();
}

enum WorryOp {
	Add(lhs:Null<SuperMod>, rhs:Null<SuperMod>);
	Mult(lhs:Null<SuperMod>, rhs:Null<SuperMod>);
	None;
}

typedef Throw = {
	var item:SuperMod;
	var dest:Int;
}

class Monkey {
	public var id(default, null):Int;

	var convArray:Array<Int> = [];
	var convOp:Array<String> = [];

	var items:Array<SuperMod> = [];
	var worryOp:WorryOp = None;
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
			convArray = pattern.matched(2).split(", ").map(Std.parseInt);
			convOp = [for (x in 3...6) pattern.matched(x)];

			//var lhs = pattern.matched(3), rhs = pattern.matched(5);
			this.superWorry = superWorry;

			testDivisor = Std.parseInt(pattern.matched(6));
			destTrue = Std.parseInt(pattern.matched(7));
			destFalse = Std.parseInt(pattern.matched(8));
		} else
			throw 'Invalid data for ${data.split("\n").shift()}';
	}

	public function setMod(mod:Int) {
		for (item in convArray) items.push(SuperMod.fromInt(mod, item));
		var lhs = convOp[0], rhs = convOp[2];
		worryOp = switch(convOp[1]) {
			case "+": Add(lhs == "old" ? null : SuperMod.fromInt(mod, Std.parseInt(lhs)), rhs == "old" ? null : SuperMod.fromInt(mod, Std.parseInt(lhs)));
			case "*": Mult(lhs == "old" ? null : SuperMod.fromInt(mod, Std.parseInt(rhs)), rhs == "old" ? null : SuperMod.fromInt(mod, Std.parseInt(rhs)));
			case x: throw 'Invalid operand $x for monkey $id';
		}
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
			case None:
				throw 'Did not call setMod';
		};
		if (!superWorry)
			newWorry = newWorry / 3;

		return {
			item: newWorry,
			dest: newWorry.isDivisible(testDivisor) ? destTrue : destFalse
		};
	}

	public inline function give(item:SuperMod)
		items.push(item);

	public inline function toString()
		return
			'Monkey $id:\n  Current items: ${items.join(", ")}\n  Operation: new = $worryOp\n  Test: divisible by $testDivisor\n    If true: throw to monkey $destTrue\n    If false: throw to monkey $destFalse';
}

class MonkeyGroup {
	public var monkeys(get, null):Array<Monkey>;

	public function new(data:String, superWorry = false) {
		monkeys = data.rtrim().split("\n\n").map(i -> new Monkey(i));
	}

	public function setMod(mod:Int) {
		for (monkey in monkeys) monkey.setMod(mod);		
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

class Day11 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: ["10,605", "2,713,310,158"]
			}
		});
		new Day11(data, 11, tests);
	}

	function problem1(data:String) {
		var group = new MonkeyGroup(data);
		var mod = 1;
		for (monkey in group.monkeys) mod *= monkey.testDivisor;
		group.setMod(mod);
		for (_ in 0...20)
			group.runRound();

		var business = group.monkeys.map(i -> i.business);
		trace(business);
		ArraySort.sort(business, (lhs, rhs) -> lhs - rhs);

		// Sys.println(group.toString());
		return Std.string(HugeNumber.fromInt(business.pop()) * HugeNumber.fromInt(business.pop()));
	}

	function problem2(data:String) {
		return null;
		var group = new MonkeyGroup(data, true);
		for (x in 0...10000){
			if (x % 100 == 0) Sys.println('Round $x');
			group.runRound();
		}

		var business = group.monkeys.map(i -> i.business);
		ArraySort.sort(business, (lhs, rhs) -> lhs - rhs);

		Sys.println(group.toString());
		return Std.string(HugeNumber.fromInt(business.pop()) * HugeNumber.fromInt(business.pop()));
	}

	function test() {
		var huge1 = HugeNumber.fromInt(1234567);
		var huge2 = HugeNumber.fromInt(7654321);
		sure(Std.string(huge1 * huge2) == "9,449,772,114,007");

		var huge3 = HugeNumber.fromInt(8465193);
		sure(Std.string(huge3 / 3) == "2,821,731");

		var huge4 = HugeNumber.fromInt(8279564);
		sure(huge4 % 5 == 4);
	}
}
