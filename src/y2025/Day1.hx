package y2025;

using StringTools;

private var testData = [
	'L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
'
];

private enum D1IDirection {
	Left(n:Int);
	Right(n:Int);
}

private abstract D1Direction(D1IDirection) from D1IDirection to D1IDirection {
	function new(input:D1IDirection)
		this = input;

	public function rotate(start:Int) {
		var retval = (switch this {
			case Left(n): start - n;
			case Right(n): start + n;
		}) % 100;
		while (retval < 0)
			retval += 100;
		return retval;
	}

	public function rotateCarry(start:Int) {
		var retval = switch this {
			case Left(n): start - n;
			case Right(n): start + n;
		};
		//trace('rotating $start ${this.getName()} ${this.getParameters()} to $retval');
		var carry = Math.round(Math.abs(Math.floor(retval / 100)));
		retval %= 100;

		if (this.getName() == "Left" && start == 0)
			carry--;
		if (this.getName() == "Left" && retval == 0)
			carry++;
		while (retval < 0)
			retval += 100;

		// if (carry > 0)
		// 	trace('carrying $carry passes to 0, actual end pos is $retval');
		return [retval, carry];
	}

	@:from
	public static function fromString(input:String) {
		var num = Std.parseInt(input.substring(1));
		return new D1Direction(switch input.charAt(0) {
			case 'L': Left(num);
			case 'R': Right(num);
			case x: throw 'Invalid character $x';
		});
	}
}

class Day1 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [3, 6]
			}
		});
		new Day1(data, 1, tests);
	}

	function parse(data:String)
		return data.rtrim().split("\n").map(i -> D1Direction.fromString(i));

	function problem1(data:String) {
		var list = parse(data);
		var pos = 50;
		var zeroes = 0;
		for (dir in list) {
			pos = dir.rotate(pos);
			if (pos == 0)
				zeroes++;
		}
		return zeroes;
	}

	function problem2(data:String) {
		var list = parse(data);
		var pos = 50;
		var zeroes = 0;
		for (dir in list) {
			var result = dir.rotateCarry(pos);
			pos = result[0];
			zeroes += result[1];
		}
		return zeroes;
	}
}
