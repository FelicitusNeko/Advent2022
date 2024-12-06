package utils;

enum IDirection {
	Up;
	Right;
	Down;
	Left;
}

abstract Direction(IDirection) from IDirection {
	public function applyToPoint(pt:Point)
		switch (this) {
			case Up:
				pt.y--;
			case Right:
				pt.x++;
			case Down:
				pt.y++;
			case Left:
				pt.x--;
		}

	public function applyToNewPoint(pt:Point):Point
		return switch (this) {
			case Up:
				[pt.x, pt.y - 1];
			case Right:
				[pt.x + 1, pt.y];
			case Down:
				[pt.x, pt.y + 1];
			case Left:
				[pt.x - 1, pt.y];
		}

	public function reverse():Direction
		return switch (this) {
			case Up: Down;
			case Down: Up;
			case Left: Right;
			case Right: Left;
		}

	public function cw():Direction
		return switch (this) {
			case Up: Right;
			case Right: Down;
			case Down: Left;
			case Left: Up;
		}

	public function ccw():Direction
		return switch (this) {
			case Up: Left;
			case Left: Down;
			case Down: Right;
			case Right: Up;
		}

	@:to
	public function toString()
		return this.getName();
}
