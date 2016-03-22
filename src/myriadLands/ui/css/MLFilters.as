package myriadLands.ui.css
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.events.TweenEvent;
	
	import flash.filters.ColorMatrixFilter;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	
	public class MLFilters
	{
        
		public static const OCHRA:uint = 0xcccc99;
		public static const ORANGE:uint = 0xcc9933;
		public static const GREY:uint = 0x666666;
		public static const DARK_GREY:uint = 0x363636;
		public static const BLACK:uint = 0x333333;
		public static const PURPLE:uint = 0xC207EA;
		public static const BLUE:uint = 0x1707EA;
		
		public static const RED:uint = 0xFF0000;
		public static const GREEN:uint = 0x00FF00;
		public static const TRUE_BLACK:uint = 0x000000;
		
		public static const PLAYER_GLOW:uint = ORANGE;
		public static const FRIEND_GLOW:uint = 0x00FF00;
		public static const NEUTRAL_GLOW:uint = 0xFFFF00;
		public static const FOE_GLOW:uint = 0xFF0000;
		
		public static const GREYFILL:ColorMatrixFilter = new ColorMatrixFilter([0.4,0,0,0,0,0,0.4,0,0,0,0,0,0.4,0,0,0,0,0,1,0]);
		public static const ORANGEFILL:ColorMatrixFilter = new ColorMatrixFilter([0.8,0,0,0,0,0,0.6,0,0,0,0,0,0.2,0,0,0,0,0,1,0]);
		public static const MUSTARDFILL:ColorMatrixFilter = new ColorMatrixFilter([0.8,0,0,0,0,0,0.8,0,0,0,0,0,0.6,0,0,0,0,0,1,0]);
		public static const OCHRAFILL:ColorMatrixFilter = new ColorMatrixFilter([0.49,0,0,0,0,0,0.51,0,0,0,0,0,0.39,0,0,0,0,0,1,0]);
		
		public static const YELLOW_FILL:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0, 0,1,0,0, 0,0,0,0, 0,0,0,0, 0,0,1,0]);
		public static const RED_FILL:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,1,0]);
		public static const GREEN_FILL:ColorMatrixFilter = new ColorMatrixFilter([0,0,0,0,0, 0,1,0,0,0, 0,0,0,0,0, 0,0,0,1,0]);
		public static const BLUE_FILL:ColorMatrixFilter = new ColorMatrixFilter([0,0,0,0,0, 0,0,0,0,0, 0,0,1,0,0, 0,0,0,1,0]);
		
		public static const NAVIGATOR_BASE_FILL:ColorMatrixFilter = new ColorMatrixFilter([0.87,0,0,0,0,0,0.64,0,0,0,0,0,0.5,0,0,0,0,0,1,0]);
		public static const NAVIGATOR_MOUSE_OVER_FILL:ColorMatrixFilter = MUSTARDFILL;
		public static const NAVIGATOR_MOUSE_DOWN_FILL:ColorMatrixFilter = GREYFILL;
		
		public static const ENGAGE_FUNCTION_BASE_FILL:ColorMatrixFilter = ORANGEFILL;
		public static const ENGAGE_FUNCTION_MOUSE_OVER_FILL:ColorMatrixFilter = MUSTARDFILL;
		public static const ENGAGE_FUNCTION_MOUSE_DOWN_FILL:ColorMatrixFilter = GREYFILL;
		
		public static const TITLE_COLOR:uint = 0xcc9933;
		
				
		public static function getPanelOpenCloseEffect(target:Object, dur:Number, h:int, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {height:h, ease:Expo.easeInOut});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		
		public static function getPanelOpenDelayedEffect(target:Object, dur:Number, h:int, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {height:h, ease:Expo.easeInOut, delay:0.5});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		
		/*public static function getFunctionPanelAlphaOpenCloseEffect(target:Object, dur:Number, a:Number, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {alpha:a, ease:Expo.easeInOut});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		
		public static function getAttributePanelAlphaOpenEffect(target:Object, dur:Number, h:int, a:Number, listener:Function = null):TweenGroup
		{
			var gt:TweenMax = new TweenMax(target, dur * 0.5, {height:h, ease:Expo.easeInOut});
			var ga:TweenMax = new TweenMax(target._content, dur * 0.5, {alpha:a, ease:Expo.easeInOut});
			var gg:TweenGroup = new TweenGroup([gt, ga])
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gg;
		}
		
		public static function getAttributePanelAlphaCloseEffect(target:Object, dur:Number, h:int, a:Number, listener:Function = null):TweenGroup
		{
			var ga:TweenMax = new TweenMax(target._content, dur * 0.5, {alpha:a, ease:Expo.easeInOut});
			var gt:TweenMax = new TweenMax(target, dur * 0.5, {height:h, ease:Expo.easeInOut});
			var gg:TweenGroup = new TweenGroup([ga, gt])
			//changed from gt to gg
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gg;
		}
		
		public static function getToolTipFadeEffect(target:Object, dur:Number, a:Number, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {alpha:a, ease:Expo.easeInOut});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}*/
		
		public static function getWindowOpenCloseHeightEffect(target:Object, dur:Number, h:int, a:Number, listener:Function = null):TweenMax
		{
			//var g1:TweenMax = new TweenMax(target, dur, {height:h, ease:Expo.easeInOut});
			var g2:TweenMax = new TweenMax(target, dur, {alpha:a, height:h, ease:Expo.easeInOut});
			//if (listener != null)
			//	g2.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			//var gg:TimelineMax = new TimelineMax({tweens:[g1, g2], align:TweenAlign.START});
			if (listener != null)
				g2.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return g2;
		}
		
		public static function getWindowOpenCloseWidthEffect(target:Object, dur:Number, w:int, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {width:w, ease:Expo.easeInOut});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		
		public static function getEntitySelectionPanelOpenDelayedEffect(target:Object, dur:Number, w:int, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {width:w, ease:Expo.easeInOut, delay:0.5});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		
		//TWEEN FOR THE ROTATION OF THE INFO ICON WHEN ADDED ON A TILE
		public static function getRotationIconTween(target:Object, dur:Number, v:int, loops:int = 1, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {rotationY:v, ease:Linear.easeNone, repeat:loops});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		
		//TWEEN FOR DAMAGE SCORE ON BATTLE
		public static function getCombatInfoTextTween(target:Object, dur:Number, newY:int, listener:Function = null, delay:Number = 0):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {y:newY, alpha:0, delay:delay, ease:Linear.easeNone});
			gt.addEventListener(TweenEvent.START, onCombatInfoTextTweenStart, false, 0, true);
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		public static function onCombatInfoTextTweenStart(e:TweenEvent):void {
			((e.currentTarget as TweenMax).target as Label).visible = true;
		}
		
		//TWEEN FOR DAMAGE SCORE ON BATTLE
		/*public static function getPlanetRotationTween(target:Object, dur:Number, angleX:int, angleY:int, listener:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {rotationX:angleX, rotationY:angleY, ease:Linear.easeOut});
			if (listener != null)
				gt.addEventListener(TweenEvent.UPDATE, listener, false, 0, true);
			return gt;
		}*/
		public static function getMovePlanetTween(target:Object, dur:Number, offsetZ:int, onUpdate:Function = null):TweenMax
		{
			var gt:TweenMax = new TweenMax(target, dur, {z:target.z + offsetZ, ease:Linear.easeNone});
			if (onUpdate != null)
				gt.addEventListener(TweenEvent.UPDATE, onUpdate, false, 0, true);
			return gt;
		}
		
		//TWEEN FOR Login Panel
		public static function getLoginTween(target:Object, dur:Number, complete:Function = null, reverseComplete:Function = null):TweenMax
		{
			target.alpha = 0;
			
			var gt:TweenMax = new TweenMax(target, dur, {alpha:1, ease:Linear.easeInOut});
			if (complete != null)
				gt.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
			if (reverseComplete != null)
				gt.addEventListener(TweenEvent.REVERSE_COMPLETE, reverseComplete, false, 0, true);
			return gt;
		}
		
		//TWEEN FOR Aura animation
		public static function getAuraTween(target:Object, dur:Number, radius:int, loops:int, update:Function, complete:Function):TweenMax
		{
			var gt1:TweenMax = new TweenMax(target, dur, {blurX:radius, blurY:radius, ease:Circ.easeInOut});
			gt1.yoyo = true;
			gt1.repeat = loops;
			gt1.addEventListener(TweenEvent.UPDATE, update, false, 0, true);
			gt1.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
			return gt1;
		}
		
		//TWEEN FOR DAMAGE SCORE ON BATTLE
		public static function getMainMenuButtonTween(targets:Array, dur:Number, newY:int, onCompleteListener:Function = null):TimelineMax
		{	var arr:Array = [];
			var item:Canvas;
			for each(item in targets) {
				var tm:TweenMax = new TweenMax(item, dur, {y:newY, ease:Linear.easeNone});
				arr.push(tm);
			}
			var tg:TimelineMax = new TimelineMax(arr)
			
			if (onCompleteListener != null)
				tg.addEventListener(TweenEvent.COMPLETE, onCompleteListener, false, 0, true);
			return tg;
		}
		
		//TWEEN FOR deploy structure animation
		public static function getDeployStructureTween(target:Object, dur:Number, radius:int, update:Function, complete:Function):TweenMax
		{
			var gt1:TweenMax = new TweenMax(target, dur, {delay:0, blurX:radius, blurY:radius, ease:Circ.easeInOut});
			gt1.addEventListener(TweenEvent.UPDATE, update, false, 0, true);
			gt1.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
			return gt1;
		}
		
		//TWEEN FOR structure destruction animation
		//No player glow tween can be added
		public static function getDestroyStructureTween(target:Object, targetEX:Object, dur:Number, radius:int, update:Function, complete:Function):TimelineMax
		{
			var gt1:TweenMax = new TweenMax(target, dur, {blurX:radius, blurY:radius, ease:Circ.easeInOut});
			var gt2:TweenMax = new TweenMax(targetEX, dur * 0.5, {alpha:0, ease:Linear.easeOut});
			var gg:TimelineMax = new TimelineMax({tweens:[gt1, gt2], align:TweenAlign.SEQUENCE});
			gt1.addEventListener(TweenEvent.UPDATE, update, false, 0, true);
			gg.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
			return gg;
		}
		
		//TWEEN FOR player's glow show
		public static function getShowPlayerGlow(target:Object, dur:Number, radius:int, update:Function, complete:Function = null):TweenMax
		{
			var gt1:TweenMax = new TweenMax(target, dur, {alpha:1, blurX:radius, blurY:radius, ease:Circ.easeInOut});
			gt1.addEventListener(TweenEvent.UPDATE, update, false, 0, true);
			if (complete != null)
				gt1.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
			return gt1;
		}
		
		//TWEEN FOR worldMap construction
		public static function getConstructTween(target1:Object, target2:Object, dur:Number, complete:Function = null):TimelineMax {
			target2.alpha = 0;
			var gt1:TweenMax = (target1 != null) ? new TweenMax(target1, dur, {alpha:0, ease:Linear.easeOut}) : null;
			var gt2:TweenMax = new TweenMax(target2, dur, {alpha:1, ease:Linear.easeOut});
			var arr:Array = (target1 != null) ? [gt1, gt2] : [gt2];
			var gg:TimelineMax = new TimelineMax({tweens:arr, align:TweenAlign.START});
			gg.addEventListener(TweenEvent.COMPLETE, complete, false, 0, true);
			return gg;
		}
		
		//TWEEN FOR LOCATION BATTLEFIELDS MANAGEMENT
		public static function getLocationPanelTween(target:Object, dur:Number, alpha:int, newX:int, listener:Function = null):TweenMax
		{
			target.alpha = (alpha == 0) ? 1 : 0;
			var gt:TweenMax = new TweenMax(target, dur, {alpha:alpha, x:newX, ease:Linear.easeNone});
			if (listener != null)
				gt.addEventListener(TweenEvent.COMPLETE, listener, false, 0, true);
			return gt;
		}
		public function MLFilters() {}
	}
}