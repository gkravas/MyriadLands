package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.Entity;
	import myriadLands.faction.Faction;
	
	public class CombatMapEvent extends Event
	{
		public static const COMBAT_GROUND_TILE_SELECTED:String = "combatGroundTileSelected";
		public static const POPULATE_ACTION_PANEL:String = "populateActionPanel";
		public static const COMBAT_ENDED:String = "combatEnded";
		
		private var _entity:Entity;
		private var _winner:Faction;
		private var _looser:Faction;
		
		public function CombatMapEvent(type:String, entity:Entity = null, winner:Faction = null, looser:Faction = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_entity = entity;
			_winner = winner;
			_looser = looser;
		}
		
		public function get entity():Entity {return _entity;}
		public function get winner():Faction {return _winner;}
		public function get looser():Faction {return _looser;}
		
		public override function clone():Event {
			return new CombatMapEvent(type, _entity, _winner, _looser, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("CombatMapEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}