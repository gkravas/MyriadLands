package myriadLands.actions
{
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.EntityState;
	
	use namespace EntityInternal;
	
	import r1.deval.D;
	import gamestone.events.ActionEvent;	

	//Abilities are executed local for each client, independent of local or remote player.
	//If applies to entity attribute, the value must be constant
	public class AbilityAction extends Action
	{
		public static const ON_INIT:String = "onInit";
		public static const ON_WORLD_MAP_ENTERED:String = "onWorldMapEntered";
		public static const ON_DEATH:String = "onDeath";
		
		protected var _engageType:String;
		
		public function AbilityAction(dataName:String, owner:Entity)
		{
			super(dataName, owner);
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			this._engageType = removeCDATA(_data.attributes["engageType"]);
			this._noCost = true;
			this._engagable = false;
			this._canBeQuickTagged = false;
		}
		
		public function engageAbility():void {
			var args:Object = {};
			args["owner"] = _owner;
			args["action"] = this;
			switch (_engageType) {
				case ON_INIT:
					if (owner.abilitiesInitialized)
						return;
				break;
				case ON_WORLD_MAP_ENTERED:
					if (owner.state != EntityState.IN_WORLD_MAP)
						return;
				break;
				case ON_DEATH:
					if (owner.lif > 0)
						return;
				break;
			}
			engage(args);
		}
		
		override public function executeFromNet(args:Object):void {
			if (_functionality == null)
				return;
			D.eval(_functionality, null, args);
		}
	}
}