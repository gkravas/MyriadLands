package myriadLands.entities
{
	import gamestone.pathfinding.AStar;
	import gamestone.pathfinding.Grid;
	
	import myriadLands.core.Settings;
	import myriadLands.ui.asComponents.MapTile;
	
	public class Tile extends Entity
	{	
		public static const PREFIX:String = "Tile";
		
		protected var _tile:MapTile;
		
		public function Tile(dataName:String, data:EntityData) {
			super(dataName, data);
		}
		
		/*public function calculateLandsDistance(newTile:Tile):Point {
			var p:Point = new Point();
			var p1:Point = new Point(mapTile.tileX, mapTile.tileY);
			var p2:Point = new Point(newTile.mapTile.tileX, newTile.mapTile.tileY);
			p = p2.subtract(p1);
			return p;
		}*/
		
		public function calculateTileDistance(newTile:Tile):int {
			var grid:Grid = new Grid();
			grid.initAutomatic(Settings.MAX_GRID_TILE_WIDTH, Settings.MAX_GRID_TILE_WIDTH);
			grid.setStartNode(mapTile.tileX - 1, mapTile.tileY - 1);
			grid.setEndNode(newTile.mapTile.tileX - 1, newTile.mapTile.tileY - 1);
			var astar:AStar = new AStar();
			astar.findPath(grid);
			return astar.path.length - 1;
		}
		//SETTERS
		public function set mapTile(v:MapTile):void {_tile = v;}
		
		//GETTERS
		public function get mapTile():MapTile {return _tile;}
	}
}