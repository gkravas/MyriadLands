package myriadLands.entities
{	
	public class Unit extends Entity
	{
		protected var _squad:Squad;
		 
		public function Unit(dataName:String, data:EntityData) {
			super(dataName, data);
			_renderableAttributes = ["xylanPC", "morphidPC", "brontitePC", "upk", "sel" ,"gat", "cap", "lif",
									"lifrg", "act", "actrg", "atk", "def", "crc"];
		}
		
		//SETTERS
		public function set squad(v:Squad):void {_squad = v;}
		//GETTERS
		public function get squad():Squad {return _squad;};
	}
}