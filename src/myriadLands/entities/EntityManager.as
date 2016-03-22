package myriadLands.entities
{
	
	import flash.errors.IllegalOperationError;
	
	import gamestone.utils.DebugX;
	
	import myriadLands.core.Settings;
	import myriadLands.errors.EntityReferenceError;
	import myriadLands.net.NetInternal;
	
	use namespace EntityInternal;
	use namespace NetInternal;
	
	public class EntityManager {
					
		private static var _this:EntityManager;
	
		protected var entities:Object;
		protected var lands:Array;
		
		protected var generatedEntitiesCnt:int;
		protected var _lastNetID:String;
		
		public function EntityManager(pvt:PrivateClass)
		{
			if (pvt == null)
			{
				throw new IllegalOperationError("EntityManager cannot be instantiated externally. EntityManager.getInstance() method must be used instead.");
				return null;
			}
			entities = {};
			lands = [];
			generatedEntitiesCnt = 0;
		}
		
		public static function getInstance():EntityManager {
			if (EntityManager._this == null)
				EntityManager._this = new EntityManager(new PrivateClass());
			return EntityManager._this;
		}
		
		public static function clear():void	{
			var entity:Entity;
			for each (entity in _this.entities) {
				entity.destroy();
				entity = null;
			}
			_this.entities = {};
			_this.lands = [];
		}
			
		EntityInternal function addEntity(entity:Entity, netID:String):void {
			var id:String = (netID == null) ? generateID() : netID;
			entity.setNetworkID(id);
			entities[id] = entity;
			_lastNetID = id;
			//Lands will be destroyed at the very end
			if (entity is Land)
				lands.push(entity);
		}
		
		public function addOthersEntity(entity:Entity, id:String):void {
			if (entities.hasOwnProperty(id)) {
				DebugX.MyTrace("entity with " + id + " is " + entities[id].toString());
				throw new EntityReferenceError("EntityManager: Entity from other player with ID: " + id + " already exists");
			}
			var lastID:String = entity.networkID;
			entity.setNetworkID(id);
			entities[id] = entity;
			delete entities[lastID];
		}
		
		public function removeEntity(id:String):Entity {
			//needs fixing
			if (!entities.hasOwnProperty(id))
				DebugX.MyTrace("EntityManager: Entity with ID: " + id + "does not exist");
				//throw new EntityReferenceError("EntityManager: Entity with ID: " + id + "does not exist");
			var entity:Entity = entities[id];
			delete entities[id];
			return entity;
		}
		
		public function destroyEntity(id:String):void {
			removeEntity(id);
			entities[id] = null;
		}
		
		public function getEntityByID(id:String):Entity {
			if (!entities.hasOwnProperty(id)) 
				throw new EntityReferenceError("EntityManager: Entity with ID: " + id + " does not exist");
			var entity:Entity = entities[id];
			return entity;
		}
		
		public function getLands():Array {
			return lands;
		}
		
		protected function generateID():String {
			generatedEntitiesCnt++;
			return Settings.username + "_" + generatedEntitiesCnt;
		}
		
		public function getLastGeneratedID1():String {
			return _lastNetID;
		}
	}
}
class PrivateClass {}