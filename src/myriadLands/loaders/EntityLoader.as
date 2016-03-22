package myriadLands.loaders
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.XMLLoader;
	
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityData;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.EntityManager;
	
	use namespace EntityInternal;
	
	public class EntityLoader extends XMLLoader
	{
		private static var _this:EntityLoader;
		
		[Bindable]
		public var entities:Object;
		
		private var entitiesNames:Array;
		
		public function EntityLoader(pvt:PrivateClass)
		{
			if (pvt == null)
			{
				throw new IllegalOperationError("EntityLoader cannot be instantiated externally. EntityLoader.getInstance() method must be used instead.");
				return null;
			}
			entities = {};
			entitiesNames = [];
		}
		
		public static function getInstance():EntityLoader
		{
			if (EntityLoader._this == null)
				EntityLoader._this = new EntityLoader(new PrivateClass());
			return EntityLoader._this;
		}
		
		protected override function xmlLoaded(e:Event):void
		{
			var xml:XML = XML(xmlLoader.data);
			xmlLoader = null;
			
			var entity:XML;
			var attribute:XML;
			
			for each(entity in xml.entity)
			{
				var eData:EntityData = new EntityData();
				eData.name = entity.attribute("name");
				eData.className = entity.attribute("class");
				eData.type = String(entity.attribute("type")).split(",");
				
				for each(attribute in entity.attribute)
				{
					eData.attributes[attribute.attribute("name")] = String(attribute);
				}
				if (eData.attributes["availableActions"] != null)
				{
					eData.availableActions = ArrayUtil.splitToIntegers(eData.attributes["availableActions"], ",");
					delete eData.attributes["availableActions"];
				}
				if (eData.attributes["abilities"] != null)
				{
					eData.abilities = ArrayUtil.splitToIntegers(eData.attributes["abilities"], ",");
					delete eData.attributes["abilities"];
				}
				entities[eData.name] = eData;
				entitiesNames.push(eData.name);
			}
			super.xmlLoaded(e);
		}
		
		public function getEntityData(entityName:String):EntityData	{
			return entities[entityName];
		}
		
		public function getEntity(entityName:String, netID:String, temporary:Boolean = false):* {
			var ed:EntityData = getEntityData(entityName);
			if (ed == null) return null;
			var cl:Class = getDefinitionByName("myriadLands.entities." + ed.className) as Class;
			var ent:* = new cl(entityName, ed);
			if (!temporary)
				EntityManager.getInstance().addEntity(ent, netID);
			return ent;
		}
		
		public function getEntityNamesByType(types:Array):Array {
			var arr:Array = [];
			for each(var type:String in types) {
				for each(var ent:EntityData in entities) {
					if (ArrayUtil.inArray(ent.type, type))
						arr.push(ent.name);
				}
			}
			return arr;
		}
		
		//Keeps the same id, changes tin object
		//Only for same types
		public function renewEntity(entity:Entity, entityName:String):void
		{
			var ed:EntityData = getEntityData(entityName);
			entity.renew(entityName, ed);
		}
	}
}
class PrivateClass {}