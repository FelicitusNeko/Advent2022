package y2015;

import haxe.ds.ArraySort;
using StringTools;

private typedef IBox = {
	var length:Int;
	var width:Int;
	var height:Int;
}

@:forward
private abstract D2Box(IBox) {
	public var volume(get, never):Int;
	public var surface(get, never):Int;
	public var smallestFace(get, never):Int;

	private function new(box:IBox)
		this = box;

	function get_volume()
		return this.length * this.width * this.height;

	function get_surface()
		return ((this.length * this.width) + (this.length * this.height) + (this.width * this.height)) * 2;

	function get_smallestFace() {
		var faces = [this.length, this.width, this.height];
		ArraySort.sort(faces, (l, r) -> l - r);
		return faces[0] * faces[1];
	}

	@:from
	public static function fromString(str:String) {
		var pattern = ~/^(\d+)x(\d+)x(\d+)$/;
		if (pattern.match(str))
			return new D2Box({
				length: Std.parseInt(pattern.matched(1)),
				width: Std.parseInt(pattern.matched(2)),
				height: Std.parseInt(pattern.matched(3))
			});
		else
			throw 'Invalid pattern "$str"';
	}

	@:to
	public function toString()
		return '${this.length}x${this.width}x${this.height}';
}

class Day2 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: "2x3x4",
				expected: [58, 34]
			},
			{
				data: "1x1x10",
				expected: [43, 14]
			}
		];
		new Day2(data, 2, tests);
	}

	function problem1(data:String) {
		var list = data.rtrim().split("\n").map(D2Box.fromString);
		var total = 0;
		for (box in list) total += box.surface + box.smallestFace;
		return total;
	}

	function problem2(data:String) {
		var list = data.rtrim().split("\n").map(D2Box.fromString);
		var total = 0;
		for (box in list) {
			var faces = [box.length, box.width, box.height];
			ArraySort.sort(faces, (l, r) -> l - r);
			total += box.volume + ((faces[0] + faces[1]) * 2);
		}
		return total;
	}
}
