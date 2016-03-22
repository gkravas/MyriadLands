package myriadLands.events
{
	import flash.events.Event;
	
	public class CompassEvent extends Event
	{
		public static const SCROLL_WORLD_MAP:String = "scrollWorldMap";
		public static const SCROLL_COMBAT_MAP:String = "scrollCombatMap";
		public static const SCROLL_TO_CITADEL_LAND:String = "scrollToCitadelLand";
		public static const SCROLL_TO_CHAMPION:String = "scrollToChampion";
		public static const ZOOM_MAP:String = "zoomMap";
		
		private var _offSetX:int;
		private var _offSetY:int;
		private var _zoomMult:Number;
		
		public function CompassEvent(type:String, offSetX:int = 0, offSetY:int = 0, zoomMult:Number = 1, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_offSetX = offSetX;
			_offSetY = offSetY;
			_zoomMult = zoomMult;
		}
		
		public function get offSetX():int {return _offSetX;}
		public function get offSetY():int {return _offSetY;}
		public function get zoomMult():Number {return _zoomMult;}
		
		public override function clone():Event {
			return new CompassEvent(type, _offSetX, _offSetY, _zoomMult, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("CompassEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}