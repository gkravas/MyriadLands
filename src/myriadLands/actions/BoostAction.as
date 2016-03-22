package myriadLands.actions
{
	import flash.filters.ColorMatrixFilter;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.errors.EntityReferenceError;
	
	public class BoostAction extends HealAction {
		
		public function BoostAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			styleName = "BoostInfo";
			iconName = "boost-cur";
			//_prosimo = "+";
		}
		
		override protected function applyValueToCombatGroundEntityAttribute(x:int, y:int, value:int, attribute:String):void {
			var combatGround:CombatGround;
			try {
				combatGround = em.getEntityByID(CombatGround.PREFIX + "_" + x + "_" + y) as CombatGround;
			} catch (error:EntityReferenceError) {
				return;
			}
			combatGround.entityOn.modifyEntityFor(attribute + ":" + value + ":D", duration, styleName);
			//apply effect
			addEffects(combatGround, String(value));
		}
		
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			var entityOn:Entity = (entity as CombatGround).entityOn;
			return (entityOn != null) ? CombatHighlight.AVAILABLE : null;
		}
	}
}