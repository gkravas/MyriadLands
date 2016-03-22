package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.Entity;
	import myriadLands.faction.Faction;
	
	public class FactionEvent extends Event
	{
		public static const ENTITY_ADDED_TO_INVENTORY:String = "entityAddedToInventory";
		public static const ENTITY_REMOVED_FROM_INVENTORY:String = "entityRemovedFromInventory";
		
		public static const ENTITY_ADDED_TO_VAULT:String = "entityAddedToVault";
		public static const ENTITY_REMOVED_FROM_VAULT:String = "entityRemovedFromVault";
		
		public static const ENTITY_ADDED_TO_EXPORT:String = "entityAddedToExport";
		public static const ENTITY_REMOVED_FROM_EXPORT:String = "entityRemovedFromExport";
		
		public static const ENTITY_ADDED_TO_IMPORT:String = "entityAddedToImport";
		public static const ENTITY_REMOVED_FROM_IMPORT:String = "entityRemovedFromImport";
		
		public static const FACTION_LOST:String = "factionLost";
		
		public static const MAX_PRESERVED_ENTITIES_CHANGED:String = "maxPreservedEntitiesChanged";
		
		private var _entity:Entity;
		private var _faction:Faction;
		
		public function FactionEvent(type:String, entity:Entity, faction:Faction, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_entity = entity;
			_faction = faction;
		}
		
		public function get entity():Entity
		{
			return _entity;
		}
		
		public function get faction():Faction
		{
			return _faction;
		}
		
		public override function clone():Event {
			return new FactionEvent(type, _entity, _faction, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("FactionEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}