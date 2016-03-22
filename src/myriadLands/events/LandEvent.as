package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.faction.Faction;
	
	public class LandEvent extends Event {
		
		public static const GO_TO_COMBAT:String = "goToCombat";
		
		private var _mySquad:Squad;
		private var _enemySquad:Squad;
		private var _combatLand:Land;
		private var _gridSize:int;
		private var _attacker:Faction;
		
		public function LandEvent(type:String, mySquad:Squad, enemySquad:Squad, attacker:Faction, combatLand:Land, gridSize:int, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_mySquad = mySquad;
			_enemySquad = enemySquad;
			_combatLand = combatLand;
			_gridSize = gridSize;
			_attacker = attacker;
		}
		
		public function get mySquad():Squad{return _mySquad;}		
		public function get enemySquad():Squad {return _enemySquad;}		
		public function get combatLand():Land {return _combatLand;}
		public function get gridSize():int {return _gridSize;}
		public function get attacker():Faction {return _attacker;}
		
		public override function clone():Event {
			return new LandEvent(type, _mySquad, _enemySquad, _attacker, _combatLand, _gridSize, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("LandEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}