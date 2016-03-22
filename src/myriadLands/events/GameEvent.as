package myriadLands.events
{
	import flash.events.Event;
	
	public class GameEvent extends Event
	{
		//public static const ON_ROUND_ENDED:String = "onRoundEnded";
		public static const INIT_GAME_SCREEN:String = "initGameScreen";
		
		public function GameEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
			
		public override function clone():Event {
			return new GameEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("GameEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}