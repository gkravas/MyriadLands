package myriadLands.entities
{
	public class Machinery extends Item
	{
		public function Machinery(dataName:String, data:EntityData)
		{
			super(dataName, data);
			_renderableAttributes = ["rpc", "upk", "sel" ,"gat"];
		}
		
	}
}