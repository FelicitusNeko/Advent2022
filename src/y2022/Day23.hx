package y2022;

import helder.Set;
import utils.Point;
import DayEngine.TestData;

using StringTools;

typedef IElf = {
	var pos:Point;
	var ?dest:Null<Point>;
}

@:forward
abstract Elf(IElf) from IElf {
	public function areAnyAdjacent(elves:Array<Elf>) {
		for (y in -1...2)
			for (x in -1...2) {
				if (x == 0 && y == 0)
					continue;
				if (elves.filter(i -> i.pos == this.pos + {x: x, y: y}).length > 0)
					return true;
			}
		return false;
	}
}

enum IElfDirection {
	North;
	South;
	West;
	East;
}

abstract ElfDirection(IElfDirection) from IElfDirection {
	public function checkDir(elf:Elf, elves:Array<Elf>) {
		var check:Array<Point> = switch (this) {
			case North: [{x: -1, y: -1}, {x: 0, y: -1}, {x: 1, y: -1}];
			case South: [{x: -1, y: 1}, {x: 0, y: 1}, {x: 1, y: 1}];
			case West: [{x: -1, y: -1}, {x: -1, y: 0}, {x: -1, y: 1}];
			case East: [{x: 1, y: -1}, {x: 1, y: 0}, {x: 1, y: 1}];
		}

		for (dest in check.map(i -> elf.pos + i))
			if (elves.filter(i -> i.pos == dest).length > 0)
				return false;

		return true;
	}

	public function apply(elf:Elf)
		elf.dest = elf.pos + switch (this) {
			case North: {x: 0, y: -1};
			case South: {x: 0, y: 1};
			case West: {x: -1, y: 0};
			case East: {x: 1, y: 0};
		}
}

private class ElfMap {
	var elves:Array<Elf> = [];
	var dirs:Array<ElfDirection> = [North, South, West, East];

	public var moves(default, null) = 0;

	public var tl(get, never):Point;
	public var br(get, never):Point;

	public function new(data:String) {
		for (y => line in data.rtrim().split("\n"))
			for (x => ch in line.split(""))
				if (ch == "#")
					elves.push({pos: {x: x, y: y}});
	}

	function get_tl() {
		var x:Int = elves[0].pos.x, y:Int = elves[0].pos.y;

		for (elf in elves) {
			if (x > elf.pos.x)
				x = elf.pos.x;
			if (y > elf.pos.y)
				y = elf.pos.y;
		}

		return {x: x, y: y};
	}

	function get_br() {
		var x:Int = elves[0].pos.x, y:Int = elves[0].pos.y;

		for (elf in elves) {
			if (x < elf.pos.x)
				x = elf.pos.x;
			if (y < elf.pos.y)
				y = elf.pos.y;
		}

		return {x: x, y: y};
	}

	public function step() {
		var dests = new Set<String>();
		var dupeDests = new Set<String>();
		var directed = 0;
		var hasAnyMoved = false;
		var movingElves = elves.filter(i -> i.areAnyAdjacent(elves));

		for (dir in dirs) {
			for (elf in movingElves) {
				if (elf.dest != null)
					continue;
				if (dir.checkDir(elf, elves)) {
					dir.apply(elf);
					if (dests.exists(elf.dest))
						dupeDests.add(elf.dest);
					else
						dests.add(elf.dest);
					directed++;
				}
			}
			if (directed == elves.length)
				break;
			if (directed > elves.length)
				throw 'More elves report as directed than there are actual elves ($directed > ${elves.length})'; // shouldn't happen but just in case
		}

		for (elf in movingElves.filter(i -> i.dest != null)) {
			if (!dupeDests.exists(elf.dest)) {
				elf.pos = elf.dest;
				hasAnyMoved = true;
			}
			elf.dest = null;
		}

		moves++;
		dirs.push(dirs.shift());
		return hasAnyMoved;
	}

	public function minEmptySpace() {
		var tl = this.tl,
			br = this.br,
			elfPos = new Set(elves.map(i -> i.pos.toString()));
		var count = 0;

		for (y in tl.y...br.y + 1)
			for (x in tl.x...br.x + 1)
				if (!elfPos.exists('$x:$y'))
					count++;

		return count;
	}

	public function toString() {
		var tl = this.tl,
			br = this.br,
			elfPos = new Set(elves.map(i -> i.pos.toString()));
		var retval = "";

		for (y in tl.y...br.y + 1) {
			for (x in tl.x...br.x + 1)
				retval += elfPos.exists('$x:$y') ? "#" : ".";
			retval += "\n";
		}

		return retval.trim();
	}
}

class Day23 extends DayEngine {
	public static function make(data:String) {
		var tests:Array<TestData> = [
			{
				data: '.....
..##.
..#..
.....
..##.
.....',
				expected: [25, 4]
			},
			{
				data: '....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..',
				expected: [110, 20]
			}
		];
		new Day23(data, 23, tests);
	}

	function problem1(data:String) {
		var map = new ElfMap(data);
		while (map.step() && map.moves < 10) {}
		return map.minEmptySpace();
	}

	function problem2(data:String) {
		var map = new ElfMap(data);
		while (map.step()) {}
		return map.moves;
	}
}
