package myriadLands.actions
{
	import gamestone.events.SoundsEvent;
	
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityManager;
	import myriadLands.events.ActionEvent;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.net.MLProtocol;
	import myriadLands.actions.ActionInternal;
	
	use namespace ActionInternal;
	

	public class ProductionAction extends Action
	{
		//protected static const FACTION_ID:int = 0;
		//protected static const ENTITY_NAME:int = 1;
		//protected static const ENTITY_ID:int = 2;
		protected static const ENTITY_NAME_ID:int = 0;
		public static const PRODUCT_NAME:String = "productName";
		
		//Vars coming from network		
		protected var entityToProduceName:String;
		
		protected var _producedTypes:Array;
		protected var eLoader:EntityLoader;
		protected var producedEntity:Entity;
		
		public function ProductionAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			appliesMalus = true;
			highLightsMap = false;
			eLoader = EntityLoader.getInstance();
			var cm:CentralManager = CentralManager.getInstance();
			addEventListener(ActionEvent.POPULATE_PRODUCTION_PANEL, cm.populateProductionPanel, false, 0, true);
			addEventListener(ActionEvent.RESET_PRODUCTION_PANEL, cm.resetPorductionPanel, false, 0, true);
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			var producedTypes:Array = String(_data.attributes["producedTypes"]).split(",");
			this._producedTypes = EntityLoader.getInstance().getEntityNamesByType(producedTypes);
			_soundID = "production";
		}
		
		override protected function getStaticCost(args:Object):Object {
			if (args.entityName == undefined)
				return {"morphid":_morphidCost, "xylan":0, "brontite":0, "lif":0, "act":0};
			var e:Entity = eLoader.getEntity(args.entityName, null, true);
			return {"morphid":_morphidCost, "xylan":e.xylanPC, "brontite":0, "lif":0, "act":0};
		}
		
		override protected function onSelected():void {
			dispatchEvent(new ActionEvent(ActionEvent.POPULATE_PRODUCTION_PANEL, this));
		}
		
		override protected function engageFunctionality(args:Object = null):Boolean {
			//var id:String = netObjects[ENTITY_NAME_ID];
			//if (!validateCost({entityName:id})) return false;
			validateCost({entityName:entityToProduceName}); 
			playSound(1, engageHelpFunction);
			producedEntity = createEntity(entityToProduceName, entityToProduceName + "_" + messageNetID);
			//owner.faction.addEntity(producedEntity);
			owner.faction.addEntity(producedEntity);
			//_lastNetArgs = producedEntity.faction.name + "," + id + "," +producedEntity.networkID;
			return true;
		}
		
		protected function createEntity(name:String, netID:String):Entity {
			return eLoader.getEntity(name, netID);
		}
		
		protected function engageHelpFunction(event:SoundsEvent):void {
			event.sound.removeEventListener(SoundsEvent.PLAYBACK_COMPLETE, engageHelpFunction);
			owner.faction.addToInventory(producedEntity);
			producedEntity = null;
		}
		
		override public function validate(args:Object):Boolean {
			return args.hasOwnProperty(ProductionAction.PRODUCT_NAME);
		}
		
		override public function executeFromNet(args:Object):void {
			//var id:String = netObjects[ENTITY_NAME_ID];
			validateCost({entityName:entityToProduceName});
			var e:Entity = createEntity(entityToProduceName, entityToProduceName + "_" + messageNetID);
			owner.faction.addEntity(e);
			owner.faction.addToInventory(e);
		}
		
		override public function engageFunctionalityExternal(args:Object=null):Boolean {
			return engageFunctionality(args);
		}
		
		override protected function onPostExecute():void {
			dispatchEvent(new ActionEvent(ActionEvent.RESET_PRODUCTION_PANEL, this));
		}
		
		override protected function onCanceled():void {
			dispatchEvent(new ActionEvent(ActionEvent.RESET_PRODUCTION_PANEL, this));
		}
		
		public function produceEntity(id:String):void {
			var args:Object = {};
			args[ProductionAction.PRODUCT_NAME] = id;
			engage(args);
		}
		
		//NETWORKING encode, decode
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			_lastNetArgs = args[ProductionAction.PRODUCT_NAME];
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			entityToProduceName = args.lastNetArray[ENTITY_NAME_ID];
		}
		
		//GETTERS
		public function get producedTypes():Array {
			return _producedTypes;
		}
	}
}