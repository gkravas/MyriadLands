package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.Entity;
	
	public class WorldMapEvent extends Event
	{
		//public static const LAND_TILE_SELECTED:String = "landTileSelected";
		public static const LAND_TILE_CONSTRUCTED:String = "landTileConstructed";
		
		private var _entity:Entity;
		
		public function WorldMapEvent(type:String, entity:Entity = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_entity = entity;
		}
		
		public function get entity():Entity
		{
			return _entity;
		}
		
		public override function clone():Event {
			return new WorldMapEvent(type, _entity, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("WorldMapEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}