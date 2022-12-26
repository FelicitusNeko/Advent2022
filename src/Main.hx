package;

// import haxe.macro.Context;
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
import y2022.Day10;
import y2022.Day11_2;
import y2022.Day12;
import y2022.Day13;
import y2022.Day14;
import y2022.Day15;
import y2022.Day16;
import y2022.Day17;
import y2022.Day18;
import y2022.Day19_2;
import y2022.Day20;
import y2022.Day21;
import y2022.Day22;
import y2022.Day23;
import y2022.Day24;
import y2022.Day25;

using StringTools;
using tink.CoreApi;

typedef AdventFunc = String->String;
typedef AdventMakeFunc = String->Void;

class Main {
	var year = 2022;
	var day:Int;

	static function main() {
		new Main(null, 24); // Change to (year, day) - null will default to this year/day
	}

	public function new(?year:Int, ?day:Int) {
		var today = Date.now();
		if (day == null && (today.getMonth() != 11 || today.getDate() > 25))
			throw "Advent of Code is not in progress; please specify day";
		this.year = year == null ? today.getFullYear() : year;
		this.day = day == null ? today.getDate() : day;

		var funcMap:Map<Int, Array<AdventMakeFunc>> = [
			2022 => [
				Day1.make, Day2.make, Day3.make, Day4.make, Day5.make, Day6.make, Day7.make, Day8.make, Day9.make, Day10.make,
				Day11_2.make, Day12.make, Day13.make, Day14.make, Day15.make, Day16.make, Day17.make, Day18.make, Day19_2.make, Day20.make,
				Day21.make, Day22.make, Day23.make, Day24.make, Day25.make
			]
		];
		// trace(Main.populateFunctionMap());
		// return;

		getInput().handle(data -> {
			funcMap[this.year][this.day - 1](data);
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
