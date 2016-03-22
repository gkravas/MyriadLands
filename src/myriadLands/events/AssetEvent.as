package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.Entity;
	import myriadLands.ui.buttons.SquareButton;
	
	public class AssetEvent extends Event
	{
		public static const INVENTORY:String = "inventory";
		public static const VAULT:String = "vault";
		public static const IMPORT:String = "import";
		public static const EXPORT:String = "export";
		
		protected var _entity:Entity;
		protected var _squareButton:SquareButton;
		
		public function AssetEvent(type:String, entity:Entity, squareButton:SquareButton = null, dbubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_entity = entity;
			_squareButton = squareButton;
		}
		
		public function get entity():Entity	{
			return _entity;
		}
		
		public function get squareButton():SquareButton	{
			return _squareButton;
		}
		
		public override function clone():Event {
			return new AssetEvent(type, _entity, _squareButton, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("AssetEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}