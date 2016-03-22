package myriadLands.ui.buttons {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import gamestone.display.MySprite;
	import gamestone.graphics.ImgLoader;
	import gamestone.graphics.RGB;
	
	import mx.core.BitmapAsset;

	public class LocationButton extends Sprite {
		
		public function LocationButton(){
			super();
			
			var ba:BitmapAsset = ImgLoader.getInstance().getBitmapAsset("circle-nav");
			ba.transform.colorTransform = MySprite.getColorTransformFromRGB(new RGB(0, 255, 0), new RGB(0, 0, 0));
			addChild(ba);
						
			scaleX = 0.4;
			scaleY = 0.4;
		}
		
	}
}