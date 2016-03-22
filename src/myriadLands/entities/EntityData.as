package myriadLands.entities
{
	import mx.utils.ObjectUtil;
	
	
	[Bindable]
	public class EntityData
	{
		
		public var name:String;
		public var className:String;
		public var type:Array;
		public var attributes:Object;
		public var availableActions:Array;
		public var abilities:Array;
		
		public function EntityData()
		{
			attributes = {};
			availableActions = [];
			abilities = [];
		}
	}
}