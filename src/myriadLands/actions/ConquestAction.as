package myriadLands.actions
{
	import flash.filters.ColorMatrixFilter;
	
	import gamestone.events.SoundsEvent;
	import gamestone.utils.NumberUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.core.Settings;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.faction.Faction;
	
	use namespace EntityInternal;

	public class ConquestAction extends OperationAction {
		
		//protected static const TARGET_LAND:int = 0;
		//protected static const GRID_SIZE:int = 1;
		
		protected var _gridSize:int;
		
		public function ConquestAction(dataName:String, owner:Entity)	{
			super(dataName, owner);
		}
		
		override protected function validateAction(args:Object):Boolean {
			if (!args[Action.INPUT_ENTITY] is Land) return false;
			var nextLand:Land = args[Action.INPUT_ENTITY] as Land;
			if (nextLand.faction == owner.faction) return false;
			if (nextLand.squad == null) return false;
			if (nextLand.squad.faction == owner.faction) return false;
			var currentLand:Land = owner.parentEntity as Land;
			if (currentLand == nextLand) return false;
			if (toValidateEntity != nextLand) {
				setToValidateEntity(nextLand);
				return false;
			} else
				return true;
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			//_gridSize = NumberUtil.random(toValidateEntity.grd[0], toValidateEntity.grd[1]);
			//_lastNetArgs = toValidateEntity.networkID + "," + _gridSize;
			//_gridSize = parseInt(args.lastNetArray[GRID_SIZE]);
			//toValidateEntity = eManger.getEntityByID(args.lastNetArray[TARGET_LAND]) as Land;
			playSound(3, fakeConquestLand);
			return true;
		}
		
		override public function engageFunctionalityExternal(args:Object = null):Boolean {
			toValidateEntity = args.toValidateEntity;
			return engageFunctionality(args);
		}
		
		override public function executeFromNet(args:Object):void {
			//toValidateEntity = eManger.getEntityByID(args.lastNetArray[TARGET_LAND]) as Land;
			//_gridSize = parseInt(args.lastNetArray[GRID_SIZE]);
			if (owner.faction != Settings.player && (toValidateEntity as Land).squad.faction != Settings.player) {
				(toValidateEntity as Land).mapTile.addIcon(iconName);
				(toValidateEntity as Land).setInBattle(true);
				return;
			}
			playSound(3, fakeConquestLand);
		}
		
		protected function fakeConquestLand(event:SoundsEvent):Boolean {
			conquestLand(toValidateEntity as Land, _gridSize);
			return true;
		}
		
		protected function conquestLand(targetLand:Land, gridSize:int):Boolean {
			targetLand.attack(owner as Squad, gridSize);
			return true;
		}
		
		override protected function onPostExecute():void {
			(toValidateEntity as Land).mapTile.removeIcon();
		}
		
		//NETWORKING encode, decode
		override public function encodeNetworkArgs(args:Object):void {
			_lastNetArgs = toValidateEntity.networkID + "," + NumberUtil.random(toValidateEntity.grd[0], toValidateEntity.grd[1]);
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			toValidateEntity = eManger.getEntityByID(args.lastNetArray[0]) as Land;
			//1 is size of battle grid
			_gridSize = parseInt(args.lastNetArray[1]);
		}
		
		//LIGHTING CALLBACK
		override protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			//entity is land
			var land:Land = entity as Land;
			return (land.squad != null && land.faction != null && land.faction.isFactionAlliance(owner.faction, [Faction.NEUTRAL, Faction.FOE])) ? CombatHighlight.AVAILABLE : null;
		}	
	}
}