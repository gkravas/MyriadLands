package myriadLands.actions
{
	import flash.filters.ColorMatrixFilter;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.Entity;
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.faction.Faction;
	import myriadLands.ui.asComponents.WorldMapTile;
	
	public class CruiseAction extends MovementAction {
		
		//protected var targetLand:Land;
		
		public function CruiseAction(dataName:String, owner:Entity) {
			super(dataName, owner);
		}
		
		override protected function validateAction(args:Object):Boolean {
			if (!args[Action.INPUT_ENTITY] is Land) return false;
			var nextLand:Land = args[Action.INPUT_ENTITY] as Land;
			if (nextLand.inBattle) return false;
			if (nextLand.squad != null) return false;
			var currentLand:Land = owner.parentEntity as Land;
			if (currentLand == nextLand) return false;
			if (toValidateEntity != nextLand) {
				var distance:int = currentLand.calculateTileDistance(nextLand);
				if (distance <= range[MAX]) {
					setToValidateEntity(nextLand);
				}
				return false;
			} else
				return true;
		}
		
		override protected function getStaticCost(args:Object):Object {
			var land:Land = owner.parentEntity as Land;
			return {"morphid":land.crf * _morphidCost, "xylan":0, "brontite":0, "lif":0, "act":0};
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			//toValidateEntity = eManger.getEntityByID(args.lastNetArray[TARGET_LAND]);
			return cruiseSquad(toValidateEntity as Land);
		}
		
		override public function executeFromNet(args:Object):void {
			//toValidateEntity = eManger.getEntityByID(args.lastNetArray[TARGET_LAND]);
			cruiseSquad(toValidateEntity as Land);
		}
		
		protected function cruiseSquad(targetLand:Land):Boolean {
			var currentLand:Land = owner.parentEntity as Land;
			var sq:Squad = owner as Squad;
			//Kratame to tile giati to land tha allaxei
			var tile:WorldMapTile = targetLand.worldMapTile;
			tile.landTileEntity.squad = sq; 
			tile.construct();
			currentLand.squad = null;
			//swaped for squad highlight
			//tile.landTileEntity.squad = sq;
			return true;
		}
		
		override protected function onPostExecute():void {
			super.onPostExecute();
			//_lastNetArgs = toValidateEntity.networkID;
			toValidateEntity = null;
		}
		override protected function onCanceled():void {
			super.onCanceled();
			toValidateEntity = null;
		}
		
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			_lastNetArgs = toValidateEntity.networkID;
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			toValidateEntity = eManger.getEntityByID(args.lastNetArray[0]);
		}
		
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			//entity is land
			var land:Land = entity as Land;
			return (land.squad == null && (land.faction == null || land.faction.isFactionAlliance(owner.faction, [Faction.FRIEND, Faction.PLAYER]))) ? CombatHighlight.AVAILABLE : null;
		}	
	}
}