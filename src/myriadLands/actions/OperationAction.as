package myriadLands.actions {
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityManager;
	import myriadLands.entities.Land;
	import myriadLands.faction.Faction;
	import myriadLands.ui.asComponents.HighlightUtil; 

	public class OperationAction extends Action {
		
		protected var _validatedEntities:Array;
		
		public function OperationAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			appliesMalus = true;
			iconName = "operation-cur";
			hlUtil = new HighlightUtil(CombatHighlight.AVAILABLE);
			getEntitiesForHLValFunction = function a():Array {return EntityManager.getInstance().getLands();};
		}
		
		override protected function onCanceled():void {
			super.onCanceled();
			toValidateEntity = null;
		}
		
		override protected function onPostExecute():void {
			super.onPostExecute();
			toValidateEntity = null;
		}
		//NETWORK ENCODE, DECODE
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			_lastNetArgs = toValidateEntity.networkID;
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			toValidateEntity = eManger.getEntityByID(args.lastNetArray[0]);
		}
	}
}