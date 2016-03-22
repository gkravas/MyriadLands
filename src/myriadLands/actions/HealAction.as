package myriadLands.actions
{
	import flash.filters.ColorMatrixFilter;
	
	import gamestone.utils.NumberUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;

	public class HealAction extends AttackAction
	{
		public function HealAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			styleName = "HealInfo";
			iconName = "heal-cur";
			_prosimo = "+";
		}
		//NETWORK ENCODE, DECODE
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidateEntity
			//1 is damage
			//2 is critical
			_lastNetArgs = toValidateEntity.networkID + "," + (-1 * NumberUtil.randomInt(damage[0], damage[1])) + "," + getCriticalChance();
		}
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			var entityOn:Entity = (entity as CombatGround).entityOn;
			return (entityOn != null) ? CombatHighlight.AVAILABLE : null;
		}
	}
}