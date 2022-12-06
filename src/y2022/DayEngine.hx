package y2022;

import haxe.Exception;
import Sure.sure;

using StringTools;

typedef TestData = {
	var data:String;
	var expected:Array<Dynamic>;
}

abstract class DayEngine {
	public function new(data:String, dayNum:Int, ?tests:Array<TestData>) {
		for (x => problem in [problem1, problem2]) {
			var pass = true;
			Sys.print('Day ${dayNum} problem ${x + 1}: ');
			if (tests != null)
				for (y => test in tests) {
					if (test.expected.length <= x || test.expected[x] == null) {
						Sys.print("❓");
						continue;
					}
					try {
						var testRun = problem(test.data);
						if (testRun == null || testRun == "") {
							pass = false;
							Sys.println('❌ <Test #${y+1} returned no data>');
							break;
						}
						sure(testRun == test.expected[x]);
						Sys.print("✅");
					} catch (e:Exception) {
						pass = false;
						if (e.message.startsWith("FAIL:"))
							Sys.println('Assertion failed on test #${y + 1}\n${e.message}');
						else
							Sys.println('Execution failed on test #${y + 1} and threw an exception\n${e.details()}');
						break;
					}
				}
			if (pass)
				try {
					var result = problem(data);
					Sys.println(result == null || result == "" ? "<Did not return a value>" : result);
				} catch (e:Exception) {
					Sys.println('Execution failed on puzzle input and threw an exception');
					Sys.println(e.details());
				}
		}
	}

	abstract function problem1(data:String):Null<Dynamic>;

	abstract function problem2(data:String):Null<Dynamic>;
}
