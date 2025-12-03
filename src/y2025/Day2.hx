package y2025;

import helder.Set;
import haxe.Int64;
import haxe.Int64Helper;

using StringTools;

private var testData = [
	'11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124'
];

private typedef D2Range = {
	start:String,
	end:String
}

class Day2 extends DayEngine {
	private static var PrimesPlusOne = [1, 2, 3, 5, 7, 11, 13, 17];

	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [Int64.ofInt(1227775554), Int64.parseString("4174379265")]
			}
		});
		new Day2(data, 2, tests);
	}

	function parse(data:String):Array<D2Range>
		return data.rtrim().split(",").map(i -> {
			var split = i.split("-");
			return {
				start: split[0],
				end: split[1]
			};
		});

	function problem1(data:String) {
		var list = parse(data);
		var total:Int64 = 0;
		for (item in list) {
			var slen = item.start.length,
				shalf = Math.floor(slen / 2),
				slimit = Math.round(Math.pow(10, Math.ceil(slen / 2)));
			var elen = item.end.length, ehalf = Math.floor(elen / 2);
			var sx = Std.parseInt(item.start.substring(0, shalf)),
				sy = Std.parseInt(item.start.substring(shalf));
			var ex = Std.parseInt(item.end.substring(0, ehalf)),
				ey = Std.parseInt(item.end.substring(ehalf));
			var hasFoundInvalid = false;

			// trace('Start comparing ${item.start} ($sx $sy:$slen $shalf $slimit) to ${item.end} ($ex $ey:$elen $ehalf)');

			while (slen < elen || sx < ex || (sx == ex && sy <= ey)) {
				if (slen % 2 == 0 && sx == sy) {
					hasFoundInvalid = true;
					// trace('$sx${Std.string(sy).lpad('0', shalf)} is invalid');
					total += Int64Helper.parseString('$sx${Std.string(sy).lpad('0', shalf)}');
				}
				sy++;
				if (sy >= slimit) {
					// trace('rounding $sy ($slimit)');
					sy -= slimit;
					var oldlen = Std.string(sx++).length;
					if (sx >= slimit) {
						// trace('shifting middle point $sx $sy');
						sy += slimit * (sx % 10);
						sx = Math.floor(sx / 10);
						slimit *= 10;
						slen++;
						shalf++;
						hasFoundInvalid = false;
					} else if (Std.string(sx).length > oldlen)
						slen++;
				}
				if (hasFoundInvalid)
					sx++;
			}
			// trace('$debugFoundInvalid invalid found');
		}
		return total;
	}

	function problem2(data:String) {
		var list = parse(data);
		var total:Int64 = 0;
		var ids = new Set<String>(); // prevent duplicates

		for (item in list) {
			var slen = item.start.length, elen = item.end.length;
			//trace('Testing ${item.start}-${item.end}');
			for (seglen in 1...Math.ceil(elen / 2) + 1) { 
				// trace('Testing ${item.start} with slices of $seglen');
				if (slen < seglen)
					break;
				if (slen % seglen != 0 && elen % seglen != 0)
					continue;

				function split(num:String, chars:Int) {
					var pnum = num.lpad("0", Math.ceil(num.length / chars) * chars);
					var pos = 0;
					var retval:Array<Int> = [];
					while (pos < pnum.length) {
						retval.push(Std.parseInt(pnum.substring(pos, pos + chars)));
						pos += chars;
					}
					return retval;
				}

				function compare(lhs:Array<Int>, rhs:Array<Int>) {
					if (lhs.length < rhs.length)
						return 1;
					if (lhs.length > rhs.length)
						return -1;
					for (x in 0...lhs.length) {
						if (lhs[x] < rhs[x])
							return 1;
						if (lhs[x] > rhs[x])
							return -1;
					}
					return 0;
				}

				var pos:Array<Int> = split(item.start, seglen),
					end:Array<Int> = split(item.end, seglen);
				var poslen = pos.length;
				var limit = Math.round(Math.pow(10, seglen));
				var match = 1;
				// trace(pos, end, compare(pos, end));

				while (compare(pos, end) >= 0) {
					// trace(pos, pos[poslen - match], pos[poslen - match - 1], pos[poslen - match] == pos[poslen - match - 1]);
					while (match < poslen && pos[poslen - match] == pos[poslen - match - 1])
						match++;
					if (match > 1 && match == poslen && Std.string(pos[0]).length == seglen && !ids.exists(pos.join(""))) {
						//trace('${pos.join("")} is invalid');
						ids.add(pos.join(""));
					}
					for (x in 1...match + 1)
						pos[poslen - x] = (pos[poslen - x] + 1) % limit;
					if (pos[poslen - 1] == 0) {
						if (match == poslen) {
							pos.unshift(1);
							poslen++;
						} else
							pos[poslen - match - 1]++;
					}
				}
			}
		}
		for (id in ids)
			total += Int64Helper.parseString(id);
		return total;
	}
}
