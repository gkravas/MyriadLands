package myriadLands.combat {
	
	import flash.events.EventDispatcher;
	
	import myriadLands.components.CombatComponent;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.Squad;
	import myriadLands.entities.Unit;
	import myriadLands.events.CombatEvent;
	import myriadLands.events.NetworkEvent;
	import myriadLands.faction.Faction;
	import myriadLands.net.MLProtocol;
	import myriadLands.net.NetworkManager;
	import myriadLands.ui.asComponents.CombatMap;
	
	use namespace CombatInternal;
	
	public class CombatManager extends EventDispatcher {
		
		protected var _mySquad:Squad;
		protected var _enemySquad:Squad;
		protected var _combatMap:CombatMap;
		protected var _combatComponents:Array;
		//protected var _combatTimer:Timer;
		
		public function CombatManager(combatMap:CombatMap) {
			//_combatTimer = new Timer(Settings.CombatMapRoundTime);
			//_combatTimer.addEventListener(TimerEvent.TIMER, onRoundEnded, false, 0, true);
			_combatComponents = [];
			_combatMap = combatMap;
			NetworkManager.getInstance().addEventListener(NetworkEvent.START_BATTLE, startBattle, false, 0, true);
		}
				
		public function init(mySquad:Squad, enemySquad:Squad, attacker:Faction):void {
			_mySquad = mySquad;
			_enemySquad = enemySquad;
			CombatVars.setMySquad(mySquad);
			CombatVars.setEnemySquad(enemySquad);
			createSquadComponents(_mySquad);
			createSquadComponents(_enemySquad);
			if (attacker == NetworkManager.getInstance().getFactionPlayer()) {
				var enemy:Faction = (attacker == enemySquad.faction) ? mySquad.faction : enemySquad.faction;
				NetworkManager.getInstance().sendMessage(MLProtocol.PLAYERS_GO_TO_BATTLE, {oponent:enemy});
			}
		}
		
		public function clear():void {
			//_combatTimer.stop();
			NetworkManager.getInstance().addEventListener(NetworkEvent.BATTLEFIELD_CYCLE, onRoundEnded, false, 0, true);
			var cc:CombatComponent;
			for each(cc in _combatComponents) {
				cc.destroy();
				cc = null;
			}
			_combatComponents = [];
		}
		
		protected function startBattle(e:NetworkEvent):void {
			//_combatTimer.start();
			NetworkManager.getInstance().addEventListener(NetworkEvent.BATTLEFIELD_CYCLE, onRoundEnded, false, 0, true);
		}
		
		protected function createSquadComponents(squad:Squad):void {
			_combatComponents.push(new CombatComponent(squad, this));
			var units:Array = squad.getUnits();
			var unit:Unit;
			for each(unit in units){
				_combatComponents.push(new CombatComponent(unit, this));
			}
		}
		
		protected function checkWinner():Faction {
			if (!isSquadAlive(_mySquad))
				return _enemySquad.faction;
			else if (!isSquadAlive(_enemySquad))
				return _mySquad.faction;
			return null;
		}
		
		//Returns false id everyone is dead
		protected function isSquadAlive(squad:Squad):Boolean {
			if (squad.lif > 0) return true;
			var units:Array = squad.getUnits();
			var unit:Unit;
			for each(unit in units){
				if (unit.lif > 0)
					return true;
			}
			return false;
		}
		//Called by EntityComponent
		EntityInternal function entityDied(e:Entity):void {
			var winner:Faction = checkWinner();
			if (winner != null) {
				var looser:Faction = (_mySquad.faction == winner) ? _enemySquad.faction : _mySquad.faction;
				dispatchEvent(new CombatEvent(CombatEvent.COMBAT_ENDED, winner, looser));
				NetworkManager.getInstance().sendMessage(MLProtocol.PLAYERS_LEAVE_BATTLE, {oponent:_enemySquad.faction});
			}
		}
		
		//EVENTS
		protected function onRoundEnded(e:NetworkEvent):void {
			dispatchEvent(new CombatEvent(CombatEvent.ON_ROUND_ENDED));
		}
	}
}