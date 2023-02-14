package;

class DummyDay extends DayEngine {
  public static function make(data:String)
    return new DummyDay(data, 0);

  public function problem1(data:String)
    return "Dummy output";

  public function problem2(data:String)
    return "Dummy output";
}