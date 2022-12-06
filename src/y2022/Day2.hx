package y2022;

import haxe.Exception;

using StringTools;

var testData = [
	'A Y
B X
C Z
'
];

enum abstract RPSSymbol(Int) to Int {
	var Rock = 1;
	var Paper = 2;
	var Scissors = 3;

	@:to
	public function toString()
		return switch (this) {
			case 1: "Rock";
			case 2: "Paper";
			case 3: "Scissors";
			default: throw new Exception('Invalid value $this for throw');
		}
}

enum abstract RPSResult(Int) to Int {
	var Lose = 0;
	var Draw = 3;
	var Win = 6;

	@:to
	public function toString()
		return switch (this) {
			case 0: "Loss";
			case 3: "Draw";
			case 6: "Win";
			default: throw new Exception('Invalid value $this for result');
		}
}

enum OtherIs {
	Me;
	Result;
}

typedef IRPSShoot = {
	var you:RPSSymbol;
	var other:String;
	var otherIs:OtherIs;
}

@:forward(you)
abstract RPSShoot(IRPSShoot) from IRPSShoot {
	public function new(you:RPSSymbol, other:String, otherIs:OtherIs) {
		this = {you: you, other: other, otherIs: otherIs};
	}

	public var me(get, never):RPSSymbol;
	public var result(get, never):RPSResult;
	public var score(get, never):Int;

	public static function fromData(data:String, otherIs:OtherIs) {
		var symbols = ~/^([A-C]) ([X-Z])$/;

		if (symbols.match(data))
			return new RPSShoot(switch (symbols.matched(1)) {
				case "A": Rock;
				case "B": Paper;
				case "C": Scissors;
				default: throw new Exception('Invalid [you] symbol ${symbols.matched(1)}');
			}, symbols.matched(2), otherIs);
		else
			throw new Exception('Invalid RPS data "$data"');
	}

	@:to
	public function toString()
		return 'Your ${this.you} vs my ${me} results in a ${result} for ${score} point(s)';

	function get_me() {
		if (this.otherIs == Me)
			return switch (this.other) {
				case "X": Rock;
				case "Y": Paper;
				case "Z": Scissors;
				default: throw new Exception('Invalid [me] symbol ${this.other}');
			}
		else {
			var you:Int = this.you;
			var me = switch (result) {
				case Draw: you;
				case Win: you % 3 + 1;
				case Lose: you == 1 ? 3 : you - 1;
				default: throw new Exception('Invalid result value ${result}');
			}
			return cast(me, RPSSymbol);
		};
	}

	function get_result() {
		if (this.otherIs == Result)
			return switch (this.other) {
				case "X": Lose;
				case "Y": Draw;
				case "Z": Win;
				default: throw new Exception('Invalid [result] symbol ${this.other}');
			}
		else if (this.you == me)
			return Draw;
		else if (this.you - 1 == me % 3)
			return Lose;
		else if (me - 1 == this.you % 3)
			return Win;
		else
			throw new Exception('Invalid result while trying to evalulate ${this.you} vs ${me}');
	}

	function get_score()
		return 0 + me + result;
}

class Day2 extends DayEngine {
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [15, 12]
			}
		});
		new Day2(data, 2, tests);
	}

	function problem1(data:String) {
		var shoots = data.trim().split("\n").map(d -> RPSShoot.fromData(d, Me));
		var total = 0;
		for (shoot in shoots)
			total += shoot.score;
		return total;
	}

	function problem2(data:String) {
		var shoots = data.trim().split("\n").map(d -> RPSShoot.fromData(d, Result));
		var total = 0;
		for (shoot in shoots)
			total += shoot.score;
		return total;
	}
}
