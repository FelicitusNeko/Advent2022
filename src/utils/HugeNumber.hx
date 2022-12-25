package utils;

using StringTools;

abstract HugeNumber(Array<Int>) {
	public function new(num:Array<Int>) {
		this = num;
	}

	inline function getThis() return this.slice(0);

	public function clone()
		return new HugeNumber(this.slice(0));

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

	@:op(a > b)
	public static function gtHuge(lhs:HugeNumber, rhs:HugeNumber) {
		var lhst = lhs.getThis(), rhst = rhs.getThis();
		if (lhst.length > rhst.length) return true;
		if (lhst.length < rhst.length) return false;

		for (x in 0...lhst.length) {
			if (lhst[x] > rhst[x]) return true;
			if (lhst[x] < rhst[x]) return false;
		}

		return false;
	}

	@:op(a > b)
	public static function gtInt(lhs:HugeNumber, rhs:Int)
		return gtHuge(lhs, fromInt(rhs));

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
