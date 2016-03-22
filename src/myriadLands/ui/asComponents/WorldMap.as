package myriadLands.ui.asComponents
{
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import myriadLands.actions.ActionView;
	import myriadLands.entities.Land;
	import myriadLands.events.MapTileEvent;
	import myriadLands.events.WorldMapEvent;
	
	public class WorldMap extends TiledMap {
		
		public static const SCENE_ID:String = "WorldMap";
		
		public function WorldMap() {
			super();
			_entityPrefix = Land.PREFIX;
		}
				
		override protected function createTile(posX:int, posY:int, index:int):MapTile
		{
			var tile:WorldMapTile = new WorldMapTile(index, tileSpecs[index]);
			tile.width = tileWidth;
			tile.height = tileHeight;
			tile.x = posX;
			tile.y = posY;
			tile.scaleX = TiledMap.DECREASE_DIMENSION_MULT;
			tile.scaleY = TiledMap.DECREASE_DIMENSION_MULT;
			tile.mouseEnabled = false;
			tiles.push(tile);
			tile.addEventListener(MapTileEvent.MAP_TILE_CONSTRUCTED, tileConstructed, false, 0, true);
			tile.addEventListener(MapTileEvent.LIGHT_PATH, onLightPath, false, 0, true);
			tile.addEventListener(MapTileEvent.RESET_PATH, onResetPath, false, 0, true);
			tile.addEventListener(MapTileEvent.LIGHT_AREA, onLightArea, false, 0, true);
			tile.addEventListener(MapTileEvent.RESET_AREA, onResetArea, false, 0, true);
			return tile;
		}
		
		//EVENTS
		protected function tileConstructed(e:MapTileEvent):void {
			landTileConstructed(e.tile as WorldMapTile);
		}
		
		protected function landTileConstructed(land:WorldMapTile):void {
			constructedLands.push(land.tileEntity);
			dispatchEvent(new WorldMapEvent(WorldMapEvent.LAND_TILE_CONSTRUCTED, land.tileEntity));
		}
		
		override protected function onMouseDown(e:MouseEvent):void {
			var tile:WorldMapTile = getFirstHitedTile() as WorldMapTile;
			if (tile != null)
				tileDown = tile;
		}
		
		override protected function onMouseUp(e:MouseEvent):void {
			var tile:WorldMapTile = getFirstHitedTile() as WorldMapTile;
			if (tileDown == tile && tileDown != null)
				tileDown.tileEntity.fireSelectedEvent(ActionView.WORLD_MAP);
			tileDown = null;
		}
		
		//GETTERS
		override public function get sceneID():String {return SCENE_ID;}
	}
}