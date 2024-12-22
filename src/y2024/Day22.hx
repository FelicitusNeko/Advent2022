package y2024;

import haxe.io.Bytes;
import haxe.Int64;
import haxe.Int64Helper;

using StringTools;

private var testData = [
	'1
10
100
2024
'
];

class Day22 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: '1
10
100
2024
',
				expected: [37327623]
			},
			{
				data: '1
2
3
2024
',
				expected: [null, 23]
			}
		];
		new Day22(data, 22, tests);
	}

	inline function mix(base:Int64, xor:Int64)
		return base ^ xor;

	inline function prune(base:Int64)
		return base % 16777216;

	function parse(data:String)
		return data.rtrim().split("\n").map(Int64Helper.parseString);

	function problem1(data:String) {
		var retval:Int64 = 0;
		for (seed in parse(data)) {
			var val = seed;
			for (_ in 0...2000) {
				val = prune(mix(val, val * 64));
				val = prune(mix(val, val / 32));
				val = prune(mix(val, val * 2048));
			}
			retval += val;
		}
		if (Int64.neq(retval, 37327623))
			Sys.println('WORKAROUND: Use this response → $retval'); // use the value this outputs as the solution
		return retval.low;
	}

	function problem2(data:String) {
		var retval:Int64 = 0;
		var cache:Map<String, Int> = [];
		var b:Array<Int> = [];

		for (z => seed in parse(data)) { // for each seed in the list
			var used:Map<String, Bool> = []; // since we can only use the first instance of a set of four deltas
			var val = seed; // the seed for the generator
			var cur = (seed % 10).low; // the starting price is based on the seed
			b = []; // reset the byte list

			for (_ in 0...2000) { // for 2000 iterations
				val = prune(mix(val, val * 64)); // xor val on val*64 and truncate to last 24 bits
				val = prune(mix(val, val / 32)); // xor val on floor(val/32) and truncate to last 24 bits
				val = prune(mix(val, val * 2048)); // xor val on val*2048 and truncate to last 24 bits

				//1000000000000000000000000
				var nv = (val % 10).low; // get the last digit
				var delta = nv - cur; // measure the change since the last price
				cur = nv; // the new price is now current
				b.push(delta); // push the byte onto the stack
				if (b.length > 4)
					b.shift(); // never keep more than four
				if (b.length == 4) { // if we have four
					var dstr = b.join(","); // join them into a string
					if (!used.exists(dstr)) { // if we haven't used this combination from this seed
						used.set(dstr, true); // say we did
						cache.set(dstr, (cache[dstr] ?? 0) + cur); // add this tally to the cache
					}
				}
			}
		}

		var best = 0; // highest number of bananas for a four-byte sequence of deltas
		for (k => v in cache) { // for each cached tally
			if (v > best)  // if this is the highest tally we've seen
				best = v; // keep track of it
		}

		return best;
	}
}
