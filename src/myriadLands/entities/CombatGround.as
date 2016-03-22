package myriadLands.entities
{
	import myriadLands.core.Settings;
	import myriadLands.ui.asComponents.CombatMapTile;
	
	public class CombatGround extends Tile {
		
		public static const PREFIX:String = "combatGround";
		
		protected var _entityOn:Entity;
		
		public function CombatGround(dataName:String, data:EntityData) {
			super(dataName, data);
		}
		
		//SETTERS
		public function set entityOn(e:Entity):void {
			if (e == _entityOn) return;
			if (_entityOn != null)
				_entityOn.parentEntity = null;
				//combatMapTile.combatMapNode.walkable = true;
			if (e == null) {
				_entityOn = null;
				combatMapTile.removeEntityOn();
				//combatMapTile.combatMapNode.walkable = true;
			} else {
				e.parentEntity = this;
				_entityOn = e;
				combatMapTile.addEntityOn(e);
				//combatMapTile.combatMapNode.walkable = (e.faction != Settings.player);
			}
		}
		//GETTERS
		public function get combatMapTile():CombatMapTile {return mapTile as CombatMapTile}
		public function get entityOn():Entity { return _entityOn;}
	}
}