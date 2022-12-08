package y2022;

import haxe.ds.ArraySort;
using StringTools;

var testData = [
	'$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
'
];

abstract class D7FileSystemItem {
	public var name(default, null):Null<String>;
	public var size(get, null):Int;
	public var parent(default, null):Null<D7Directory> = null;
	public var fullPath(get, never):String;

	public function new(name:Null<String>) {
		this.name = name;
	}

	abstract function get_size():Int;

	function get_fullPath() {
		var fullPath:Array<String> = [name];
		var ptr = parent;
		while (ptr != null && ptr.name != null) {
			fullPath.unshift(ptr.name);
			ptr = ptr.parent;
		}
		return '/${fullPath.join("/")}';
	}

	public function toString(indent = 0)
		return "".lpad(" ", indent) + '{{size}} $name';
}

class D7Directory extends D7FileSystemItem {
	var content:Array<D7FileSystemItem> = [];
	var subdirs(get, never):Array<D7Directory>;

	function get_size() {
		var size = 0;
		for (item in content)
			size += item.size;
		return size;
	}

	public function add(item:D7FileSystemItem) {
		for (i in content)
			if (i.name == item.name)
				return;
		// throw 'File ${item.name} already exists';
		content.push(item);
		item.parent = this;
	}

	function get_subdirs() {
		var subdirs:Array<D7Directory> = [];
		for (i in content)
			if (Std.isOfType(i, D7Directory))
				subdirs.push(cast(i, D7Directory));
		return subdirs;
	}

	public function cd(name:String) {
		for (i in content)
			if (i.name == name) {
				if (Std.isOfType(i, D7Directory))
					return cast(i, D7Directory);
				else
					throw '${i.fullPath} is not a directory';
			}
		var newdir = new D7Directory(name);
		add(newdir);
		return newdir;
	}

	public inline function getContent()
		return content.slice(0);

	override public function toString(indent = 0) {
	 	var retval = [super.toString(indent).replace("{{size}}", "dir")];
	 	for (i in content) retval.push(i.toString(indent + 2));
		return retval.join("\n");
	}
}

class D7File extends D7FileSystemItem {
	public function new(name:String, size:Int) {
		super(name);
		this.size = size;
	}

	function get_size()
		return this.size;

	override function toString(indent:Int = 0):String {
		return super.toString(indent).replace("{{size}}", Std.string(size));
	}
}

class CommandLineInterpreter {
	public var root(default, null) = new D7Directory(null);
	public var pwd(default, null):D7Directory;

	public function new(data:String) {
		pwd = root;
		var list = data.rtrim().split("\n");
		var is_ls = false;

		for (line in list) {
			if (is_ls && line.startsWith("$ "))
				is_ls = false;
			if (line.startsWith("$ cd")) {
				var dest = line.substr(5);
				if (dest == "/") pwd = root;
				else if (dest == "..") pwd = pwd.parent;
				else pwd = pwd.cd(line.substr(5));
			} else if (line.startsWith("$ ls")) {
				is_ls = true;
			} else if (is_ls) {
				var filedata = line.split(" ");
				if (filedata[0] == "dir")
					pwd.add(new D7Directory(filedata[1]));
				else
					pwd.add(new D7File(filedata[1], Std.parseInt(filedata[0])));
			} else
				throw 'Unexpected line "$line"';
		}

		//trace(root.toString());
	}

	public function getDirsAtMost(size:Int) {
		var retval:Array<D7Directory> = [];
		function parseDir(dir:D7Directory) {
			if (dir.size <= size) retval.push(dir);
			for (i in dir.getContent()) {
				if (Std.isOfType(i, D7Directory)) parseDir(cast(i, D7Directory));
			}
		}
		parseDir(root);
		return retval;
	}

	public function getDirsAtLeast(size:Int) {
		var retval:Array<D7Directory> = [];
		function parseDir(dir:D7Directory) {
			if (dir.size >= size) retval.push(dir);
			for (i in dir.getContent()) {
				if (Std.isOfType(i, D7Directory)) parseDir(cast(i, D7Directory));
			}
		}
		parseDir(root);
		return retval;
	}
}

class Day7 extends DayEngine {
	var cmd:CommandLineInterpreter;
	public static function make(data:String) {
		var tests = testData.map(i -> {
			return {
				data: i,
				expected: [95437, 24933642]
			}
		});
		new Day7(data, 7, tests);
	}

	function problem1(data:String) {
		cmd = new CommandLineInterpreter(data);
		var totalSize = 0;
		for (d in cmd.getDirsAtMost(100000)) totalSize += d.size;
		return totalSize;
	}

	function problem2(data:String) {
		cmd = new CommandLineInterpreter(data);
		var freeSpace = 70000000 - cmd.root.size;
		var candidates = cmd.getDirsAtLeast(30000000 - freeSpace);
		ArraySort.sort(candidates, (lhs, rhs) -> lhs.size - rhs.size);
		return candidates.shift().size;
	}
}
