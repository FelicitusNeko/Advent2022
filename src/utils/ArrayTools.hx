package utils;

class ArrayTools {
	@:generic
	public static function reduce<T, U>(ar:Array<T>, cb:(U, T) -> U, ?start:U):Null<U> {
		if (ar.length == 0)
			return null;
		var retval:U = start == null ? cast ar.shift() : start;
		for (value in ar)
			retval = cb(retval, value);
		return retval;
	}
}
