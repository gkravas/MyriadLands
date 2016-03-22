package myriadLands.ui.asComponents {
	import flash.filters.ColorMatrixFilter;
	
	import myriadLands.entities.Entity;
	import myriadLands.entities.Tile;
	
	
	public class HighlightUtil {
		
		protected var _highlightColor:ColorMatrixFilter;
		protected var _iconName:String;
		protected var _tiles:Array;
		
		public function HighlightUtil(highlightColor:ColorMatrixFilter, iconName:String = null) {
			_highlightColor = highlightColor;
			_iconName = iconName;
		}
		
		public function setTileArray(arr:Array):void {
			_tiles = arr;
		}
		
		public function lightAndAddIcons():void {
			var tile:Tile;
			for each (tile in _tiles)
				markEntity(tile);
		}
		
		public function darkAndRemoveIcons():void {
			var tile:Tile;
			for each (tile in _tiles)
				unmarkEntity(tile);
		}
		
		protected function markEntity(tile:Tile):void {
			tile.mapTile.lightMe(_highlightColor);
			if (_iconName != null)
				tile.mapTile.addIcon(_iconName);
		}
		
		protected function unmarkEntity(tile:Tile):void {
			tile.mapTile.darkMe();
			if (_iconName != null)
				tile.mapTile.removeIcon();
		}

	}
}