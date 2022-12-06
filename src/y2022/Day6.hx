package y2022;

using StringTools;

class Day6 {
	public static function problem1(data:String) {
		var list = data.rtrim().split("");
		var buf:Array<String> = [];

		var match = false;
		for (x => char in list) {
			buf.push(char);
			while (buf.length > 4)
				buf.shift();
			if (buf.length == 4) {
				match = true;
				for (y in 0...3)
					for (z in y+1...4) 
						if (buf[y] == buf[z]) {
							match = false;
							break;
						}
					
			}
			if (match)
				return Std.string(x+1);
		}

		return "Not found";
	}

	public static function problem2(data:String) {
		var list = data.rtrim().split("");
		var buf:Array<String> = [];

		var match = false;
		for (x => char in list) {
			buf.push(char);
			while (buf.length > 14)
				buf.shift();
			if (buf.length == 14) {
				match = true;
				for (y in 0...13)
					for (z in y+1...14) 
						if (buf[y] == buf[z]) {
							match = false;
							break;
						}
					
			}
			if (match)
				return Std.string(x+1);
		}

		return "Not found";
	}
}
