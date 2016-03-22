package myriadLands.combat {
	
	import myriadLands.entities.Squad;	
	
	public class CombatVars {
		
		protected static var _enemySquad:Squad;
		protected static var _mySquad:Squad;
		
		//GETTERS
		public static function get enemySquad():Squad {return _enemySquad;}		
		public static function get mySquad():Squad {return _mySquad;}
		
		//SETTERS
		CombatInternal static function setEnemySquad(v:Squad):void {_enemySquad = v;}		
		CombatInternal static function setMySquad(v:Squad):void {_mySquad = v;} 
		
		public function CombatVars() {}

	}
}