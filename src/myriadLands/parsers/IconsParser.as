package myriadLands.parsers {

	import flash.geom.Point;
	
	import gamestone.graphics.ImgInitParams;
	import gamestone.graphics.ImgParser;
	
	import mx.utils.StringUtil;
	
	public class IconsParser extends ImgParser {
	
		public override function getProccessedNodes(image:XML):Array {
			var id:String = String(image.@id);
			var imgs:Array = StringUtil.trimArrayElements(String(image),",").split(",");
			var path:String  = String(image.@path);
			var pivotPoint:Point = parsePivot(image.@pivot);
			var type:String = String(image.@type);
			var img:String;
			var obj:ImgInitParams;
			var slices:Array = [1, 1];

			
			var images:Array = [];
			
			for each(img in imgs){
				obj = new ImgInitParams;
				obj.id = img + "-" + id;
				obj.file = path + "/" + img + "." + type;
				obj.slices = slices;
				obj.pivotPoint = pivotPoint;
				images.push(obj);
			}
			
			return images;
		}
	}
}