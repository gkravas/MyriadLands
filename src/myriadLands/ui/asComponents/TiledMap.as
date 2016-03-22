package myriadLands.ui.asComponents
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.events.TweenEvent;
	
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import gamestone.pathfinding.AStar;
	import gamestone.pathfinding.Grid;
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.IPhoneScrollerManager;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.combat.MapNode;
	import myriadLands.entities.EntityManager;
	import myriadLands.entities.Tile;
	import myriadLands.events.CompassEvent;
	import myriadLands.events.MapTileEvent;
	import myriadLands.faction.Faction;
	import myriadLands.fx.FXManager;
	import myriadLands.fx.IFXAble;
	import myriadLands.net.NetworkManager;
	import myriadLands.ui.cursor.MLCursorManager;
	
	public class TiledMap extends UIComponent 
							implements IFXAble{
		
		public static const SCENE_ID:String = "TiledMap";
		public static const DECREASE_DIMENSION_MULT:Number = 1;
		
		protected const mult:Number = 0.146;
		
		protected var _gridWidth:int;
		protected var tileWidth:int;
		protected var tileHeight:int;
		protected var _mapWidth:int;
		protected var _mapHeight:int;
		
		protected var _offSetX:int;
		protected var _offSetY:int;
		
		public const pivotX:int = 256;
		public const pivotY:int = 182;
		
		protected var tileDown:MapTile;
		
		protected var tiles:Array;
		protected var tileSpecs:Array;
		protected var constructedLands:Array;
		
		protected var _focusedTile:MapTile;
		protected var _mouseOverTile:MapTile;
		protected var viewPort:Rectangle;
		
		protected var mPoint:Point;
		
		protected var tileContainer:Canvas;
		protected var fxManager:FXManager;
		
		protected var _entityPrefix:String;
		
		protected var _pathFinder:AStar;
		protected var _gridPath:Grid;
		protected var _lightedPath:Array;
		protected var _lightedArea:Array;
		
		protected var _gridSize:int;
		
		public function TiledMap()
		{
			super();
			_pathFinder = new AStar();
			constructedLands = [];
			mPoint = new Point();
			addListeners();
			createScene();
		}
		
		public function clear():void {
			tileContainer.removeAllChildren();
			var tile:MapTile;
			for each(tile in tiles)
				tile.tileEntity.destroy();			
		}
		
		protected function addListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function createGrid(tileSpecs:Array, tileW:int, tileH:int, offSetX:int = 0, offSetY:int = 0):void {
			_gridSize = Math.sqrt(tileSpecs.length);
			this.tileSpecs = tileSpecs;
			this.tiles = [];
			this._gridWidth = Math.sqrt(tileSpecs.length);;
			this.tileWidth = tileW;// * DECREASE_DIMENSION_MULT;
			this.tileHeight = tileH;// * DECREASE_DIMENSION_MULT;
			this._offSetX = offSetX;
			this._offSetY = offSetY;
			
			this._mapWidth = this._gridWidth * this.tileWidth * DECREASE_DIMENSION_MULT + _offSetX * 2;
			this._mapHeight = this._gridWidth * this.tileHeight * (1 - mult) * DECREASE_DIMENSION_MULT * 0.5 + _offSetY * 2;
			
			tileContainer.width = _mapWidth;
			tileContainer.height = _mapHeight;
            
			
			populateGrid();
			transformTileNumbers();
			sortAndAddTiles();
			
			setSize(width, height);
		}
		
		protected function createScene():void {
			tileContainer = new Canvas();
            tileContainer.x = 0;
            tileContainer.y = 0;
            tileContainer.verticalScrollPolicy = "false";
            tileContainer.horizontalScrollPolicy = "false";
			addChild(tileContainer);
			IPhoneScrollerManager.addContainer(tileContainer, true, scrollMap, startIScroll, stopIScroll, stopIScroll);
			
			fxManager = FXManager.getInstance();
			fxManager.registerScene(this, sceneID);
		}
		
		public function setSize(width:int, height:int):void {
			if (tileContainer == null) return;
			var cX:int = (tileContainer.scrollRect != null) ? tileContainer.scrollRect.x : _mapWidth * 0.5 - width/0.5;
			var cY:int = (tileContainer.scrollRect != null) ? tileContainer.scrollRect.y : -_offSetY;
			var rect:Rectangle = new Rectangle(cX, cY, width, height);
			tileContainer.scrollRect = rect;
		}
		
		/**
		 *Populates the grid with tiles. 
		 * 
		 */		
		protected function populateGrid():void
		{
			var i:int, j:int;
			var startX:int, startY:int, posX:int, posY:int;
			var tileIndex:int = 0;
			var Rn:int = 1;
			var step:int = this._gridWidth * this._gridWidth;
			
			for(j=1; j<=this._gridWidth; j++)
			{
				startX = (this.tileWidth * DECREASE_DIMENSION_MULT * this._gridWidth * 0.5) - j * this.tileWidth * DECREASE_DIMENSION_MULT * 0.5 + this._offSetX;
				startY = (j - 1) * this.tileHeight * DECREASE_DIMENSION_MULT * this.mult  + this._offSetY;
				step -= Rn
				
				for(i=0; i<=j-1; i++)
				{
					posX = startX + i * this.tileWidth * DECREASE_DIMENSION_MULT;
					posY = startY;
					tileIndex++;
					createTile(posX, posY, tileIndex);
					if (j == this._gridWidth) continue;
					createTile(posX, posY + (this._gridWidth - j) * this.tileHeight * DECREASE_DIMENSION_MULT * this.mult * 2, tileIndex + step);
				}
				Rn += 2;
			}
		}
		
		/**
		 * 
		 * @param posX
		 * @param posY
		 * @return A tile
		 * Creates each tile and returns it.
		 */		
		protected function createTile(posX:int, posY:int, index:int):MapTile
		{
			//not used
			var tile:MapTile = new MapTile(index, tileSpecs[index]);
			tile.width = tileWidth;
			tile.height = tileHeight;
			tile.x = posX;
			tile.y = posY;
			tile.scaleX = TiledMap.DECREASE_DIMENSION_MULT;
			tile.scaleY = TiledMap.DECREASE_DIMENSION_MULT;
			tile.mouseEnabled = false;
			tiles.push(tile);
			return tile;
		}
		
		/**
		 *Sorts the tiles Array and adds them on stage.
		 */		
		protected function sortAndAddTiles():void
		{
			tiles = tiles.sortOn("y", Array.NUMERIC);
			tiles.forEach(addTileToStage);
		}
		
		protected function transformTileNumbers():void {
			var em:EntityManager = EntityManager.getInstance();
			var arr:Array = [];
			var initStepX:int = 1;
			var stepX:int = initStepX;
			var tileNumber:int;
			var newTileNumber:int = 1;
			var addToX:Boolean;
			var newX:int;
			//Kata grammi
			for (var y:int = 1; y <= this._gridWidth; y++) {
				addToX = true;
				tileNumber = initStepX;
				if (y + 1 > this._gridWidth) {
					stepX = this._gridWidth
					addToX = false;
				} else {
					stepX = y + 1;
				}
				//Kata stili
				for (var x:int = 0; x < this._gridWidth; x++) {
					//trace(x + " , " + tileNumber);
					for each(var item:MapTile in tiles) {
						if (item.tileNumber == tileNumber) {
							//item.tileNumber = newTileNumber;
							newX = newTileNumber % this._gridWidth;
							newX = (newX == 0) ? this._gridWidth : newX;
							item.setTileGridCoords(newX, y);
							em.removeEntity(item.tileEntity.networkID);
							em.addOthersEntity(item.tileEntity, _entityPrefix + "_" + newX + "_" + y);
							arr.push(item);
							tiles = ArrayUtil.remove(tiles, item);
							newTileNumber++;
							break;
						}
					}
					tileNumber += stepX;
					if (stepX == this._gridWidth && addToX)
						addToX = false;
					else if (!addToX)
						stepX--;
					else if (addToX)
						stepX++;
				}
				//trace("===========================================");
				initStepX += (y > this._gridWidth) ? this._gridWidth : y;
			}
			tiles = arr;
			//trace("tiles:" + tiles.length);
			
			var tile:MapTile;
			var arr1:Array = ArrayUtil.create2DArray(_gridSize, _gridSize, null);
			for each (tile in tiles) {
				var node:MapNode = new MapNode(tile.tileX - 1, tile.tileY - 1);
				node.mapTile = tile;
				tile.mapNode = node;
				arr1[tile.tileX - 1][tile.tileY - 1] = node; 
			}
			_gridPath =  new Grid();
			_gridPath.initManualy(arr1);
		}
		
		/**
		 * 
		 * @param item
		 * @param index
		 * @param arr
		 * This function is used to add the sorted tiles.
		 */		
		protected function addTileToStage(item:MapTile, index:int, arr:Array):void {
            tileContainer.addChildAt(item, index);
        }
        
        /**
		 *Gets the first hited tile.
		 */		
		protected function getFirstHitedTile():MapTile
		{
			var p:Point = new Point(stage.mouseX, stage.mouseY);
			var element:MapTile;
			
			for each(element in tiles){
				if (element.isVisibleAreaHited(element.mouseX, element.mouseY)) 
					return element;
			}
			return null;
		}
		
		protected function getInBoundsMapCoords(left:int, top:int):Point
		{
			if (left == 0 && top == 0) 
				return new Point(tileContainer.scrollRect.x, tileContainer.scrollRect.y);
			
			var newView:Rectangle = tileContainer.scrollRect;
			var _x:int;
			var _y:int;
			
			if (left < 0)
				_x = (newView.x + left < 0) ? (Math.abs(left) + newView.x + left) : newView.x + left;
			else
				_x = (left + newView.x + newView.width >= _mapWidth) ? _mapWidth - newView.width : newView.x + left;
			
			if (top < 0)
				_y = (newView.y + top < 0) ? (Math.abs(top) + newView.y + top) : newView.y + top;
			else
				_y = (top + newView.y + newView.height >= _mapHeight) ? _mapHeight - newView.height : newView.y + top;
			
			return new Point(_x, _y);
		}
		
		protected function scrollMap(left:int, top:int):void {
			var p:Point = getInBoundsMapCoords(left, top);
			tileContainer.scrollRect = new Rectangle(p.x, p.y, tileContainer.scrollRect.width, tileContainer.scrollRect.height);
			fxManager.scrollTo2D(sceneID, p.x, -p.y);
		}
			
		protected function scrollToLand(land:MapTile):void {
			if (tileContainer == null || tileContainer.scrollRect == null) return;
			viewPort = tileContainer.scrollRect;
			var _x:int = land.x - viewPort.x - 0.5 * (viewPort.width - land.width);
			var _y:int = land.y - viewPort.y - 0.5 * (viewPort.height - land.height);
			var p:Point = getInBoundsMapCoords(_x, _y);
			var gt:TweenMax = new TweenMax(viewPort , 1, {x:p.x, y:p.y, ease:Expo.easeInOut});
			gt.addEventListener(TweenEvent.UPDATE, onScrollMapUpdate, false, 0, true);
		}
		
		public function scrollToMapTile(tile:MapTile):void {
			scrollToLand(tile);
		}
		
		public function scrollToCitadelLand(e:CompassEvent):void {
			var player:Faction = NetworkManager.getInstance().getFactionPlayer();
			if (player.centralMapTile == null) return;
			scrollToLand(player.centralMapTile);
		}
		
		public function scrollTo(e:CompassEvent):void {
			scrollMap(e.offSetX, e.offSetY);
		}
		
		public function zoom(e:CompassEvent):void {
			tileContainer.scaleX = e.zoomMult;
			tileContainer.scaleY = e.zoomMult;
			var newView:Rectangle = tileContainer.scrollRect;
			if (newView == null) return;
			var oldWidth:int = newView.width;
			var oldHeight:int = newView.height;
			newView.width = width / e.zoomMult;
			newView.height =  height / e.zoomMult;
			newView.x -= (newView.width - oldWidth) * 0.5;
			newView.y -= (newView.height - oldHeight) * 0.5;
			tileContainer.scrollRect = newView;
			fxManager.zoomTo2D(sceneID, e.zoomMult, newView.x, newView.y, newView.width, newView.height);
		}
				
		protected function onScrollMapUpdate(e:TweenEvent):void {
			tileContainer.scrollRect = viewPort;
			fxManager.scrollTo2D(sceneID, viewPort.x * tileContainer.scaleX, -viewPort.y * tileContainer.scaleY);
		}
		
		protected function checkRollOver(event:MouseEvent):void	{
			var tile:MapTile = getFirstHitedTile();
			if (tile != null)
			{
				if (_mouseOverTile != tile) 
					_mouseOverTile = tile;
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void {}
		protected function onMouseUp(event:MouseEvent):void {}
		protected function startIScroll():void {MLCursorManager.setCursor(MLCursorManager.BROWSE);}
		protected function stopIScroll():void {MLCursorManager.setCursor(MLCursorManager.SELECT);}
		
		
		//GETTERS
		public function get sceneID():String {return SCENE_ID;}
		public function get gridWidth():int {return _gridWidth;}
		public function get realWidth():int {return _mapWidth;}
		public function get realHeight():int {return _mapHeight;}		
		public function get offSetX():int {return _offSetX;}		
		public function get offSetY():int {return _offSetY;}
		public function get entityPrefix():String {return _entityPrefix;}
		
		public function getMapTile(x:int, y:int):MapTile {
			return (EntityManager.getInstance().getEntityByID(this.entityPrefix + "_" + x + "_" + y) as Tile).mapTile;
		}
		
		protected function onLightPath(e:MapTileEvent):void {
			var startX:int = e.lightPathArgs[MapTileEvent.START_X];
			var startY:int = e.lightPathArgs[MapTileEvent.START_Y];
			var endX:int = e.lightPathArgs[MapTileEvent.END_X];
			var endY:int = e.lightPathArgs[MapTileEvent.END_Y];
			var minTileNum:int = e.lightPathArgs[MapTileEvent.MIN_TILE_NUMBER];
			var maxTileNum:int = e.lightPathArgs[MapTileEvent.MAX_TILE_NUMBER];
			
			onResetPath(null);
			//GRID IS ZERO BASED
			_gridPath.setStartNode(startX - 1, startY - 1);
			_gridPath.setEndNode(endX - 1, endY - 1);
			_pathFinder.findPath(_gridPath);
			_lightedPath = _pathFinder.path;
			var node:MapNode;
			var cnt:int = 1;
			var combatHilight:ColorMatrixFilter;
			for each(node in _lightedPath) {
				combatHilight = (minTileNum <= cnt && cnt <= maxTileNum) ? CombatHighlight.AVAILABLE : CombatHighlight.INVALID; 
				node.mapTile.lightMe(combatHilight);
				cnt++;
			}
		}
		
		//LIGHTING STAFF
		protected function onResetPath(e:MapTileEvent):void {
			if (_lightedPath == null) return;
			var node:MapNode;
			for each(node in _lightedPath)
				node.mapTile.darkMe();
		}
		
		protected function onLightArea(e:MapTileEvent):void {
			var startX:int = e.lightPathArgs[MapTileEvent.START_X];
			var startY:int = e.lightPathArgs[MapTileEvent.START_Y];
			var radius:int = e.lightPathArgs[MapTileEvent.TILE_RADIUS];
			var offset:int = e.lightPathArgs[MapTileEvent.TILE_RADIUS_OFFSET];
			var validationFunction:Function = e.lightPathArgs[MapTileEvent.VALIDATION_FUNCTION];
			
			onResetArea(null);
			//GRID IS ZERO BASED
			_gridPath.setStartNode(startX - 1, startY - 1);
			_gridPath.setRadius(radius + 1);
			_pathFinder.findArea(_gridPath);
			_lightedArea = _pathFinder.area;
			var startNode:MapNode = _gridPath.getNode(startX - 1, startY - 1) as MapNode;
			var node:MapNode;
			var combatHilight:ColorMatrixFilter;
			var validationColor:ColorMatrixFilter;
			var distance:int;
			for each(node in _lightedArea) {
				combatHilight = null;
				distance = startNode.mapTile.tileEntity.calculateTileDistance(node.mapTile.tileEntity);
				if (offset <=  distance && distance <= radius) {
					if (validationFunction != null) {
						validationColor = validationFunction.call(null, node.mapTile.tileEntity);
						combatHilight = (validationColor == null) ? combatHilight : validationColor;
					}
					node.mapTile.lightMe(combatHilight);
				}
				//else
				//	node.mapTile.lightMe(CombatHighlight.INVALID); 
			}
		}
		
		protected function onResetArea(e:MapTileEvent):void {
			if (_lightedArea == null) return;
			var node:MapNode;
			for each(node in _lightedArea)
				node.mapTile.darkMe();
		}
	}
}