package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.EntityModifier;
	
	public class EntityModifierEvent extends Event
	{
		public static const STARTED:String = "started";
		public static const ENDED:String = "ended";
		
		protected var _entityModifier:EntityModifier;
		
		public function EntityModifierEvent(type:String, entityModifier:EntityModifier, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_entityModifier = entityModifier;
		}
		
		public function get entityModifier():EntityModifier {
			return _entityModifier;
		}
		
		public override function clone():Event {
			return new EntityModifierEvent(type, _entityModifier, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("EntityModifierEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}