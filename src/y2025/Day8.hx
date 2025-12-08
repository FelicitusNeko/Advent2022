package y2025;

import haxe.ds.ArraySort;
import haxe.DynamicAccess;
import utils.Point3D;
using StringTools;

private var testData = ['162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
'];

private typedef D8Chart = {
	src:Point3D,
	dest:Point3D,
	dist:Float
}

class Day8 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [40, 25272]
			}
		});
		new Day8(data, 8, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(Point3D.ofString);

	function problemCommon(data:String, part2:Bool) {
		var list = parse(data);
		var ref:DynamicAccess<Int> = {}, dists:Array<D8Chart> = [], groups:Map<Int, Array<Point3D>> = [];
		for (x => point in list) {
			ref[point] = x;
			groups[x] = [point];
		}
		for (x => src in list.slice(0, -1)) for (y => dest in list.slice(x+1))
			dists.push({
				src: src,
				dest: dest,
				dist: src.euclidean(dest)
			});
		ArraySort.sort(dists, (x, y) -> {
			if (x.dist > y.dist) return 1;
			if (x.dist < y.dist) return -1;
			return 0;
		});

		for (i => dist in dists) {
			if (!part2 && i >= (list.length == 20 ? 10 : 1000))
				break;
			
			var mergeFrom = ref[dist.src], mergeTo = ref[dist.dest];
			if (mergeFrom == mergeTo) continue;
			groups[mergeFrom] = groups[mergeFrom].concat(groups[mergeTo]);
			for (pt in groups[mergeTo]) ref[pt] = mergeFrom;
			groups.remove(mergeTo);

			if (part2 && [for (x in groups.keys()) x].length == 1)
				return dist.src.x * dist.dest.x;
		}

		if (!part2) {
			var top = [for (x in groups) x.length];
			ArraySort.sort(top, (x, y) -> y - x);
	
			return top[0] * top[1] * top[2];
		}
		else return -1;
	}

	function problem1(data:String) 
		return problemCommon(data, false);

	function problem2(data:String)
		return problemCommon(data, true);
}
