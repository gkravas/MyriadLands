package myriadLands.events
{
	import flash.events.Event;
	
	public class MainMenuEvent extends Event
	{
		public static const TOGGLE_FLOATER_VISIBILITY:String = "toggleFloaterVisibility"; 
		
		protected var _floater:String;
		
		public function MainMenuEvent(type:String, floater:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_floater = floater;
		}
		
		public function get floater():String {
			return _floater;
		}
		
		public override function clone():Event {
			return new MainMenuEvent(type, _floater, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("HierarchyPanelEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}