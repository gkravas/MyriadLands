package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.faction.Faction;
	
	public class CombatEvent extends Event
	{
		public static const ON_ROUND_ENDED:String = "onRoundEnded";
		public static const COMBAT_START:String = "combatStarted";
		public static const COMBAT_ENDED:String = "combatEnded";
		public static const CITADEL_CONQUESTED:String = "citadelConquested";
		
		protected var _winner:Faction;
		protected var _looser:Faction;
		
		public function CombatEvent(type:String, winner:Faction = null, looser:Faction = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_winner = winner;
			_looser = looser;
		}
		
		public function get winner():Faction {return _winner;}
		public function get looser():Faction {return _looser;}
			
		public override function clone():Event {
			return new CombatEvent(type, _winner, _looser, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("CombatEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}