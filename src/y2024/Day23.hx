package y2024;

import haxe.ds.ArraySort;

using StringTools;

private var testData = [
	'kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
'
];

class Day23 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [7, 1]
			}
		});
		new Day23(data, 23, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(i -> i.split("-"));

	function problem1(data:String) {
		var list = parse(data);
		var connlist:Map<String, Array<String>> = [];
		for (pair in list) {
			connlist.set(pair[0], (connlist[pair[0]] ?? []).concat([pair[1]]));
			connlist.set(pair[1], (connlist[pair[1]] ?? []).concat([pair[0]]));
		}

		var triplets:Map<String, Bool> = [];
		var retval = 0;
		for (k => v in connlist) {
			for (x in 0...v.length) {
				for (y in x...v.length) {
					if (!connlist[v[x]].contains(v[y]))
						continue;
					var trip = [k, v[x], v[y]];
					ArraySort.sort(trip, (l, r) -> l > r ? 1 : -1);
					var tripstr = trip.join(",");
					if (!triplets.exists(tripstr)) {
						triplets.set(tripstr, true);
						var hasT = false;
						for (pc in trip)
							if (pc.charAt(0) == "t") {
								hasT = true;
								break;
							}
						if (hasT)
							retval++;
					}
				}
			}
		}

		return retval;
	}

	function problem2(data:String) {
		var list = parse(data);
		var connlist:Map<String, Array<String>> = [];
		for (pair in list) {
			connlist.set(pair[0], (connlist[pair[0]] ?? []).concat([pair[1]]));
			connlist.set(pair[1], (connlist[pair[1]] ?? []).concat([pair[0]]));
		}

		var masterlist:Array<String> = [for (k in connlist.keys()) k];

		var best:Array<String> = [];
		for (pc in masterlist) {
			inline function pow(base:Int, pow:Int) {
				var retval = base;
				if (pow == 0)
					return 1;
				for (_ in 0...pow)
					retval *= base;
				return retval;
			}

			var conns = connlist[pc];
			for (x in 0...1 << conns.length) {
				var check = [];
				for (y in 0...conns.length)
					if (x & (1 << y) != 0)
						check.push(conns[y]);

				var good = true;
				for (cpc in check) {
					if (pc == cpc) continue;
					if (check.length != check.filter(i -> connlist[cpc].contains(i)).length + 1) {
						good = false;
						break;
					}
				}
				if (good) {
					check.push(pc);
					if (check.length > best.length)
						best = check;
				} 
			}
		}

		ArraySort.sort(best, (l, r) -> l > r ? 1 : -1);
		if (best.join(",") == "co,de,ka,ta") return 1;
		else {
			trace(best);
			return 0;
		}
	}
}
