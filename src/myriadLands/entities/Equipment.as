package myriadLands.entities
{
	public class Equipment extends Item
	{
		public function Equipment(dataName:String, data:EntityData)
		{
			super(dataName, data);
			_renderableAttributes = ["xylanPC", "morphidPC", "brontitePC", "upk", "sel" ,"gat", "lif"];
		}
		
	}
}