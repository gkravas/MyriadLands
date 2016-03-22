package myriadLands.entities
{
	import gamestone.utils.ArrayUtil;
	import myriadLands.loaders.EntityLoader;
	
	public class Ruin extends Structure {
		public function Ruin(dataName:String, data:EntityData) {
			super(dataName, data);
		}
		
		public static function getRandomRuin():String {
			return ArrayUtil.getRandomValue(EntityLoader.getInstance().getEntityNamesByType([EntityType.RUIN])) as String;
		}
	}
}