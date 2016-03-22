package myriadLands.ui.asComponents
{
	import com.greensock.TweenMax;
	import com.greensock.events.TweenEvent;
	
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import gamestone.utils.ArrayUtil;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import myriadLands.core.Settings;
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.entities.Structure;
	import myriadLands.events.MapTileEvent;
	import myriadLands.fx.FXManager;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.ui.css.MLFilters;
	
	public class WorldMapTile extends MapTile {
		
		public static const MAX_LIGHTING_BRIGHTNESS:int = 150;
		public static const MAX_SQUAD_HIGHLIGHT:int = 10;
		
		public static const SCARRED_LAND:String = "scarredLand";
		public static const FLAT_LANDS_TYPE:String = "flatLands";
		
		public static const CONSTRUCTED_LAND:String = "constructedLand";
		public static const WARPED_LAND:String = "warpedLand";
		
		/*public static const WASTELAND_TYPE:String = "wasteland";
		public static const CHASM_TYPE:String = "chasm";
		public static const FUNGAL_FOREST_TYPE:String = "fungalForest";
		public static const VOLCANO_TYPE:String = "volcano";
		public static const ROCKY_FIELDS_TYPE:String = "rockyFields";
		public static const FOREST_TYPE:String = "forest";
		public static const CRATER_TYPE:String = "crater";*/
		
		public static const CARD_REAR:String = "cardRear";
		public static const LAND_TYPES:Array = [SCARRED_LAND, FLAT_LANDS_TYPE];
		
		protected const LAND_LAYER:int = 2;
		protected const STRUCTURE_LAYER:int = 1;
		protected const SQUAD_LAYER:int = 0;
		//protected const SELECTED_LAYER:int = 0;
		
		protected var _constructed:Boolean;
		protected var _type:String;
		protected var _usableClassTypes:Object;
		
		protected var _deployFilter:GlowFilter;
		protected var _destructionFilter:GlowFilter;
		
		//Event sync lock variables
		protected var _callConstruct:Boolean;
		
		protected var _squadGlow:GlowFilter;
		protected var _squadGlowTween:TweenMax;
		
		public function WorldMapTile(tileNumber:int, tileSpec:int) {
			super(tileNumber, tileSpec);
			_tileSpec = tileSpec;
			_tileNumber = tileNumber;
			toolTip = String(tileNumber);
			_constructed = false;
			_type = CARD_REAR;
			
			_tileEntity = EntityLoader.getInstance().getEntity(_type, null);
			_tileEntity.mapTile = this;
			
			createSquadGlow();
		}
		
		public function construct():void
		{
			if (_constructed) return;
			if (_tileSprite == null && !_callConstruct) {
				_callConstruct = true;
				return;
			} 
			convertLandTo(LAND_TYPES[_tileSpec]);
			_constructed = true;
			dispatchEvent(new MapTileEvent(MapTileEvent.MAP_TILE_CONSTRUCTED, this));
		}
		
		public function attack(squad:Squad):void {
			
		}
		public function assignStructure(construct:Structure):void {
			if (_entityOn != null) {
				removeStructure();
				return;
			}
			_entityOn = new UIComponent();
			_entityOn.addChild(construct.getBitmapAssetIco());
			_entityOn.mouseEnabled = false;
			addChild(_entityOn);
			
			startDeployAnim();
		}
		
		//DEPLOY ANIM
		protected function startDeployAnim():void {
			_deployFilter = new GlowFilter();
			_deployFilter.inner = true;
			_deployFilter.color = 0xFFFFFF;
			_deployFilter.alpha = 1;
			_deployFilter.blurX = MAX_LIGHTING_BRIGHTNESS;
			_deployFilter.blurY = MAX_LIGHTING_BRIGHTNESS;
			_deployFilter.quality = BitmapFilterQuality.HIGH;
			_entityOn.filters = [_deployFilter];
			MLFilters.getDeployStructureTween(_deployFilter, Settings.STRUCTURE_DEPLOY_DURATION, 0, onDeployAnimUpdate, onDeployAnimHide);
		}
		
		protected function onDeployAnimUpdate(e:TweenEvent):void {
			_entityOn.filters = [_deployFilter];
		}
		
		protected function onDeployAnimHide(e:TweenEvent):void {
			showPlayerGlow();
			_deployFilter = null;
		}
		//
		
		public function removeStructure():void {
			if (_entityOn == null) return;
			removeAura();
			removePlayerGlow();
			startDestructionAnim();
		}
		
		//DEPLOY ANIM
		protected function startDestructionAnim():void {
			_destructionFilter = new GlowFilter();
			_destructionFilter.inner = true;
			_destructionFilter.color = 0xFFFFFF;
			_destructionFilter.alpha = 1;
			_destructionFilter.blurX = 0;
			_destructionFilter.blurY = 0;
			_destructionFilter.quality = BitmapFilterQuality.HIGH;
			MLFilters.getDestroyStructureTween(_destructionFilter, _entityOn, Settings.STRUCTURE_DESTRUCTION_DURATION, MAX_LIGHTING_BRIGHTNESS, onDestructionAnimUpdate, onDestructionAnimHide);
		}
		
		protected function onDestructionAnimUpdate(e:TweenEvent):void {
			if (_entityOn == null) return;
			_entityOn.filters = [_destructionFilter];
		}
		
		protected function onDestructionAnimHide(e:Event):void {
			removeChild(_entityOn);
			_entityOn = null
			_destructionFilter = null;
			if (landTileEntity.structure != null)
				assignStructure(landTileEntity.structure);
		}
		//
		
		public function convertLandTo(newType:String):void {
			chooseLandType(newType);
			//if (_tileSprite != null)
			//	removeChild(_tileSprite);
			
			if (_tileSprite == null) {
				_tileSprite = new UIComponent();
				addChild(_tileSprite);
			}
			_tileSprite.addChildAt(getLandBitmapAsset(_type + "-ico"), 0);
			var ba:BitmapAsset = (_tileSprite.numChildren > 1) ? _tileSprite.getChildAt(1) as BitmapAsset : null;
			MLFilters.getConstructTween(ba, _tileSprite.getChildAt(0), 1, onConvertLandTweenComplete);
			//_tileSprite.mouseEnabled = false;
			//addChild(_tileSprite);
			
			if (_entityOn != null && getChildIndex(_tileSprite) > 0)
					swapChildren(_entityOn, _tileSprite);
		}
		
		private function chooseLandType(type:String):void {
			_type = type;
			EntityLoader.getInstance().renewEntity(_tileEntity, _type);
		}
		
		override public function isVisibleAreaHited(x:int, y:int):Boolean {
			var bmp:BitmapAsset = _tileSprite.getChildAt(0) as BitmapAsset;
			var a:uint = bmp.bitmapData.getPixel32(x, y);
			var bmpSt:BitmapAsset;
			var b:uint;
			if (_entityOn != null) {
				bmpSt = _entityOn.getChildAt(0) as BitmapAsset;
				b = bmpSt.bitmapData.getPixel32(x, y);
			}
			else
				b = 0;
			return ((a != 0) || (b != 0));
		}
		
		override public function addIcon(name:String):void {
			var pos:Point = new Point;
			pos.x = x + width * 0.5;
			pos.y = -y -height * 0.8;
			_fxIndex = FXManager.getInstance().addWorldMapActionIconPlane(name, pos);
		}
		
		override public function removeIcon():void {
			FXManager.getInstance().removeWorldMapActionIconPlane(_fxIndex);
		}
		
		//SQUAD GLOW
		protected function createSquadGlow():void {
			_squadGlow = new GlowFilter();
			_squadGlow.inner = true;
			_squadGlow.alpha = 1;
			_squadGlow.quality = BitmapFilterQuality.HIGH;
		}
		
		public function addSquadGlow():void {
			if (!constructed) return;
			_squadGlowTween  = null;
				
			_squadGlow.color = landTileEntity.squad.faction.strokeColor;
			_squadGlow.blurX = 0;
			_squadGlow.blurY = 0;
			
			var arr:Array = _tileSprite.filters;
			arr.push(_squadGlow);
			_tileSprite.filters = arr;
			_squadGlowTween = MLFilters.getShowPlayerGlow(_squadGlow, Settings.SQUAD_GLOW_DURATION, MAX_SQUAD_HIGHLIGHT, onAddSquadAnimUpdate, onAddSquadAnimComplete);
		}
		
		protected function onAddSquadAnimUpdate(e:TweenEvent):void {
			if (_squadGlowTween == null || _tileSprite == null) return;
			var arr:Array = ArrayUtil.remove(_tileSprite.filters, _squadGlow);
			arr.push(_squadGlow);
			_tileSprite.filters = arr;
		}
		
		protected function onAddSquadAnimComplete(e:TweenEvent):void {_squadGlowTween = null;}
		
		public function removeSquadGlow():void {
			_squadGlowTween = null;
			_tileSprite.filters = ArrayUtil.remove(_tileSprite.filters, _squadGlow);
		}
		
		//EVENTS
		override protected function onCreationComplete(e:FlexEvent):void {
			if (_callConstruct)
				construct();
			else
				createImageTile(_type + "-ico");
		}
		
		protected function onConvertLandTweenComplete(e:Event):void {
			if (_tileSprite.numChildren > 1)
				_tileSprite.removeChildAt(1);
			if(landTileEntity.squad != null)
				addSquadGlow();
		}
		
		//GETTERS
		public function get landTileEntity():Land {return _tileEntity as Land;}
		public function get constructed():Boolean {return _constructed;}
		public function get tileType():String {return _type;}
	}
}