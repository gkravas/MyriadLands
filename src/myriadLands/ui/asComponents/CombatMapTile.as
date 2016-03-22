package myriadLands.ui.asComponents
{
	import com.greensock.TweenMax;
	import com.greensock.events.TweenEvent;
	
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import gamestone.utils.ArrayUtil;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import myriadLands.core.Settings;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.fx.FXManager;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.ui.css.MLFilters;
	
	public class CombatMapTile extends MapTile {
		
		public static const GRID_TERRAIN_PREFIC:String = "gridTerrain0#-cbt";
		public static const MAX_ENTITY_ON_HIGHLIGHT:int = 15;
		
		protected var _entityOnGlow:GlowFilter;
		protected var _entityOnGlowTween:TweenMax;
		
		public function CombatMapTile(tileNumber:int, tileSpec:int) {
			super(tileNumber, tileSpec);
			_tileSpec = tileSpec;
			_tileNumber = tileNumber;
			toolTip = String(tileNumber);
			
			_tileEntity = EntityLoader.getInstance().getEntity(GRID_TERRAIN_PREFIC.replace("0#-cbt", ""), null);
			_tileEntity.mapTile = this;
			createEntityOnGlow();
		}
				
		public function addEntityOn(entinty:Entity):void {
			_entityOn = new UIComponent();
			_entityOn.addChild(entinty.getBitmapAssetIco());
			// _entityOnSprite.setFlipHorizontal();
			_entityOn.mouseEnabled = false;
			addChild(_entityOn);
			addEntityOnGlow();
			//setPlayerGlow();
		}
		
		public function removeEntityOn():void {
			if (_entityOn == null) return;
			removeAura();
			removeEntityOnGlow();
			removeChild(_entityOn);
			_entityOn = null;
		}
				
		override public function addIcon(name:String):void {
			var pos:Point = new Point;
			pos.x = x + width * 0.5;
			pos.y = -y -height * 0.8;
			_fxIndex = FXManager.getInstance().addCombatMapActionIconPlane(name, pos);
		}
		
		override public function removeIcon():void {
			FXManager.getInstance().removeCombatMapActionIconPlane(_fxIndex);
		}
		//Unit Glow
		protected function createEntityOnGlow():void {
			_entityOnGlow = new GlowFilter();
			_entityOnGlow.inner = true;
			_entityOnGlow.alpha = 1;
			_entityOnGlow.quality = BitmapFilterQuality.HIGH;
		}
		
		public function addEntityOnGlow():void {
			_entityOnGlowTween  = null;
				
			_entityOnGlow.color = combatGround.entityOn.faction.strokeColor;
			_entityOnGlow.blurX = 0;
			_entityOnGlow.blurY = 0;
			
			var arr:Array = _tileSprite.filters;
			arr.push(_entityOnGlow);
			_tileSprite.filters = arr;
			_entityOnGlowTween = MLFilters.getShowPlayerGlow(_entityOnGlow, Settings.ENTITY_ON_GLOW_DURATION, MAX_ENTITY_ON_HIGHLIGHT, onAddEntityOnAnimUpdate, onAddEntityOnAnimComplete);
		}
		
		protected function onAddEntityOnAnimUpdate(e:TweenEvent):void {
			if (_entityOnGlowTween == null || _entityOn == null) return;
			var arr:Array = ArrayUtil.remove(_tileSprite.filters, _entityOnGlow);
			arr.push(_entityOnGlow);
			_tileSprite.filters = arr;
		}
		
		protected function onAddEntityOnAnimComplete(e:TweenEvent):void {_entityOnGlowTween = null;}
		
		public function removeEntityOnGlow():void {
			_entityOnGlowTween = null;
			_tileSprite.filters = ArrayUtil.remove(_tileSprite.filters, _entityOnGlow);
		}
				
		//EVENTS
		override protected function onCreationComplete(e:FlexEvent):void {
			createImageTile(GRID_TERRAIN_PREFIC.replace("#", _tileSpec));
		}
				
		//SETTERS
		
		
		//GETTERS
		public function get combatGround():CombatGround {return tileEntity as CombatGround;}
	}
}