package y2024;

import utils.Point;

using StringTools;

private var testData = [
	'............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............'
];

class Day8 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [14, 34]
			}
		});
		new Day8(data, 8, tests);
	}

	static function inBounds(pt:Point, br:Point)
		return pt.x >= 0 && pt.y >= 0 && pt.x < br.x && pt.y < br.y;

	function parse(data:String) {
		var nodes:Map<String, Array<Point>> = [];
		var grid = [for (line in data.rtrim().split('\n')) line.split('')];
		var size:Point = [grid[0].length, grid.length];

		for (y => row in grid)
			for (x => cell in row)
				if (cell != '.') {
					if (nodes.exists(cell))
						nodes[cell].push([x, y]);
					else
						nodes.set(cell, [[x, y]]);
				}

		return {
			nodes: nodes,
			size: size
		};
	}

	function problem1(data:String) {
		var p = parse(data);
		var antinodes:Map<String, Bool> = [];

		for (nodes in p.nodes) {
			for (z => n1 in nodes) {
				for (n2 in nodes.slice(z + 1)) {
					var dist:Point = n1 - n2;
					if (inBounds(n1 + dist, p.size)) antinodes.set(n1 + dist, true);
					if (inBounds(n2 - dist, p.size)) antinodes.set(n2 - dist, true);
				}
			}
		}

		return [for (k in antinodes.keys()) k].length;
	}

	function problem2(data:String) {
		var p = parse(data);
		var antinodes:Map<String, Bool> = [];

		for (nodes in p.nodes) {
			for (z => n1 in nodes) {
				for (n2 in nodes.slice(z + 1)) {
					var dist:Point = n1 - n2;
					var vec = 0;
					var stillok = false;
					do {
						stillok = false;
						var n1vec = n1 + (dist * vec),
							n2vec = n2 - (dist * vec);
						if (inBounds(n1vec, p.size)) {
							antinodes.set(n1vec, true);
							stillok = true;
						}
						if (inBounds(n2vec, p.size)) {
							antinodes.set(n2vec, true);
							stillok = true;
						}
						vec++;
					} while (stillok);
				}
			}
		}

		return [for (k in antinodes.keys()) k].length;
	}
}
