package y2022;

import haxe.Int64;
using StringTools;

var testData = [
	'1
2
-3
3
-2
0
4'
];

typedef MixNumber = {
	var n:Int64;
}

class Day20 extends DayEngine {
	public static final encryptKey = 811589153;

	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [] //[3, 1623178306].map(Int64.ofInt)
			}
		});
		new Day20(data, 20, tests);
	}

	function problem1(data:String) {
		var list:Array<MixNumber> = data.rtrim().split("\n").map(i -> {
			return {n: Int64.ofInt(Std.parseInt(i))}
		}), zero = list.filter(i -> i.n == 0)[0];
		var origOrder = list.slice(0);

		if (zero == null) 'Failed to retrieve zero pointer from list';

		for (i in origOrder) {
			if (i == zero) continue;
				
			var index = list.indexOf(i);
			var mix = list.splice(index, 1)[0];
			if (mix == null)
				throw 'Tried to retrieve item at index $index failed (null)';
			var newIndex = (index + (mix.n % list.length).low) % list.length;
			if (newIndex < 0)
				newIndex += list.length;
			if (newIndex == 0)
				list.push(mix);
			else
				list.insert(newIndex, mix);
		}

		var scanIndex = list.indexOf(zero);
		var total:Int64 = 0;
		for (x in 1...3001) {
			scanIndex = (scanIndex + 1) % list.length;
			if (x % 1000 == 0) total += list[scanIndex].n;
		}

		return total;
	}

	function problem2(data:String) {
		var list:Array<MixNumber> = data.rtrim().split("\n").map(i -> {
			return {n: Int64.ofInt(Std.parseInt(i)) * encryptKey}
		}), zero = list.filter(i -> i.n == 0)[0];
		var origOrder = list.slice(0);

		if (zero == null) 'Failed to retrieve zero pointer from list';

		trace(list.map(i -> i.n));
		for (_ in 0...10) {
			for (i in origOrder) {
				if (i == zero) continue;

				var index = list.indexOf(i);
				var mix = list.splice(index, 1)[0];
				if (mix == null)
					throw 'Tried to retrieve item at index $index failed (null)';
				var newIndex = ((index + mix.n) % list.length).low;
				if (newIndex < 0)
					newIndex += list.length;
				if (newIndex == 0)
					list.push(mix);
				else
					list.insert(newIndex, mix);
			}
		}

		var scanIndex = list.indexOf(zero);
		var total:Int64 = 0;
		for (x in 1...3001) {
			scanIndex = (scanIndex + 1) % list.length;
			if (x % 1000 == 0) total += list[scanIndex].n;
		}

		return total;
	}
}
