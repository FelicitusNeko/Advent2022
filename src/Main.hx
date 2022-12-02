package;

import haxe.Exception;
import haxe.Http;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

import y2022.Day1;
import y2022.Day2;

using StringTools;
using tink.CoreApi;

typedef AdventFunc = String->String;

class Main {
	var testData:Null<String>;
	var year = 2022;
	var day:Int;

	static function main() {
		var testData:Null<String> = null;
		var testDataLoc = Path.join(["./cache", "testdata"]);
		if (FileSystem.exists("./cache") && FileSystem.exists(testDataLoc)) {
			testData = File.getContent(testDataLoc);
			if (testData.startsWith("###\n")) testData = null;
		}
		new Main(2022, 2, testData);
	}

	public function new(year:Int, day:Int, ?testData:String = null) {
		this.testData = testData;
		this.year = year;
		this.day = day;

		var funcMap = new Map<Int, Array<Array<AdventFunc>>>();

		funcMap[2022] = [
			[Day1.problem1, Day1.problem2],
			[Day2.problem1, Day2.problem2]
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
}
