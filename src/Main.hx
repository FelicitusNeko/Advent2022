package;

import haxe.Exception;
import haxe.Http;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

import y2022.Day1;
import y2022.Day2;
import y2022.Day3;
import y2022.Day4;
import y2022.Day5;
import y2022.Day6;

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
		new Main(null, null, testData);
	}

	public function new(?year:Int, ?day:Int, ?testData:String = null) {
		var today = Date.now();
		this.testData = testData;
		if (this.testData != null) Sys.println("Using test data");
		this.year = year == null ? today.getFullYear() : year;
		this.day = day == null ? today.getDate() : day;

		var funcMap = new Map<Int, Array<Array<AdventFunc>>>();

		funcMap[2022] = [
			[Day1.problem1, Day1.problem2],
			[Day2.problem1, Day2.problem2],
			[Day3.problem1, Day3.problem2],
			[Day4.problem1, Day4.problem2],
			[Day5.problem1, Day5.problem2],
			[Day6.problem1, Day6.problem2]
		];

		getInput().handle(data -> {
			for (x => func in funcMap[this.year][this.day - 1])
				Sys.println('Day ${this.day} problem ${x + 1}: ' + func(data));
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
