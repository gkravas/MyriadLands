package myriadLands.parsers {

	import flash.geom.Point;
	
	import gamestone.graphics.ImgInitParams;
	import gamestone.graphics.ImgParser;
	
	public class DefaultImgParser extends ImgParser {
	
		public override function getProccessedNodes(image:XML):Array {
			var id:String = String(image.@id);
			var categories:Array = String(image.@cat).split(",");
			var cat:String;
			var type:String = String(image.@type);
			var obj:ImgInitParams;
			var slices:Array = [1, 1];
			var pivotPoint:Point = new Point(0, 0);
			
			var images:Array = [];
			
			for each(cat in categories){
				obj = new ImgInitParams;
				obj.id = id + "-" + cat;
				obj.file = cat + "/" + id + "." + type;
				obj.slices = slices;
				obj.pivotPoint = pivotPoint;
				images.push(obj);
			}
			
			return images;
		}
	}
}