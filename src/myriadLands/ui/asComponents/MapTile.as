 package myriadLands.ui.asComponents
{
	import away3d.cameras.TargetCamera3D;
	import away3d.containers.View3D;
	import away3d.primitives.Plane;
	
	import com.greensock.TweenMax;
	import com.greensock.events.TweenEvent;
	
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import gamestone.graphics.ImgLoader;
	import gamestone.utils.ArrayUtil;
	
	import mx.containers.Canvas;
	import mx.controls.*;
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import myriadLands.combat.MapNode;
	import myriadLands.core.Settings;
	import myriadLands.entities.Tile;
	import myriadLands.events.MapTileEvent;
	import myriadLands.fx.FXManagerOld;
	import myriadLands.ui.css.MLFilters;
	
	public class MapTile extends Canvas {
			
		//protected static const ICON:String = "icon";
		protected static const MAX_AURA_LOOP_COUNT:int = 5;
		
		protected var _previousColor:ColorMatrixFilter;
		
		protected var _tileEntity:Tile;
		protected var _tileSprite:UIComponent;
		protected var _entityOn:UIComponent;
		
		protected var glow:GlowFilter;
		protected var aura:GlowFilter;
		
		protected var _tileNumber:int;
		protected var _tileSpec:int;
		protected var _tileX:int;
		protected var _tileY:int;
		
		protected var _fxIndex:int;
		//protected var auraLoopCnt:int;
		protected var auraTween:TweenMax;
		protected var _lightState:ColorMatrixFilter;
		
		protected var _mapNode:MapNode;
		
		public function MapTile(tileNumber:int, tileSpec:int) {
			super();
			verticalScrollPolicy = "false";
			horizontalScrollPolicy = "false";
			_tileNumber = tileNumber;
			_tileSpec = tileSpec;
       		addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
		}
		
		protected function createImageTile(imageName:String):void {
			_tileSprite = new UIComponent();
			_tileSprite.addChild(getLandBitmapAsset(imageName));
			_tileSprite.mouseEnabled = false;
			_tileSprite.x = 0;
			_tileSprite.y = 0;
			addChild(_tileSprite);
		}

		public function isVisibleAreaHited(x:int, y:int):Boolean {
			var bmp:BitmapAsset = _tileSprite.getChildAt(0) as BitmapAsset;
			var a:uint = bmp.bitmapData.getPixel32(x, y);
			var bmpSt:BitmapAsset;
			return a != 0;
		}
						
		protected function getLandBitmapAsset(id:String):BitmapAsset {
			return ImgLoader.getInstance().getBitmapAsset(id);
		}
		
		//ICON MANAGMENT
		public function addIcon(name:String):void {
		}
		
		public function removeIcon():void {
		}
		
		public function toggleLightToPreviousColor():void {
			if (_previousColor == null)
				darkMe();
			else
				lightMe(_previousColor);
		}
		
		//For critical areas glow
		public function showPlayerGlow():void {
			glow = new GlowFilter();
			glow.color = tileEntity.faction.strokeColor;
			glow.alpha = 0;
			glow.blurX = 0;
			glow.blurY = 0;
			glow.quality = BitmapFilterQuality.HIGH;
			_entityOn.filters = [glow];
			MLFilters.getShowPlayerGlow(glow, Settings.SHOW_PLAYER_GLOW_DURATION, 25, onGlowUpdate);
		}
		
		protected function onGlowUpdate(e:TweenEvent):void {
			if (glow == null) return;
			_entityOn.filters = [glow];
		}
		
		public function removePlayerGlow():void {
			_entityOn.filters = ArrayUtil.remove(_entityOn.filters, glow);
			glow = null;
		}
		//
		
		//For aura
		public function showAura(color:uint):void {
			if (_entityOn == null) return;
			//auraLoopCnt = 0;
			aura = new GlowFilter();
			aura.color = color;
			aura.alpha = 1;
			aura.blurX = 0;
			aura.blurY = 0;
			aura.quality = BitmapFilterQuality.HIGH;
			if (auraTween != null) {
				auraTween.pause();
				auraTween = null;
			}
			auraTween = MLFilters.getAuraTween(aura, 2, 25, MAX_AURA_LOOP_COUNT, onAuraUpdate, hideAura);
		}
		
		protected function onAuraUpdate(e:TweenEvent):void {
			if (auraTween == null || _entityOn == null) return;
			_entityOn.filters = [aura];
		}
		
		protected function hideAura(e:Event):void {
			if (_entityOn == null) return;
			//auraLoopCnt++;
			//if (auraLoopCnt <= MAX_AURA_LOOP_COUNT) return;
			_entityOn.filters = ArrayUtil.remove(_entityOn.filters, aura);
			auraTween = null;
			if (glow != null) {
				showPlayerGlow();
			}
		}
		
		public function removeAura():void {
			if (_entityOn == null) return;
			_entityOn.filters = ArrayUtil.remove(_entityOn.filters, aura);
			auraTween = null;
			if (glow != null) {
				showPlayerGlow();
			}
		}
		
		//MESSAGES
		public function addAnimatedTextArray(text:Array, styleName:String):void {
			var txt:String;
			var delay:Number = 0;
			for each (txt in text) {
				addAnimatedText(txt, styleName, delay);
				delay += 1;
			}
		}
		
		public function addAnimatedText(text:String, styleName:String, delay:Number = 0):void {
			var txt:Label = new Label();
			txt.truncateToFit = true;
			txt.toolTip = String(delay);
			txt.styleName = styleName;
			txt.text = text;
			txt.x = width * 0.5;
			txt.y = height * (2/3);
			txt.addEventListener(FlexEvent.CREATION_COMPLETE, onAnimatesTextCreationComplete, false, 0, true);
			txt.visible = false;
			addChild(txt);
		}
		
		//For lighting
		public function lightMe(lightState:ColorMatrixFilter):void {
			if (lightState == null) return;
			if (ArrayUtil.inArray(_tileSprite.filters, _lightState)) _previousColor = _lightState;
			var arr:Array = _tileSprite.filters;
			arr = ArrayUtil.remove(_tileSprite.filters, _lightState);
			arr.push(lightState); 
			_lightState = lightState;
			_tileSprite.filters = arr;
		}
		
		public function darkMe():void {
			_tileSprite.filters = ArrayUtil.remove(_tileSprite.filters, _previousColor);
			_tileSprite.filters = ArrayUtil.remove(_tileSprite.filters, _lightState);
			_previousColor = null;
		}
		
		public function setTileGridCoords(x:int, y:int):void {
			_tileX = x;
			_tileY = y;
		}
		
		public function scrollToMe():void {
			var map:TiledMap = this.parent.parent as TiledMap;
			map.scrollToMapTile(this);
		}
		
		public function dispatchLightPath(endTileX:int, endTileY:int, minTileNum:int, maxTileNum:int):void {
			dispatchEvent(new MapTileEvent(MapTileEvent.LIGHT_PATH, null, 
						{0:tileX, 1:tileY, 2:endTileX, 3:endTileY, 4:minTileNum, 5:maxTileNum}));
		}
		
		public function dispatchResetPath():void {
			dispatchEvent(new MapTileEvent(MapTileEvent.RESET_PATH));
		}
		
		public function dispatchLightArea(tileRadius:int, offset:int, validationFunction:Function = null):void {
			dispatchEvent(new MapTileEvent(MapTileEvent.LIGHT_AREA, null,
							{0:tileX, 1:tileY, 6:tileRadius, 7:offset, 8:validationFunction}));
		}
		
		public function dispatchResetArea():void {
			dispatchEvent(new MapTileEvent(MapTileEvent.RESET_AREA));
		}
		
		//EVENTS
		protected function onCreationComplete(e:FlexEvent):void {
		}
		
		protected function onIconCreationComplete(e:FlexEvent):void {
			//_iconRotate = new PivotRotate(_icon, new Point(_icon.width * 0.5, _icon.height * 0.5)); 
			//MLFilters.getRotationIconTween(_iconRotate, 4, 360);
		}
		
		protected function onAnimatesTextCreationComplete(e:FlexEvent):void {
			MLFilters.getCombatInfoTextTween(e.currentTarget, 1, 0, removeAnimatedText, parseInt(e.currentTarget.toolTip));
			e.currentTarget.toolTip = null;
		}
		
		protected function removeAnimatedText(e:TweenEvent):void {
			removeChild((e.currentTarget as TweenMax).target as Label);
		}
		
		//SETTERS
		public function set mapNode(v:MapNode):void {_mapNode = v;}
		public function set tileNumber(v:int):void {trace(_tileNumber + " = " + v); _tileNumber = v;}
		
		//GETTERS
		public function get mapNode():MapNode {return _mapNode;}
		public function get tileEntity():Tile {return _tileEntity;}
		public function get tileNumber():int {return _tileNumber;}
		public function get tileX():int {return _tileX;}
		public function get tileY():int {return _tileY;}
	}
}