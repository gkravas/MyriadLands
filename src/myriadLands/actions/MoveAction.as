package myriadLands.actions
{
	import gamestone.utils.NumberUtil;
	
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.events.ActionEvent;

	use namespace ActionInternal;
	
	public class MoveAction extends MovementAction {
				
		protected var _distance:int;
		
		public function MoveAction(dataName:String, owner:Entity)
		{
			super(dataName, owner);
		}
		
		override public function calcultateDynamicCost():Object {
			var context:Object =  {"morphid":morphidCost, "xylan":0, "brontite":0, "lif":lifCost,
									"act":actCost * _distance};
			return context;
		}
		
		override protected function validateAction(args:Object):Boolean {
			if (owner.parentEntity == null) return false;
			var inputEntity:Entity = args[INPUT_ENTITY] as Entity;
			if (!(inputEntity is CombatGround)) return false;
			if (toValidateEntity == inputEntity) return true;
			var combatGround:CombatGround = inputEntity as CombatGround;
			if (combatGround.entityOn != null) return false;
			_distance = (owner.parentEntity as CombatGround).calculateTileDistance(combatGround);
			dispatchEvent(new ActionEvent(ActionEvent.UPDATE_DYNAMIC_COST, this));
			(owner.parentEntity as CombatGround).combatMapTile.dispatchLightPath(combatGround.combatMapTile.tileX, combatGround.combatMapTile.tileY, 2, (owner.act / actCost + 1));
			if (calcultateDynamicCost().act <= owner.act)
				setTargetCombatGround(combatGround);
			else
				setTargetCombatGround(null);
			return false;
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			return moveEntity(eManger.getEntityByID(args.lastNetArray[TARGET_LAND]) as CombatGround);
		}
		
		override public function engageFunctionalityExternal(args:Object = null):Boolean {
			toValidateEntity = args.toValidateEntity;
			return engageFunctionality(args);
		}
		
		override public function executeFromNet(args:Object):void {
			moveEntity(eManger.getEntityByID(args.lastNetArray[TARGET_LAND]) as CombatGround);
		}
		
		protected function moveEntity(combatGround:CombatGround):Boolean {
			(owner.parentEntity as CombatGround).entityOn = null;
			combatGround.entityOn = owner;
			combatGround.mapTile.removeIcon();
			return true;
		}
				
		protected function setTargetCombatGround(newCombatGround:CombatGround):void {
			var combatGround:CombatGround = toValidateEntity as CombatGround;
			if (combatGround != null)
				combatGround.mapTile.removeIcon();
			if (newCombatGround != null)
				newCombatGround.mapTile.addIcon("move-cur");
			toValidateEntity = newCombatGround;
			_lastNetArgs = toValidateEntity.networkID;
		}
		
		override protected function onSelected():void {
		}
		
		override protected function onPostExecute():void {
			super.onPostExecute();
			(owner.parentEntity as CombatGround).combatMapTile.dispatchResetPath();
			toValidateEntity = null;
		}
		
		override ActionInternal function reset():void {
			if (owner.parentEntity == null) return;
			if (toValidateEntity != null)
				(toValidateEntity as CombatGround).mapTile.removeIcon();
			toValidateEntity = null;
			(owner.parentEntity as CombatGround).combatMapTile.dispatchResetPath();
		}
	}
}