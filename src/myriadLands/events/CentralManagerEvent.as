package myriadLands.events
{
	import flash.events.Event;
	
	public class CentralManagerEvent extends Event
	{
		public static const CYCLE_PASSED:String = "cyclePassed";
		
		private var _args:Object;
		
		public function CentralManagerEvent(type:String, args:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_args = args;
		}
		
		public function get args():Object
		{
			return _args;
		}
		
		public override function clone():Event {
			return new CentralManagerEvent(type, _args, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("CentralManagerEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}