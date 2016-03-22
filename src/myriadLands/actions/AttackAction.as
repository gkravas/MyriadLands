package myriadLands.actions {
	
	import flash.filters.ColorMatrixFilter;
	import gamestone.utils.NumberUtil;
	import gamestone.utils.StringUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityManager;
	import myriadLands.errors.EntityReferenceError;

	public class AttackAction extends Action {
		
		protected var em:EntityManager;
		protected var _prosimo:String;
		public var isCritical:Boolean;
		public var finalDamage:int;
		
		public function AttackAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			em = EntityManager.getInstance(); 
			styleName = "DamageInfo";
			iconName = "attack-cur";
			_prosimo = "-";
		}
				
		override protected function validateAction(args:Object):Boolean {
			//this is for some attacks with center of damage the owner
			if (!requiersInput) {
				var returnValue:Boolean = super.validateAction(args);
				if (returnValue)
					toValidateEntity = owner.parentEntity;
				return returnValue;
			}
			
			if (owner.parentEntity == null) return false;
			var inputEntity:Entity = args[INPUT_ENTITY] as Entity;
			if (!(inputEntity is CombatGround)) return false;
			if ((inputEntity as CombatGround).entityOn == null) return false;
			if (toValidateEntity == inputEntity) return true;
			var combatGround:CombatGround = inputEntity as CombatGround;
			var distance:int = (owner.parentEntity as CombatGround).calculateTileDistance(combatGround);
			//(owner.parentEntity as CombatGround).combatMapTile.dispatchLightPath(combatGround.combatMapTile.tileX, combatGround.combatMapTile.tileY, range[0], range[1]);
			if (distance >= range[0] && distance <= range[1])
				setToValidateEntity(combatGround);
			else
				resetToValidateEntity(toValidateEntity);
			return false;
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			
			if (isCritical)
				finalDamage *= 2;
			//if (!_requiersInput)
			//	toValidateEntity = owner.parentEntity;
			var returnValue:Boolean = applyToEntity(toValidateEntity as CombatGround, finalDamage);
			//_lastNetArgs = toValidateEntity.networkID + "," + finalDamage + "," + String((isCritical) as int);
			return returnValue;
		}
		
		override public function engageFunctionalityExternal(args:Object = null):Boolean {
			toValidateEntity = args.toValidateEntity;
			return engageFunctionality(args);
		}
		
		override public function executeFromNet(args:Object):void {
			if (isCritical)
				finalDamage *= 2;
			//if (!_requiersInput)
			//	toValidateEntity = owner.parentEntity;
			var returnValue:Boolean = applyToEntity(toValidateEntity as CombatGround, finalDamage);
		}
		/*override public function configForScriptExecution(args:Object):void {
			finalDamage = (-1 * NumberUtil.randomInt(damage[0], damage[1]) + owner.extraDmg);
			isCritical = getCriticalChance();
			toValidateEntity = (owner.lastParentEntity != null) ? owner.lastParentEntity : owner.parentEntity;
		}*/
		/*override protected function onSelected():void {
			if (owner.parentEntity == null) return;
			(owner.parentEntity as CombatGround).combatMapTile.dispatchLightArea(range[1], range[0], validateAndColorEntity);
		}*/
		
		override protected function onPostExecute():void {
			super.onPostExecute();
			toValidateEntity = null;
			isCritical = false;
		}
		
		override protected function onCanceled():void {
			super.onCanceled();
			toValidateEntity = null;
			isCritical = false;
		}
		
		protected function applyToEntity(combatGround:CombatGround, value:int):Boolean {
			var i:int, j:int;
			var initX:int = combatGround.combatMapTile.tileX;
			var initY:int = combatGround.combatMapTile.tileY;
			for (i = (1-radius); i < radius; i++) {
				for (j = (1-radius); j < radius; j++) {
					applyValueToCombatGroundEntityAttribute(initX + i, initY + j, value, _attributeToApply);
				}
			}
			resetHighLightAndRemoveIcons();
			return true;
		}
		
		protected function applyValueToCombatGroundEntityAttribute(x:int, y:int, value:int, attribute:String):void {
			var combatGround:CombatGround;
			try {
				combatGround = em.getEntityByID(CombatGround.PREFIX + "_" + x + "_" + y) as CombatGround;
			} catch (error:EntityReferenceError) {
				return;
			}
			
			var text:String;
			if (combatGround.entityOn == null)
				return;
			if (isCritical) {
				combatGround.entityOn.addToAttribute(attribute, value);
				text = String(Math.abs(value * 0.5)) + " x 2";
			} else {
				combatGround.entityOn.addToAttribute(attribute, value);
				text = String(Math.abs(value));
			}
			
			text += " " + _d.getLeema(attribute);
			//apply effect
			addEffects(combatGround, text);
		}
		
		protected function addEffects(combatGround:CombatGround, text:String):void {
			combatGround.combatMapTile.addAnimatedText(_prosimo + " " + String(text), styleName);
		}
		
		/*protected function setTargetCombatGround(newCombatGround:CombatGround):void {
			var combatGround:CombatGround = toValidateEntity as CombatGround;
			if (combatGround != null) {
				combatGround.mapTile.removeIcon();
				combatGround.combatMapTile.toggleLightToPreviousColor();
			}
			if (newCombatGround != null) {
				newCombatGround.mapTile.addIcon(iconName + "-cur");
				newCombatGround.combatMapTile.lightMe(CombatHighlight.SELECTED);
			}
			toValidateEntity = newCombatGround;
		}*/
		
		public function getCriticalChance():Boolean {
			var critical:Number = this.owner.crc / 100; 
			return NumberUtil.randomDecision(critical)
		}
		//NETWORK ENCODE, DECODE
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidateEntity
			//1 is damage
			//2 is critical
			_lastNetArgs = toValidateEntity.networkID + "," + (-1 * NumberUtil.randomInt(damage[0], damage[1]) + owner.extraDmg) + "," + getCriticalChance();
		}
		override public function decodeNetworkArgs(args:Object):void {
			toValidateEntity = eManger.getEntityByID(args.lastNetArray[0]);
			finalDamage = parseInt(args.lastNetArray[1]);
			isCritical = StringUtil.parseBoolean(args.lastNetArray[2]);
		}
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			var entityOn:Entity = (entity as CombatGround).entityOn;
			if (entityOn == null) return null;
			return (entityOn.faction != owner.faction) ? CombatHighlight.AVAILABLE : null;
		}	
	}
}