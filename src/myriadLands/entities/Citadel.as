package myriadLands.entities
{
	import gamestone.utils.ArrayUtil;
	
	import myriadLands.faction.Faction;
	
		
	public class Citadel extends Structure
	{
		protected static const CITADEL_PREFIX:String = "citadel_";
		
		public function Citadel(dataName:String, data:EntityData) {
			super(dataName, data);
		}
		
		public function fixID(newID:String):void {
			var em:EntityManager = EntityManager.getInstance();
			em.removeEntity(networkID);
			em.addOthersEntity(this, CITADEL_PREFIX + newID);
		}
		
		
		
		public function engageAbilitiesEX():void {
			engageAbilities();
			_abilitiesInitialized = true;
		}
		
		//SETTERS
		override public function set faction(value:Faction):void {
			if (_faction == value) return;
			_faction = value; 
		}
		
		//EVENTS
		//FROM STRUCTURE WITHOUT THE SUPER CALL
		override protected function stateChanged(currentState:String, newState:String):Boolean {
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
	}
}