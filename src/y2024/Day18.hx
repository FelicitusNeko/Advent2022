package y2024;

import utils.Direction;
import utils.Point;

using StringTools;

private var testData = [
	'5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0'
];

class Day18 extends DayEngine {
	static var dirs:Array<Direction> = [Right, Down, Left, Up];

	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [22, 601]
			}
		});
		new Day18(data, 18, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(Point.fromString);

	function problem1(data:String) {
		var list = parse(data);
		var br:Point = [0, 0];
		var map:Map<String, Null<Int>> = ["0:0" => 0];
		var queue:Array<Point> = [[0, 0]];

		var limit = list.length < 40 ? 12 : 1024;
		for (x => pt in list) {
			if (pt.x > br.x)
				br.x = pt.x;
			if (pt.y > br.y)
				br.y = pt.y;
			if (x < limit)
				map.set(pt, null);
		}

		while (queue.length > 0) {
			var pt = queue.pop();
			var score = map[pt];
			if (score == null || pt == br)
				continue;

			for (dir in dirs) {
				var chk = dir.applyToNewPoint(pt);
				if (chk.x < 0 || chk.y < 0 || chk.x > br.x || chk.y > br.y)
					continue;
				var exist = map.exists(chk);
				if (!exist || (exist && map[chk] != null && map[chk] > score + 1)) {
					map[chk] = score + 1;
					queue.push(chk);
				}
			}
		}

		return cast(map[br]);
	}

	function problem2(data:String) {
		var list = parse(data);
		var br:Point = [0, 0];
		var map:Map<String, Bool> = ["0:0" => true];

		var start = list.length < 40 ? 12 : 1024;
		for (x => pt in list) {
			if (pt.x > br.x)
				br.x = pt.x;
			if (pt.y > br.y)
				br.y = pt.y;
			if (x < start)
				map.set(pt, false);
		}

		for (x in start...list.length) {
			var queue:Array<Point> = [[0, 0]];
			map[list[x]] = false;
			var cmap = map.copy();

			while (queue.length > 0) {
				var pt = queue.pop();
				if (cmap[pt] == null || pt == br)
					continue;
	
				for (dir in dirs) {
					var chk = dir.applyToNewPoint(pt);
					if (chk.x < 0 || chk.y < 0 || chk.x > br.x || chk.y > br.y){
						continue;}
					if (!cmap.exists(chk)) {
						cmap[chk] = true;
						if (chk == br) { queue = []; break; }
						else queue.push(chk);
					}
				}
			}

			if (cmap[br] != true) return list[x].x * 100 + list[x].y;
			// NOTE: submit this answer as "xx,yy"
			// returning an int here so type can unify with first part
		}

		return 0;
	}
}
