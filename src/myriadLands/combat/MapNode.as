package myriadLands.combat {
	
	import gamestone.pathfinding.Node;
	
	import myriadLands.ui.asComponents.CombatMapTile;
	import myriadLands.ui.asComponents.MapTile;
	
	
	public class MapNode extends Node {
		
		protected var _mapTile:MapTile;
		
		public function MapNode(x:int, y:int) {
			super(x, y);
		}
		
		//SETTERS
		public function set mapTile(v:MapTile):void {_mapTile = v};
		//GETTERS
		public function get mapTile():MapTile {return _mapTile};
	}
}