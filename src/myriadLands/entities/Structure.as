package myriadLands.entities
{
	import gamestone.utils.ArrayUtil;
	
	public class Structure extends Entity
	{
		protected var _machineries:Array;
		
		public function Structure(dataName:String, data:EntityData)
		{
			super(dataName, data);
			_renderableAttributes = ["xylanPC", "morphidPC", "brontitePC", "upk", "sel" ,"gat", "cap", "mal", "mch"];
			this._machineries = [];
		}
		
		protected override function setDataFromXML():void
		{
			super.setDataFromXML();
		}
		
		public function addMachinery(mac:Machinery):void
		{
			if (mac == null)
				return;
			if (availableMachinerySlots <= 0) return;
			_machineries.push(mac);
			mac.parentEntity = this;			
		}
		
		public function removeMachinery(mac:Machinery):void
		{
			if (mac == null)
				return;
			_machineries = ArrayUtil.remove(_machineries, mac);
			mac.destroy();
			mac = null;
		}
		
		public function getMachineries():Array
		{
			return _machineries;
		}
		public override function getStringData():Array
		{
			var arr:Array = [];
			var value:String;
			for each(var field:String in _renderableAttributes)
			{
				value = this[field];
				arr.push(field + ": " + value);
			}
			return arr;
		}
		
		override protected function stateChanged(currentState:String, newState:String):Boolean {
			if (!super.stateChanged(currentState, newState))
				return false;
			switch (newState) {
				case EntityState.IN_WORLD_MAP:
					if (!ArrayUtil.inArray(data.type, EntityType.FLAGSTONE))
						faction.addActiveStructure(this);
				break;
				case EntityState.IN_VAULT:
					if (ArrayUtil.inArray(data.type, EntityType.FLAGSTONE))
						faction.removeFromVault(this);
					else
						faction.removeActiveStructure(this);
				break;
			}
			return true;
		}
		
		//GETTERS
		public function get availableMachinerySlots():int {return mch - getMachineries().length;}
	}
}