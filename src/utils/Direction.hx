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

	public function reverse():Direction
		return switch (this) {
			case Up: Down;
			case Down: Up;
			case Left: Right;
			case Right: Left;
		}

	@:to
	public function toString()
		return this.getName();
}
