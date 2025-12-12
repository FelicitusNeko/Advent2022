package y2025;

using StringTools;

class Day11 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: 'aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
',
				expected: [5]
			},
			{
				data: 'svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
',
				expected: [null, 2]
			}
		];
		new Day11(data, 11, tests);
	}

	function parse(data:String) {
		var retval:Map<String, Array<String>> = [];
		for (line in data.rtrim().split("\n"))
			retval[line.substring(0, 3)] = line.substring(5).split(" ");
		return retval;
	}

	function problem1(data:String) {
		var list = parse(data);

		function travel(path:Array<String>) {
			var here = path[path.length - 1];
			var paths = 0;
			if (!list.exists(here))
				throw 'Invalid location $here';
			for (dest in list[here]) {
				if (dest == "out")
					paths++;
				else if (!path.contains(dest))
					paths += travel(path.concat([dest]));
			}
			return paths;
		}

		return travel(["you"]);
	}

	function problem2(data:String) {
		trace('runs indefinitely'); // TODO: 2025.11.2
		return null;

		var list = parse(data);

		function travel(path:Array<String>, goal = 0) {
			var here = path[path.length - 1];
			var paths = 0;
			if (!list.exists(here))
				throw 'Invalid location $here';
			for (dest in list[here]) {
				if (dest == "out") {
					if (goal == 2)
						paths++;
				} else if (!path.contains(dest)) {
					paths += travel(path.concat([dest]), goal + ((dest == "fft" || dest == "dac") ? 1 : 0));
				}
			}
			return paths;
		}

		return cast travel(["svr"]);
	}
}
