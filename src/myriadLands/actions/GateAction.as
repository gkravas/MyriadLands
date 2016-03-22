package myriadLands.actions
{
	import flash.filters.ColorMatrixFilter;
	
	import gamestone.utils.ArrayUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.core.Settings;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityState;
	import myriadLands.entities.EntityType;
	import myriadLands.entities.Equipment;
	import myriadLands.entities.Land;
	import myriadLands.entities.Machinery;
	import myriadLands.entities.Squad;
	import myriadLands.entities.Structure;
	import myriadLands.entities.Unit;
	import myriadLands.events.ActionEvent;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.ui.asComponents.HighlightUtil;
	
	use namespace ActionInternal;

	public class GateAction extends Action {
		public static const GATE_ENTITY:String = "gateEntity";
		
		protected static const TARGET_LAND_ID:int = 0;
		protected static const GATE_ENTITY_ID:int = 1;
		
		protected var _allowedEntities:Array;
		protected var _gateEntity:Entity;
		
		public function GateAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			//False because you have to select for gate list first
			iconName = "gate-cur";
			highLightsMap = false;
			hlUtil = new HighlightUtil(CombatHighlight.AVAILABLE, null);
			var cm:CentralManager = CentralManager.getInstance();
			addEventListener(ActionEvent.POPULATE_GATE_PANEL, cm.populateGatePanel, false, 0, true);
			addEventListener(ActionEvent.RESET_GATE_PANEL, cm.resetGatePanel, false, 0, true);
			getEntitiesForHLValFunction = function a():Array {return owner.faction.getEntities()};
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			var allowedEntities:Array = String(_data.attributes["allowedEntities"]).split(",");
			this._allowedEntities = EntityLoader.getInstance().getEntityNamesByType(allowedEntities);
			this.chargeStaticCost = false;
			_soundID = "gate";
		}
		
		override protected function getStaticCost(args:Object):Object {
			return {"morphid":0, "xylan":0, "brontite":0, "lif":0, "act":0};
		}
		
		override public function calcultateDynamicCost():Object {
			var distance:int = (owner.parentEntity as Land).calculateTileDistance(this.toValidateEntity as Land);
			var extraCost:int = (this._morphidCost * (5*distance + 1) * 0.01);
			return {"morphid":extraCost, "xylan":0, "brontite":0, "lif":0, "act":0};
		}
		
		override protected function onSelected():void {
			dispatchEvent(new ActionEvent(ActionEvent.POPULATE_GATE_PANEL, this));
		}
		
		public function gateEntityDiselected():void {
			hlUtil.darkAndRemoveIcons();
		}
		
		//Executes when action is selected
		public function gateEntitySelected():void {
			storeValidatedEntities(getEntitiesForHLValFunction.call(null));
			hlUtil.setTileArray(validatedEntitiesForHL);
			hlUtil.lightAndAddIcons();
		}
		
		override protected function validateEntityForHighLight(entity:Entity):Entity {
			var land:Land;
			if (_gateEntity is Structure) {
				if (!(entity is Land)) return null;
				land = entity as Land;
				if (ArrayUtil.inArray(land.structure.data.type, EntityType.FLAGSTONE) && owner.faction.availableStructures > 0)
					return land;
			} else if (_gateEntity is Squad && owner.faction.availableBattlegroups > 0) {
				if (!(entity is Land)) return null;
				land = entity as Land;
				if (land.squad == null)
					return land;
			} else if (_gateEntity is Unit) {
				if (!(entity is Squad)) return null
				if (entity.parentEntity == null) return null;
				land = entity.parentEntity as Land;
				if (land.squad.availableUnitSlots > 0)
					return land;
			} else if (_gateEntity is Equipment) {
				if (!(entity is Squad)) return null;
				if (entity.parentEntity == null) return null;
				land = entity.parentEntity as Land;
				if (land.squad.availableEquipmentSlots > 0)
					return land;
			} else if (_gateEntity is Machinery) {
				if (!(entity is Structure)) return null;
				if (entity.parentEntity == null) return null;
				land = entity.parentEntity as Land;
				if (land.structure.availableMachinerySlots > 0)
					return land;
			}
			return null;
		}
		
		override protected function validateAction(args:Object):Boolean {
			var inputEntity:Entity = args[INPUT_ENTITY] as Entity;
			if (inputEntity == toValidateEntity) return true;
			if (!inputEntity is Land) return false;
			//if (inputEntity.faction != owner.faction) return false;
			
			var land:Land = inputEntity as Land;
			if (land.worldMapTile.constructed) {
				if (_gateEntity is Structure && land.faction == owner.faction) {
					if (ArrayUtil.inArray(land.structure.data.type, EntityType.FLAGSTONE) && owner.faction.availableStructures > 0)
						setToValidateEntity(land);
				} else if (_gateEntity is Squad && land.faction == owner.faction && owner.faction.availableBattlegroups > 0) {
					if (land.squad == null)
						setToValidateEntity(land);
				} else if (_gateEntity is Unit) {
					if (land.squad != null && land.squad.faction == Settings.player && land.squad.availableUnitSlots > 0)
						setToValidateEntity(land);
				} else if (_gateEntity is Equipment) {
					if (land.squad != null && land.squad.faction == Settings.player && land.squad.availableEquipmentSlots > 0)
						setToValidateEntity(land);
				} else if (_gateEntity is Machinery) {
					if (land.structure != null && land.structure.faction == Settings.player && land.structure.availableMachinerySlots > 0)
						setToValidateEntity(land);
				}
			}
			return false;
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			//var targetLand:Land = netObjects[TARGET_LAND_ID];
			//_gateEntity = netObjects[GATE_ENTITY_ID];
			if (teleportEntity(toValidateEntity as Land)) {
				//_lastNetArgs = toValidateEntity.networkID + "," + _gateEntity.networkID;
				_gateEntity = null;
				return true;
			}
			return false;
		}
		
		override public function engageFunctionalityExternal(args:Object = null):Boolean {
			_gateEntity = args[GATE_ENTITY] as Entity;
			toValidateEntity = args.toValidateEntity;
			return engageFunctionality(args);
		}
		
		override public function executeFromNet(args:Object):void {
			//var targetLand:Land = eManger.getEntityByID(args.lastNetArray[TARGET_LAND_ID]) as Land;
			//_gateEntity = eManger.getEntityByID(args.lastNetArray[GATE_ENTITY_ID]);
			//var targetLand:Land = eManger.getEntityByID(args.lastNetArray[TARGET_LAND_ID]) as Land;
			//_gateEntity = eManger.getEntityByID(args.lastNetArray[GATE_ENTITY_ID]);
			teleportEntity(toValidateEntity as Land);
		}
		
		/*override protected function onPostExecute():void {
			hlUtil.darkAndRemoveIcons();
			dispatchEvent(new ActionEvent(ActionEvent.RESET_GATE_PANEL, this));
			toValidateEntity = null;
			_gateEntity = null;
			validatedEntitiesForHL = [];
		}*/
		
		override ActionInternal function reset():void {
			super.reset();
			dispatchEvent(new ActionEvent(ActionEvent.RESET_GATE_PANEL, this));
		}
		
		/*override protected function onCanceled():void {
			hlUtil.darkAndRemoveIcons();
			if (toValidateEntity != null)
				(toValidateEntity as Land).mapTile.removeIcon();
			toValidateEntity = null;
			_gateEntity = null;
			validatedEntitiesForHL = [];
			dispatchEvent(new ActionEvent(ActionEvent.RESET_GATE_PANEL, this));
		}*/
		
		protected function teleportEntity(land:Land):Boolean {
			//if (_gateEntity == null) return false;
			owner.faction.removeFromInventory(gateEntity);
			if (_gateEntity is Structure) {
				land.assignToFaction(_owner.faction);
				land.structure = _gateEntity as Structure;
			} else if (_gateEntity is Squad) {
				land.squad = _gateEntity as Squad;
			} else if (_gateEntity is Unit) {
				land.squad.addUnit(_gateEntity as Unit);
			} else if (_gateEntity is Equipment) {
				land.squad.addEquipment(_gateEntity as Equipment);
			}
			_gateEntity.state = EntityState.IN_WORLD_MAP;
			land.mapTile.darkMe();
			land.mapTile.removeIcon();
			playSound();
			return true;
		}
		
		override public function setToValidateEntity(entity:Entity, color:ColorMatrixFilter = null):void {
			super.setToValidateEntity(entity, color);
			dispatchEvent(new ActionEvent(ActionEvent.UPDATE_DYNAMIC_COST, this));
		}
		
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			//1 entity to be gated
			_lastNetArgs = toValidateEntity.networkID + "," + _gateEntity.networkID;
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			toValidateEntity = eManger.getEntityByID(args.lastNetArray[TARGET_LAND_ID]);
			_gateEntity = eManger.getEntityByID(args.lastNetArray[GATE_ENTITY_ID]);
		}
		
		//GETTERS
		public function get allowedEntities():Array {return _allowedEntities;}
		public function get gateEntity():Entity {return _gateEntity;}
		
		//SETTERS
		public function set gateEntity(v:Entity):void{_gateEntity = v;}
	}
}