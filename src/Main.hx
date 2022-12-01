package;

import y2022.Day1;
import haxe.Exception;
import haxe.Http;
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;

using tink.CoreApi;

typedef AdventFunc = String->String;

class Main {
	var testData:Null<String>;
	var year = 2022;
	var day:Int;

	static function main() {
		new Main(2022, 1);
	}

	public function new(year:Int, day:Int, ?testData:String = null) {
		this.testData = testData;
		this.year = year;
		this.day = day;

		var funcMap = new Map<Int, Array<Array<AdventFunc>>>();

		funcMap[2022] = [
			[Day1.problem1, Day1.problem2]
		];

		getInput().handle(data -> {
			for (x => func in funcMap[year][day - 1])
				Sys.println('Day $day problem ${x + 1}: ' + func(data));
		});
	}

	function getInput() {
		if (testData != null)
			return Future.sync(cast(testData, String));
		if (!FileSystem.exists("./cache"))
			FileSystem.createDirectory("./cache");
		var cachePath = Path.join(["./cache", Std.string(year)]);
		if (!FileSystem.exists(cachePath))
			FileSystem.createDirectory(cachePath);
		var cacheFile = Path.join([cachePath, '$day.txt']);
		if (FileSystem.exists(cacheFile))
			return Future.sync(File.getContent(cacheFile));

		var USERAGENT = File.getContent("./secrets/useragent");
		var COOKIE = File.getContent("./secrets/session");
		return Future.irreversible(f -> {
			Sys.println("Retrieving today's data from server");
			var h = new Http('https://adventofcode.com/$year/day/$day/input');
			h.addHeader("User-Agent", USERAGENT);
			h.addHeader("Cookie", 'session=$COOKIE');
			h.onData = d -> {
				File.saveContent(cacheFile, d);
				f(d);
			};
			h.onError = e -> throw new Exception('HTTP error: $e');
			h.request();
		});
	}

	function dummy(data:String) {
		return "dummy";
	}

	function day2prob1(data:String) {
		return "";
	}
}
