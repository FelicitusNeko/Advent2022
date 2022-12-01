package y2022;

class Day1 {
  public static function problem1(data:String) {
    var list = data.split("\n").map(d -> d == "" ? null : Std.parseInt(d));
		var cur = 0, most = 0;

		for (d in list) {
			if (d == null) {
				if (cur > most)
					most = cur;
				cur = 0;
			} else
				cur += d;
		}

		return Std.string(most);
  }

  public static function problem2(data:String) {
    var list = data.split("\n").map(d -> d == "" ? null : Std.parseInt(d));
		var cur = 0, most = [0, 0, 0];

		for (d in list) {
			if (d == null) {
				for (x => mostx in most)
					if (cur > mostx) {
						var buf = cur;
						cur = most[x];
						most[x] = buf;
						if (cur == 0) break;
					}
				cur = 0;
			} else
				cur += d;
		}

		for (_ => mostx in most) cur += mostx;

		return Std.string(cur);
  }
}