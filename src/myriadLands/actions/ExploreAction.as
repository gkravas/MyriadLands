package myriadLands.actions {
	
	import myriadLands.entities.Entity;
	import myriadLands.entities.Ruin;

	public class ExploreAction extends OperationAction {
		
		public function ExploreAction(id:String, owner:Entity) {
			super(id, owner);
		}
		//NETWORK ENCODE, DECODE
		override public function encodeNetworkArgs(args:Object):void {
			//0 is ruins name
			_lastNetArgs = Ruin.getRandomRuin();
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			//0 is ruins name
			args["ruinName"] = args.lastNetArray[0];
			toValidateEntity = owner.parentEntity;
		}
	}
}