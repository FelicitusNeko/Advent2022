package;

// import haxe.macro.Context;
import haxe.Exception;
import haxe.Http;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using Safety;
using StringTools;
using tink.CoreApi;

typedef AdventFunc = String->String;
typedef AdventMakeFunc = String->Void;

class Main {
	var year = 2024;
	var day:Int;

	static function main() {
		//new Main(2024, 2); // Change to (year, day) - null will default to this year/day
		new Main();
	}

	public function new(?year:Int, ?day:Int) {
		var today = Date.now();
		if (year != null && day == null)
			throw "Year specified without day; please also specify day";
		if (day == null && (today.getMonth() != 11 || today.getDate() > 25))
			throw "Advent of Code is not in progress; please specify day";
		this.year = year == null ? today.getFullYear() : year;
		this.day = day == null ? today.getDate() : day;

		var funcMap:Map<Int, Array<AdventMakeFunc>> = [
			2015 => [
				y2015.Day1.make, y2015.Day2.make, y2015.Day3.make, y2015.Day4.make, y2015.Day5.make, y2015.Day6.make, y2015.Day7.make, y2015.Day8.make
			],

			2022 => [
				y2022.Day1.make, y2022.Day2.make, y2022.Day3.make, y2022.Day4.make, y2022.Day5.make, y2022.Day6.make, y2022.Day7.make, y2022.Day8.make,
				y2022.Day9.make, y2022.Day10.make, y2022.Day11_2.make, y2022.Day12.make, y2022.Day13.make, y2022.Day14.make, y2022.Day15.make, y2022.Day16.make,
				y2022.Day17.make, y2022.Day18.make, y2022.Day19.make, y2022.Day20.make, y2022.Day21.make, y2022.Day22.make, y2022.Day23.make, y2022.Day24.make,
				y2022.Day25.make
			],

			2024 => [
				y2024.Day1.make, y2024.Day2.make, y2024.Day3.make, y2024.Day4.make, y2024.Day5.make, y2024.Day6.make, y2024.Day7.make, y2024.Day8.make,
				y2024.Day9.make, y2024.Day10.make, y2024.Day11.make, y2024.Day12.make, y2024.Day13.make, y2024.Day14.make
			]
		];
		// trace(Main.populateFunctionMap());
		// return;

		getInput().handle(data -> {
			funcMap[this.year].or([])[this.day - 1].or(DummyDay.make)(data);
		});
	}

	/*
		public static macro function populateFunctionMap() {
			var retval:Map<Int, Array<AdventMakeFunc>> = [];
			//var srcPath = Path.directory(Context.getPosInfos(Context.currentPos()).file);
			var srcPath = "./src";
			for (yfile in FileSystem.readDirectory(srcPath)) {
				var ypath = Path.join([srcPath, yfile]);
				var ypattern = ~/^y(\d{4,})$/;
				if (FileSystem.isDirectory(ypath) && ypattern.match(yfile)) {
					var year = Std.parseInt(ypattern.matched(1));
					retval[year] = [];
					var days:Array<Int> = [];
					for (dfile in FileSystem.readDirectory(ypath)) {
						var dpath = Path.join([srcPath, yfile, dfile]);
						var dpattern = ~/^Day(\d{1,2}).hx$/;
						if (!FileSystem.isDirectory(dpath) && dpattern.match(dfile)) {
							days.push(Std.parseInt(dpattern.matched(1)));
						}
					}
					trace(days);
					retval[year] = [for (i in days) macro y$v{year}.Day${i}.make];
				}
			}
			return macro retval;
		}
	 */
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
			Sys.println('Retrieving today\'s data from server ($year day $day)');
			var h = new Http('https://adventofcode.com/$year/day/$day/input');
			h.addHeader("User-Agent", USERAGENT);
			h.addHeader("Cookie", 'session=$COOKIE');
			h.onData = d -> {
				if (d.startsWith("Please don't repeatedly request"))
					throw "Puzzle input not available yet";
				if (d.startsWith("Puzzle inputs differ by user"))
					throw "Authentication failed";
				File.saveContent(cacheFile, d);
				f(d);
			};
			h.onError = e -> throw new Exception('HTTP error: $e');
			h.request();
		});
	}
}
