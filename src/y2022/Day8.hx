package y2022;

using StringTools;

private var testData = [
	'30373
25512
65332
33549
35390
'
];

private typedef ID8Tree = {
	var height:Int;
	var visible:Bool;
	var scenic:Int;
}

@:forward
private abstract D8Tree(ID8Tree) from ID8Tree {
	@:to
	public function toString()
		return '${this.height}${this.visible ? "✅" : "❌"} ';
}

private class TreeGrid {
	var grid:Array<Array<D8Tree>> = [];

	public var width(get, never):Int;
	public var height(get, never):Int;
	public var totalVisible(get, never):Int;
	public var bestScenic(get, never):Int;

	public function new(data:String) {
		grid = data.rtrim().split("\n").map(i -> {
			i.split("").map(ii -> {
				return {
					height: Std.parseInt(ii),
					visible: false,
					scenic: 0
				};
			});
		});
	}

	public function scanVisible() {
		for (y in 0...height) {
			var scanHeightLeft = -1, scanHeightRight = -1;
			for (x in 0...width) {
				var ix = width - x - 1;
				if (grid[y][x].height > scanHeightLeft) {
					scanHeightLeft = grid[y][x].height;
					grid[y][x].visible = true;
				}
				if (grid[y][ix].height > scanHeightRight) {
					scanHeightRight = grid[y][ix].height;
					grid[y][ix].visible = true;
				}
			}
		}

		for (x in 0...width) {
			var scanHeightUp = -1, scanHeightDown = -1;
			for (y in 0...height) {
				var iy = height - y - 1;
				if (grid[y][x].height > scanHeightUp) {
					scanHeightUp = grid[y][x].height;
					grid[y][x].visible = true;
				}
				if (grid[iy][x].height > scanHeightDown) {
					scanHeightDown = grid[iy][x].height;
					grid[iy][x].visible = true;
				}
			}
		}
	}

	public function scanScenic() {
		for (y in 1...height - 1) {
			for (x in 1...width - 1) {
				var treehouse = grid[y][x];

				var treetop = -1, count = 0, tally:Array<Int> = [];
				// count northward
				for (z in 1...y + 1) {
					count++;
					if (grid[y - z][x].height >= treehouse.height)
						break;
				}
				tally.push(count);
				treetop = -1;
				count = 0;

				// count westward
				for (z in 1...x + 1) {
					count++;
					if (grid[y][x - z].height >= treehouse.height)
						break;
				}
				tally.push(count);
				treetop = -1;
				count = 0;

				// count southward
				for (z in 1...height - y) {
					count++;
					if (grid[y + z][x].height >= treehouse.height)
						break;
				}
				tally.push(count);
				treetop = -1;
				count = 0;

				// count eastward
				for (z in 1...width - x) {
					count++;
					if (grid[y][x + z].height >= treehouse.height)
						break;
				}
				tally.push(count);

				treehouse.scenic = 1;
				for (mult in tally)
					treehouse.scenic *= mult;
			}
		}
	}

	public function toString() {
		var retval:Array<String> = [];
		for (row in grid)
			retval.push(row.map(i -> Std.string(i)).join(""));
		return retval.join("\n");
	}

	inline function get_width()
		return grid[0].length;

	inline function get_height()
		return grid.length;

	function get_totalVisible() {
		var retval = 0;
		for (row in grid)
			for (tree in row)
				if (tree.visible)
					retval++;
		return retval;
	}

	function get_bestScenic() {
		var retval = 0;
		for (row in grid)
			for (tree in row)
				if (tree.scenic > retval)
					retval = tree.scenic;
		return retval;
	}
}

class Day8 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [21, 8]
			}
		});
		new Day8(data, 8, tests);
	}

	function problem1(data:String) {
		var grid = new TreeGrid(data);
		grid.scanVisible();
		return grid.totalVisible;
	}

	function problem2(data:String) {
		var grid = new TreeGrid(data);
		grid.scanScenic();
		return grid.bestScenic;
	}
}
