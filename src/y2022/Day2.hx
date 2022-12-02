package y2022;

import haxe.Exception;

using StringTools;

enum abstract RPSSymbol(Int) {
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

enum abstract RPSResult(Int) {
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

typedef IRPSShoot = {
	var you:RPSSymbol;
	var me:RPSSymbol;
}

@:forward
abstract RPSShoot(IRPSShoot) from IRPSShoot {
	public function new(you:RPSSymbol, me:RPSSymbol) {
		this = {you: you, me: me};
	}

	public var result(get, never):RPSResult;
	public var score(get, never):Int;

	@:from
	public static function fromString(data:String) {
		var symbols = ~/^([A-C]) ([X-Z])$/;

		if (symbols.match(data))
			return new RPSShoot(switch (symbols.matched(1)) {
				case "A": Rock;
				case "B": Paper;
				case "C": Scissors;
				default: throw new Exception('Invalid [you] symbol ${symbols.matched(1)}');
			}, switch (symbols.matched(2)) {
				case "X": Rock;
				case "Y": Paper;
				case "Z": Scissors;
				default: throw new Exception('Invalid [me] symbol ${symbols.matched(2)}');
			});
		else
			throw new Exception('Invalid RPS data "$data"');
	}

	@:to
	public function toString()
		return 'Your ${this.you} vs my ${this.me} results in a ${result} for ${score} point(s)';

	function get_result() {
		if (this.you == this.me)
			return Draw;
		else if (cast(this.you, Int) - 1 == cast(this.me, Int) % 3)
			return Lose;
		else if (cast(this.me, Int) - 1 == cast(this.you, Int) % 3)
			return Win;
		else
			throw new Exception('Invalid result while trying to evalulate ${this.you} vs ${this.me}');
	}

	function get_score()
		return cast(this.me, Int) + cast(result, Int);
}

typedef IRPSShoot2 = {
	var you:RPSSymbol;
	var result:RPSResult;
}

@:forward
abstract RPSShoot2(IRPSShoot2) from IRPSShoot2 {
	public function new(you:RPSSymbol, result:RPSResult) {
		this = {you: you, result: result};
	}

	public var me(get, never):RPSSymbol;
	public var score(get, never):Int;

	@:from
	public static function fromString(data:String) {
		var symbols = ~/^([A-C]) ([X-Z])$/;

		if (symbols.match(data))
			return new RPSShoot2(switch (symbols.matched(1)) {
				case "A": Rock;
				case "B": Paper;
				case "C": Scissors;
				default: throw new Exception('Invalid [you] symbol ${symbols.matched(1)}');
			}, switch (symbols.matched(2)) {
				case "X": Lose;
				case "Y": Draw;
				case "Z": Win;
				default: throw new Exception('Invalid [result] symbol ${symbols.matched(2)}');
			});
		else
			throw new Exception('Invalid RPS data "$data"');
	}

	@:to
	public function toString()
		return 'Your ${this.you} vs my ${me} results in a ${this.result} for ${score} point(s)';

  function get_me() {
    var you = cast(this.you, Int);
    var me = switch(this.result) {
      case Draw: you;
      case Win: you % 3 + 1;
      case Lose: you == 1 ? 3 : you - 1;
      default: throw new Exception('Invalid result value ${this.result}');
    }
    return cast(me, RPSSymbol);
  }

	function get_score()
		return cast(me, Int) + cast(this.result, Int);
}

class Day2 {
	public static function problem1(data:String) {
		var shoots = data.trim().split("\n").map(d -> RPSShoot.fromString(d));
		var total = 0;
		for (shoot in shoots)
			total += shoot.score;
		return Std.string(total);
	}

	public static function problem2(data:String) {
		var shoots = data.trim().split("\n").map(d -> RPSShoot2.fromString(d));
		var total = 0;
		for (shoot in shoots)
			total += shoot.score;
		return Std.string(total);
	}
}
