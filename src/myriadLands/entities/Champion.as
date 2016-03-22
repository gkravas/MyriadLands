package myriadLands.entities
{
	
	public class Champion extends Squad
	{
				
		public function Champion(dataName:String, data:EntityData)
		{
			super(dataName, data);
			_isCombatant = true;
			_renderableAttributes = ["xylanPC", "morphidPC", "brontitePC", "upk", "sel" ,"gat", "cap", "lif",
									"lifrg", "act", "actrg", "atk", "def", "crc", "mal", "equ", "unt"];
		}
	}
}