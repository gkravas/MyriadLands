package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.Entity;
	
	public class EntityEvent extends Event
	{
		public static const SELECTED:String = "selected";
		public static const UPDATE:String = "update";
		public static const STATE_CHANGED:String = "stateChanged";
		public static const LIF_CHANGED:String = "lifChanged";
		public static const ENTITY_DIED:String = "entityDied";
		public static const ENTITY_AP_RUNNED_OUT:String = "entityApRunnedOut";
		
		private var _entity:Entity;
		private var _view:String;
		private var _attributesUpdated:Boolean;
		private var _actionsUpdated:Boolean;
		private var _contentUpdated:Boolean;
		
		public function EntityEvent(type:String, entity:Entity = null, view:String = null, attributesUpdated:Boolean = false, actionsUpdated:Boolean = false, contentUpdated:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_entity = entity;
			_view = view;
			_attributesUpdated = attributesUpdated;
			_actionsUpdated = actionsUpdated;
			_contentUpdated = contentUpdated
		}
		
		public function get entity():Entity
		{
			return _entity;
		}
		
		public function get view():String
		{
			return _view;
		}
		
		public function get attirbutesUpdated():Boolean
		{
			return _attributesUpdated;
		}
		
		public function get actionsUpdated():Boolean
		{
			return _actionsUpdated;
		}
		
		public function get contentUpdated():Boolean
		{
			return _contentUpdated;
		}
		
		public override function clone():Event {
			return new EntityEvent(type, _entity, _view, _attributesUpdated, _actionsUpdated, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("EntityEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}