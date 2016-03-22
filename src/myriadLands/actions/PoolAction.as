package myriadLands.actions {
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityManager;
	
	
	public class PoolAction extends Action {
		
		public function PoolAction(dataName:String, owner:Entity) {
			super(dataName, owner);
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			if (this._netFunctionality == null)
				this._netFunctionality = _functionality;
		}
		
		override public function encodeNetworkArgs(args:Object):void {
			_lastNetArgs = args.entityToApply.networkID;
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			args.entityToApply = EntityManager.getInstance().getEntityByID(args.lastNetArray[0]);
		}
	}
}