package myriadLands.actions {
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.StringUtil;
	
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.entities.Squad;
	import myriadLands.entities.Unit;
	
	public class StaticCombatAuraAction extends DynamicCombatAuraAction {
		
		protected var _applyToType:Array;
		
		public function StaticCombatAuraAction(dataName:String, owner:Entity) {
			super(dataName, owner);
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			_applyToType = String(_data.attributes["applyToType"]).split(",");
		}
		
		override protected function populateEntitiesForVal():Array {
			var entities:Array = [];
			var squad:Squad = this.owner as Squad;
			//Only my entities
			for each(var unit:Unit in  squad.getUnits()) {
				if (unit.parentEntity != null)
					entities.push(unit.parentEntity);
			}
			return entities;
		}
				
		override protected function validateEntityForHighLight(entity:Entity):Entity {
			var entityOn:Entity = (entity as CombatGround).entityOn; 
			if (entityOn != null && ArrayUtil.inArrayFromArray(entityOn.data.type, _applyToType))
				return entity;
			else
				return null;
		}
	}
}