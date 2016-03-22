package myriadLands.actions {
	
	import flash.filters.ColorMatrixFilter;
	
	import gamestone.utils.NumberUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.Entity;
	import myriadLands.entities.Land;

	public class RaidAction extends ConquestAction {
		
		public function RaidAction(dataName:String, owner:Entity) {
			super(dataName, owner);
		}
		
		override protected function validateAction(args:Object):Boolean {
			if (!args[Action.INPUT_ENTITY] is Land) return false;
			var nextLand:Land = args[Action.INPUT_ENTITY] as Land;
			if (nextLand.faction != null) return false;
			if (nextLand.squad == null) return false;
			if (nextLand.squad.faction == owner.faction) return false;
			var currentLand:Land = owner.parentEntity as Land;
			if (currentLand == nextLand) return false;
			if (toValidateEntity != nextLand) {
				setToValidateEntity(nextLand);
				return false;
			} else
				return true;
		}
		
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			//entity is land
			var land:Land = entity as Land;
			return (land.squad != null && land.faction == null) ? CombatHighlight.AVAILABLE : null;
		}	
	}
}