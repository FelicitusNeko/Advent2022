package y2015;

import utils.Point;
using StringTools;

private enum ILightDirective {
	TurnOn;
	TurnOff;
	Toggle;
}

private abstract LightDirective(ILightDirective) from ILightDirective {
	function new(value:ILightDirective)
		this = value;

	public function perform1(old:Bool)
		return switch (this) {
			case TurnOn: true;
			case TurnOff: false;
			case Toggle: !old;
		};

	public function perform2(old:Int)
		return Math.round(Math.max((old + switch (this) {
			case TurnOn: 1;
			case TurnOff: -1;
			case Toggle: 2;
		}), 0));

	@:from
	public static function fromString(token:String)
		return new LightDirective(switch(token) {
			case "turn off": TurnOff;
			case "turn on": TurnOn;
			case "toggle": Toggle;
			default: throw 'Unknown directive "$token"';
		});

	@:to
	public function toString()
		return switch(this) {
			case TurnOn: "turn on";
			case TurnOff: "turn off";
			case Toggle: "toggle";
		}
}

private typedef ILightInstruction = {
	var directive:LightDirective;
	var tl:Point;
	var br:Point;
}

@:forward
private abstract LightInstruction(ILightInstruction) from ILightInstruction {
	static var pattern = ~/^(turn o(?:n|ff)|toggle) (\d+,\d+) through (\d+,\d+)$/;

	function new(instr:ILightInstruction)
		this = instr;

	public function perform1(grid:Array<Array<Bool>>) {
		for (y in this.tl.y...this.br.y+1)
			for (x in this.tl.x...this.br.x+1) {
				var pt = new Point(x, y);
				pt.arraySet(grid, this.directive.perform1(pt.arrayGet(grid)));
			}
	}

	public function perform2(grid:Array<Array<Int>>) {
		for (y in this.tl.y...this.br.y+1)
			for (x in this.tl.x...this.br.x+1) {
				var pt = new Point(x, y);
				pt.arraySet(grid, this.directive.perform2(pt.arrayGet(grid)));
			}
	}

	@:from
	public static function fromString(line:String) {
		if (pattern.match(line)) {
			var tokens = [for (x in 1...4) pattern.matched(x)];
			return new LightInstruction({
				directive: tokens[0],
				tl: tokens[1],
				br: tokens[2]
			});
		} else throw 'Unable to parse line "$line"';
	}

	@:to
	public function toString()
		return '${this.directive} ${this.tl} through ${this.br}';
}

private abstract LightGrid(Array<Array<Bool>>) from Array<Array<Bool>> to Array<Array<Bool>> {
	public function new(w:Int, h:Int)
		this = [for (_ in 0...h) [for (_ in 0...w) false]];

	public var onCount(get, never):Int;

	function get_onCount() {
		var retval = 0;
		for (row in this) for (light in row) if (light) retval++;
		return retval;
	}
}

private abstract SuperLightGrid(Array<Array<Int>>) from Array<Array<Int>> to Array<Array<Int>> {
	public function new(w:Int, h:Int)
		this = [for (_ in 0...h) [for (_ in 0...w) 0]];

	public var onCount(get, never):Int;

	function get_onCount() {
		var retval = 0;
		for (row in this) for (light in row) retval += light;
		return retval;
	}
}

class Day6 extends DayEngine {
  public static function make(data:String) {
		new Day6(data, 6, []);
	}

  function problem1(data:String) {
		var grid = new LightGrid(1000, 1000);
    var list = data.rtrim().split("\n").map(LightInstruction.fromString);
		for (x => dir in list) {
			Sys.println('${x + 1}: $dir');
			dir.perform1(grid);
		}
		return grid.onCount;
  }

  function problem2(data:String) {
		var grid = new SuperLightGrid(1000, 1000);
    var list = data.rtrim().split("\n").map(LightInstruction.fromString);
		for (x => dir in list) {
			Sys.println('${x + 1}: $dir');
			dir.perform2(grid);
		}
		return grid.onCount;
  }
}