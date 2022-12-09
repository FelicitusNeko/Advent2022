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
import y2022.Day7;
import y2022.Day8;
import y2022.Day9;

using StringTools;
using tink.CoreApi;

typedef AdventFunc = String->String;
typedef AdventMakeFunc = String->Void;

class Main {
	var year = 2022;
	var day:Int;

	static function main() {
		new Main(null, null);
	}

	public function new(?year:Int, ?day:Int) {
		var today = Date.now();
		this.year = year == null ? today.getFullYear() : year;
		this.day = day == null ? today.getDate() : day;

		var funcMap:Map<Int, Array<AdventMakeFunc>> = [
			2022 => [Day1.make, Day2.make, Day3.make, Day4.make, Day5.make, Day6.make, Day7.make, Day8.make, Day9.make]
		];

		getInput().handle(data -> {
			funcMap[this.year][this.day - 1](data);
		});
	}

	function getInput() {
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
				if (d.startsWith("Please don't repeatedly request")) throw "Puzzle input not available yet";
				if (d.startsWith("Puzzle inputs differ by user")) throw "Authentication failed";
				File.saveContent(cacheFile, d);
				f(d);
			};
			h.onError = e -> throw new Exception('HTTP error: $e');
			h.request();
		});
	}
}
