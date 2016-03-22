package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.ui.asComponents.MapTile;
	
	public class MapTileEvent extends Event
	{
		public static const MAP_TILE_CONSTRUCTED:String = "landTileConstructed";
		public static const LIGHT_PATH:String = "lightPath";
		public static const RESET_PATH:String = "resetPath";
		public static const LIGHT_AREA:String = "lightArea";
		public static const RESET_AREA:String = "resetArea";
		
		public static const START_X:int = 0;
		public static const START_Y:int = 1;
		public static const END_X:int = 2;
		public static const END_Y:int = 3;
		public static const MIN_TILE_NUMBER:int = 4;
		public static const MAX_TILE_NUMBER:int = 5;
		public static const TILE_RADIUS:int = 6;
		public static const TILE_RADIUS_OFFSET:int = 7;
		public static const VALIDATION_FUNCTION:int = 8;
		
		private var _tile:MapTile;
		private var _lightPathArgs:Object;
		public function MapTileEvent(type:String, tile:MapTile = null, lightPathArgs:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_tile = tile;
			_lightPathArgs = lightPathArgs;
		}
		
		public function get tile():MapTile {return _tile;}
		public function get lightPathArgs():Object {return _lightPathArgs;}
		
		public override function clone():Event {
			return new MapTileEvent(type, _tile, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("MapTileEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}