package myriadLands.entities
{
	import gamestone.utils.ArrayUtil;
	
	public class Squad extends Entity
	{
		protected var _isCombatant:Boolean;
		protected var _equipment:Array;
		protected var _units:Array;
			
		public function Squad(dataName:String, data:EntityData)
		{
			_equipment = [];
			super(dataName, data);
			_renderableAttributes = _renderableAttributes.concat(["cruisingSpeed"]);
			this._equipment = [];
			this._units = [];
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
		
		public function get maxEquipment():int
		{
			return equ;
		}
		
		public function addEquipment(item:Equipment):void
		{
			if (item == null)
				return;
			//Check on action
			//if (availableEquipmentSlots > 0) return;
			_equipment.push(item);
			item.parentEntity = this;
			fireUpdate(false, false, true);
		}
		
		public function removeEquipment(item:Equipment):void
		{
			if (item == null)
				return;
			_equipment = ArrayUtil.remove(_equipment, item);
			item.parentEntity = null;
			fireUpdate(false, false, true);
		}
		
		public function getEquipment():Array
		{
			return _equipment;
		}
		
		public function get maxUnits():int
		{
			return unt;
		}
		
		public function addUnit(item:Unit):void
		{
			if (item == null)
				return;
			//Check on action
			//if (availableUnitSlots > 0) return;
			_units.push(item);
			item.squad = this;
			fireUpdate(false, false, true);
		}
		
		public function removeUnit(item:Unit):void
		{
			if (item == null)
				return;
			_units = ArrayUtil.remove(_units, item);
			item.squad = null;
			fireUpdate(false, false, true);
		}
		
		public function getUnits():Array
		{
			return _units;
		}
		
		public function detachUnits():void {
			var unit:Unit;
			for each (unit in getUnits()) {
				removeUnit(unit);
				unit.parentEntity = null;
			}
		}
		
		override protected function stateChanged(currentState:String, newState:String):Boolean {
			if (!super.stateChanged(currentState, newState))
				return false;
			switch (newState) {
				case EntityState.IN_WORLD_MAP:
					faction.addActiveBattlegroup(this);
				break;
				case EntityState.IN_VAULT:
					faction.removeActiveBattlegroup(this);
				break;
			}
			return true;
		}
		
		//GETTERS
		public function get availableUnitSlots():int {return unt - getUnits().length;}
		public function get availableEquipmentSlots():int {return equ - getEquipment().length;}
	}
}