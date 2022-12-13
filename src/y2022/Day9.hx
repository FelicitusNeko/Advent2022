package y2022;

import haxe.Json;
import helder.Set;

using StringTools;

enum MoveInstruction {
	Up(step:Int);
	Right(step:Int);
	Down(step:Int);
	Left(step:Int);
}

typedef IPoint = {
	var x:Int;
	var y:Int;
}

@:forward
abstract Point(IPoint) from IPoint to IPoint {
	@:to
	public function toString()
		return '${this.x}:${this.y}';

	@:op(a == b)
	public function isEqual(rhs:Point)
		return this.x == rhs.x && this.y == rhs.y;
}

class Walker {
	var rope:Array<Point>;
	var head:Point;
	var tail:Point;
	var list:Array<MoveInstruction>;

	public var tailLog(default, null) = new Set<String>();

	public function new(data:String, length = 2) {
		rope = [for (_ in 0...length) {x: 0, y: 0}];
		head = rope[0];
		tail = rope[rope.length - 1];
		list = data.rtrim().split("\n").map(i -> {
			var pattern = ~/^([UDLR]) (\d+)$/;
			if (pattern.match(i))
				return switch (pattern.matched(1)) {
					case "U": Up(Std.parseInt(pattern.matched(2)));
					case "D": Down(Std.parseInt(pattern.matched(2)));
					case "L": Left(Std.parseInt(pattern.matched(2)));
					case "R": Right(Std.parseInt(pattern.matched(2)));
					default: throw 'Invalid direction "${pattern.matched(1)}"';
				}
			else
				throw 'Invalid instruction "$i"';
		});
	}

	public function walk() {
		function performMove(cb:Point->Void, dist:Int) {
			for (_ in 0...dist) {
				for (x in 0...rope.length) {
					var node = rope[x];
					if (node == head)
						cb(node);
					else {
						var prev = rope[x - 1];
						var hdist = node.x - prev.x;
						var vdist = node.y - prev.y;

						switch (Math.round(Math.abs(hdist) + Math.abs(vdist))) {
							case 3 | 4:
								if (hdist < 0)
									node.x++;
								else if (hdist > 0)
									node.x--;
								if (vdist < 0)
									node.y++;
								else if (vdist > 0)
									node.y--;
							case 2:
								if (hdist < -1)
									node.x++;
								else if (hdist > 1)
									node.x--;
								if (vdist < -1)
									node.y++;
								else if (vdist > 1)
									node.y--;
							case 1 | 0:
							case l:
								throw 'Invalid Planck length $l ($hdist, $vdist) on node $x';
						}
					}
				}
				tailLog.add('${tail.x}:${tail.y}');
			}
		}

		for (move in list) {
			switch (move) {
				case Up(step):
					performMove(pt -> pt.y--, step);
				case Down(step):
					performMove(pt -> pt.y++, step);
				case Left(step):
					performMove(pt -> pt.x--, step);
				case Right(step):
					performMove(pt -> pt.x++, step);
			}
		}
	}
}

class Day9 extends DayEngine {
	public static function make(data:String) {
		var tests = [
			{
				data: 'R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
',
				expected: [13, 1]
			},
			{
				data: 'R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
',
				expected: [null, 36]
			}
		];
		new Day9(data, 9, tests);
	}

	function problem1(data:String) {
		var walker = new Walker(data);
		walker.walk();
		return walker.tailLog.length;
	}

	function problem2(data:String) {
		var walker = new Walker(data, 10);
		walker.walk();
		return walker.tailLog.length;
	}
}
