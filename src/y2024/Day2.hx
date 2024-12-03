package y2024;

using StringTools;

private var testData = [
	'7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
'
];

private enum IPowerDir {
	Unknown;
	Initial(n:Int);
	Incrementing(n:Int);
	Decrementing(n:Int);
}

private abstract PowerDir(IPowerDir) from IPowerDir to IPowerDir {
	static function safe(l, r) {
		var diff = Math.round(Math.abs(l - r));
		return diff >= 1 && diff <= 3;
	}

	public function next(v:Int):Null<PowerDir>
		return switch (this) {
			case Unknown: Initial(v);
			case Initial(n):
				if (!safe(n, v)) null; else n < v ? Incrementing(v) : Decrementing(v);
			case Incrementing(n):
				if (!safe(n, v) || n > v) null; else Incrementing(v);
			case Decrementing(n):
				if (!safe(n, v) || n < v) null; else Decrementing(v);
		}

	@:to
	function toNullInt() {
		if (this == Unknown)
			return null;
		else
			return cast(this.getParameters()[0], Int);
	}
}

class Day2 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [2, 4]
			}
		});
		new Day2(data, 2, tests);
	}

	function parse(data:String)
		return data.rtrim().split('\n').map(i -> i.split(' ').map(Std.parseInt));

	function problem(data:String, tolerate = false) {
		var list = parse(data);
		var retval = 0;
		for (line in list) {
			for (i in -1...(tolerate ? (line.length) : 0)) {
				var state:PowerDir = Unknown;
				var valid = true;
				for (x => val in line) {
					if (x == i)
						continue;
					var next = state.next(val);
					if (next == null) {
						valid = false;
						break;
					} else
						state = next;
				}

				if (valid) {
					retval++;
					break;
				}
			}
		}
		return retval;
	}

	function problem1(data:String)
		return problem(data, false);

	function problem2(data:String)
		return problem(data, true);
}
