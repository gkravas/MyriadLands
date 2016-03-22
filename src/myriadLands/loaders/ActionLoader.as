package myriadLands.loaders
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getDefinitionByName;
	
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.XMLLoader;
	
	import myriadLands.actions.Action;
	import myriadLands.actions.ActionData;
	import myriadLands.entities.Entity;
	
	public class ActionLoader extends XMLLoader
	{
		private static var _this:ActionLoader;
		
		private var actions:Object;
		//private var finalActions:Object;
		//private var actionsID:Array;
		
		public function ActionLoader(pvt:PrivateClass)
		{
			if (pvt == null)
			{
				throw new IllegalOperationError("ActionLoader cannot be instantiated externally. ActionLoader.getInstance() method must be used instead.");
				return null;
			}
			actions = {};
			//finalActions = {};
			//actionsID = [];
		}
		
		public static function getInstance():ActionLoader
		{
			if (ActionLoader._this == null)
				ActionLoader._this = new ActionLoader(new PrivateClass());
			return ActionLoader._this;
		}
		
		protected override function xmlLoaded(e:Event):void
		{
			var xml:XML = XML(xmlLoader.data);
			xmlLoader = null;
			
			var action:XML;
			var attribute:XML;
			
			for each(action in xml.action)
			{
				var fData:ActionData = new ActionData();
				fData.id = parseInt(action.attribute("id"));
				fData.name = action.attribute("name");
				fData.type = action.attribute("type");
				fData.actionClass = action.attribute("class");
				fData.actionSuperClass = action.attribute("superClass");
				if (fData.actionClass == "")
					fData.actionClass = fData.type;
				fData.view = action.attribute("view");
				
				for each(attribute in action.attribute)
				{
					fData.attributes[attribute.@name] = String(attribute);
				}
				
				actions[fData.id] = fData;
				//actionsID.push(fData.id);
			}
			//saveActionsForDictionary();
			super.xmlLoaded(e);
		}
		
		public function saveActionsForDictionary():void {
			
			var stream:FileStream = new FileStream;
			var file:File =  File.desktopDirectory.resolvePath("actionDictionary.xml");
			file.nativePath;
			stream.open(file, FileMode.WRITE);
			for each(var action:ActionData in actions) {
				stream.writeUTF("<leema id=\"" + action.name + "Name\"></leema>\n");
				stream.writeUTF("<leema id=\"" + action.name + "Info\"></leema>\n");
			}
			stream.close();
		}
		
		public function getActionData(id:String):ActionData
		{
			var action:ActionData =  (actionDataExists(id)) ? ActionData(actions[id]) : null; 
			return action;
		}
		
		public function actionDataExists(id:String):Boolean
		{
			return actions.hasOwnProperty(id);
		}
		
		public function getAvailableActions(owner:Entity, view:String = null):Array
		{
			return getActionsOfEntity(owner.availableActions, owner, view);
		}
		
		public function getAvailableAbilities(owner:Entity, view:String = null):Array
		{
			return getActionsOfEntity(owner.data.abilities, owner, view);
		}
		
		public function getActionsOfEntity(arrfunctions:Array, owner:Entity, view:String = null):Array
		{
			var arr:Array = arrfunctions;
			var farr:Array = [];
			while (arr.length > 0)
			{
				farr.push(getActionOfEntity(arr[0], owner, view));
				arr = arr.slice(1);
			}
			return ArrayUtil.stripEmpty(farr);
		}
		
		public function getActionOfEntity(action:String, owner:Entity, view:String = null):Action
		{
			var f:ActionData = getActionData(action);
			if (f != null && (view == null || f.view == view)) { 
				var cl:Class = getDefinitionByName("myriadLands.actions." + f.actionClass) as Class;
				var ef:Object = new cl(action, owner);
				return ef as Action;
			}
			return null;
		}
		
		protected function initializeActionData(actionData:ActionData, actionDataID:String):void {
			var data:ActionData = getActionData(actionDataID);
			if (data.actionSuperClass != null)
				initializeActionData(actionData, data.actionSuperClass);
				
			var atName:String;
			for (var i:int = 0; i < ActionData.ATTRIBUTES.length; i++) {
				atName = ActionData.ATTRIBUTES[i];
				if (data.attributes.hasOwnProperty(atName)) continue;
				actionData.attributes[atName] = data.attributes[atName];
			}
		}
	}
}
class PrivateClass {}