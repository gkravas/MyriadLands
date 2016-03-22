package myriadLands.actions
{
	import flash.filters.ColorMatrixFilter;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.EntityManager;
	
	use namespace EntityInternal;
	use namespace ActionInternal;	
	
	public class GateCombatAction extends Action {
		
		public static const ID:int = -6;
		protected static const TARGET_COMBAT_GROUND_ID:int = 0;
				
		public function GateCombatAction(dataName:String, owner:Entity) {
			super(dataName, owner);
		}
		
		override protected function validateAction(args:Object):Boolean {
			var inputEntity:Entity = args[INPUT_ENTITY] as Entity;
			if (inputEntity == toValidateEntity) return true;
			if (!(inputEntity is CombatGround)) return false;
			var combatGround:CombatGround = inputEntity as CombatGround;
			var distance:int = combatGround.calculateTileDistance(owner.faction.combatGroundBase);
			if (distance > radius) return false;
			if ((inputEntity as CombatGround).entityOn != null) return false;
			setTargetCombatGround(combatGround);
			return false;
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			var targetCombatGround:CombatGround = eManger.getEntityByID(args.lastNetArray[TARGET_COMBAT_GROUND_ID]) as CombatGround;
			if (teleportEntity(targetCombatGround)) {
				//_lastNetArgs = toValidateEntity.networkID + "," + owner.networkID;
				return true;
			}
			return false;
		}
		
		override public function executeFromNet(args:Object):void {
			var targetCombatGround:CombatGround = eManger.getEntityByID(args.lastNetArray[TARGET_COMBAT_GROUND_ID]) as CombatGround;
			teleportEntity(targetCombatGround);
		}
		
		override protected function onPostExecute():void {
			super.onPostExecute();
			owner.setActions(owner.data.availableActions);
		}
		
		override protected function onCanceled():void {
			super.onCanceled();
		}
		
		override ActionInternal function reset():void {
			if (toValidateEntity == null) return;
			owner.faction.combatGroundBase.combatMapTile.dispatchResetArea();
			(toValidateEntity as CombatGround).combatMapTile.removeIcon();
			toValidateEntity = null;
		}
		
		override protected function onSelected():void {
			(owner.faction.combatGroundBase as CombatGround).combatMapTile.dispatchLightArea(radius, 0, validateAndColorEntity);
		}
		
		protected function teleportEntity(combatGround:CombatGround):Boolean {
			combatGround.entityOn = owner;
			combatGround.combatMapTile.removeIcon();
			owner.faction.combatGroundBase.combatMapTile.dispatchResetArea();
			return true;
		}
		
		protected function setTargetCombatGround(newCombatGround:CombatGround):void {
			var combatGround:CombatGround = toValidateEntity as CombatGround;
			if (combatGround != null) {
				combatGround.combatMapTile.removeIcon();
				combatGround.combatMapTile.lightMe(CombatHighlight.AVAILABLE);
			}
			newCombatGround.combatMapTile.addIcon("gate-cur");
			newCombatGround.combatMapTile.lightMe(CombatHighlight.SELECTED);
			toValidateEntity = newCombatGround;
			_lastNetArgs = toValidateEntity.networkID;
		}
		
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			return ((entity as CombatGround).entityOn == null) ? CombatHighlight.AVAILABLE : null;
		}	
	}
}