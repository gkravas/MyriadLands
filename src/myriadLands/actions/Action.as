package myriadLands.actions
{	
	import flash.events.EventDispatcher;
	import flash.filters.ColorMatrixFilter;
	
	import gamestone.events.SoundsEvent;
	import gamestone.localization.LocalizationDictionary;
	import gamestone.sound.SoundManager;
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.NumberUtil;
	import gamestone.utils.StringUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.components.CentralComponent;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityManager;
	import myriadLands.entities.Machinery;
	import myriadLands.entities.Tile;
	import myriadLands.events.ActionEvent;
	import myriadLands.faction.Faction;
	import myriadLands.loaders.ActionLoader;
	import myriadLands.sound.Sounds;
	import myriadLands.ui.asComponents.HighlightUtil;
	
	import r1.deval.D;
	/**
	 * @author George Kravas
	 * Action is the second basic object in the game. Each Action must be referenced in xml.
	 * If an action is similar to an other, we refer it in xml with the specific parameters.
	 * For safe coding, it is better to put code inside classes.
	 */
	 
	 use namespace ActionInternal;
	 
	public class Action extends EventDispatcher
	{
		public static const MIN:int = 0;
		public static const MAX:int = 1;
		
		public static const INPUT_ENTITY:String = "inputEntity";
		
		public static const NET_TO_VALIDATE_ENTITY:int = 0;
		
		protected var _id:int;
		protected var _data:ActionData;
		protected var _owner:Entity;
		
		/**
		 *Save here data for networking 
		 */		
		protected var _lastNetArgs:String;
		protected var _messageNetID:String;
		protected var _morphidCost:int;
		protected var _lifCost:int;
		protected var _actCost:int;
		/**
		 *For no cost set true 
		 */		
		protected var _noCost:Boolean;
		
		protected var _range:Array;
		protected var _radius:int;
		protected var _damage:Array;
		protected var _duration:int;
		/**
		 *If action requiers some input for engaging, set to true; 
		 */		
		protected var _requiersInput:Boolean;
		protected var chargeStaticCost:Boolean;
		protected var _showFunction:String;
		protected var _externalArgs:Object;
		/**
		 *If your cost is not related to your inputEntity 
		 */		
		protected var _staticCost:String;
		/**
		 *If your cost is related to your inputEntity 
		 */	
		protected var _dynamicCost:String;
		/**
		 *Action's functionality 
		 */	
		protected var _functionality:String;
		/**
		 *Action's network functionality 
		 */	
		protected var _netFunctionality:String;
		/**
		 *Action's config before script execution
		 */	
		protected var _configForScriptExecution:String;
		/**
		 *Input entities validation code 
		 */	
		protected var _validation:String;
		
		protected var _d:LocalizationDictionary;
		protected var eManger:EntityManager;
		/**
		 *Assign here entity that has been validated 
		 */	
		protected var _toValidateEntity:Entity;
		/**
		 *Action will affect this attribute 
		 */	
		protected var _attributeToApply:String;
		/**
		 *Action can be angaged by action panel, else is auto engaged 
		 */	
		protected var _engagable:Boolean;
		/**
		 *Action can be quickTagged 
		 */	
		protected var _canBeQuickTagged:Boolean;
		
		/**
		 *Action's sound ID
		 */	
		protected var _soundID:String;
		
		protected var _cCompenent:CentralComponent;
		protected var _markForDestruction:Boolean;
		protected var _markForExecution:Boolean;
		
		protected var _remoteExecution:Boolean
		protected var _failedForMalus:Boolean
		protected var appliesMalus:Boolean
		
		//helping function for highlight
		protected var highLightsMap:Boolean;
		protected var styleName:String;
		protected var iconName:String;
		protected var validatedEntitiesForHL:Array;
		protected var hlUtil:HighlightUtil;
		protected var _highLightValidation:String;
		//This is the function which returns the entities for validation and coloring
		protected var getEntitiesForHLValFunction:Function;
		protected var _tileHighlightcolor:String;
		//

		public function Action(id:String, owner:Entity)
		{
			_owner = owner;
			_d =  LocalizationDictionary.getInstance();
			eManger = EntityManager.getInstance();
			_id = parseInt(id);
			_data = ActionLoader.getInstance().getActionData(id);
			setDataFromXML();
			_cCompenent = CentralComponent.createForAction(this);
			highLightsMap = true;
			validatedEntitiesForHL = [];
			appliesMalus = false;
		}
		
		public function destroy():void {
			_cCompenent.destroy();
			_cCompenent = null;
			_owner = null;
			_d =  null;
			eManger = null;
			_data = null;
			hlUtil = null;
			validatedEntitiesForHL = null;
			toValidateEntity = null;
		}
		
		public function markForDestroy():void {
			if (!_markForExecution)
				destroy();
			else
				_markForDestruction = true;
		}
		
		protected function setDataFromXML():void {
			if (_data == null)
				return;
				
			this._morphidCost = parseInt(this._data.attributes["morphidCost"]);
			this._lifCost = parseInt(this._data.attributes["lifCost"]);
			this._actCost = parseInt(this._data.attributes["actCost"]);
			this._noCost = StringUtil.parseBoolean(this._data.attributes["noCost"]);
			
			if (this._data.attributes.hasOwnProperty("range")) {
				this._range = String(this._data.attributes["range"]).split("-");
				if (this._range.length == 1)
					this._range = [0, this._range[0]];
				this._range = ArrayUtil.toIntegers(this._range);
			}
			
			this._radius = parseInt(this._data.attributes["radius"]);
			
			this._damage = String(this._data.attributes["damage"]).split(",");
			if (this._damage.length == 1)
					this.damage.push(this.damage[0]);
			this._damage = ArrayUtil.toIntegers(this._damage);
				
			this._duration = parseInt(this._data.attributes["duration"]);
			
			this._requiersInput = StringUtil.parseBoolean(this._data.attributes["requiersInput"]);
			this._engagable = StringUtil.parseBoolean(this._data.attributes["engagable"], true);
			this._canBeQuickTagged = StringUtil.parseBoolean(this._data.attributes["canBeQuickTagged"], true);
			
			this.chargeStaticCost = StringUtil.parseBoolean(this._data.attributes["chargeStaticCost"], true);
			this._showFunction = this._data.attributes["showFunction"];	
			
			this._externalArgs = StringUtil.splitToObject(_data.attributes["arguments"]);
			this._staticCost = removeCDATA(_data.attributes["staticCost"]);
			this._dynamicCost = removeCDATA(_data.attributes["dynamicCost"]);
			this._functionality = removeCDATA(_data.attributes["functionality"]);
			this._validation = removeCDATA(_data.attributes["validation"]);
			this._netFunctionality = removeCDATA(_data.attributes["netFunctionality"]);
			this._configForScriptExecution = removeCDATA(_data.attributes["configForScriptExecution"]);			
			
			this._attributeToApply = this._data.attributes["attributeToApply"];
			
			this._highLightValidation = removeCDATA(_data.attributes["highLightValidation"]);
			this._tileHighlightcolor = removeCDATA(_data.attributes["tileHighlightcolor"]);
			
			this._soundID = _data.attributes["sound"];
		}
		
		public function get data():ActionData
		{
			return _data;
		}
		
		public function get owner():Entity
		{
			return _owner;
		}
		
		public function validate(args:Object):Boolean {
			args["lastNetArgs"] = _lastNetArgs;
			args["toValidateEntity"] = toValidateEntity;
			args["owner"] = _owner;
			args["action"] = this;
			//if (_requiersInput && args.hasOwnProperty(INPUT_ENTITY))
			if (!validateAction(args))
				return false;
			//Here validates _static cost		
			if (validateCost(args)) {
				return true;
			}
				
			return false;
		}
		//SAME AS VALIDATE FUNCTION EXCEPT THAT DOESN'T CHARGE COST
		public function virtualValidate(args:Object):Boolean {
			args["lastNetArgs"] = _lastNetArgs;
			args["toValidateEntity"] = toValidateEntity;
			args["owner"] = _owner;
			args["action"] = this;
			//if (_requiersInput && args.hasOwnProperty(INPUT_ENTITY))
			if (!validateAction(args))
				return false;
			//Here validates _static cost		
			if (validateCost(args, false)) {
				return true;
			}
				
			return false;
		}
		
		public function execute(args:Object):Boolean {
			//True because it runned, but false because it didn't happen
			if (appliesMalus) {
				if (operationMalusChance()) {
					dispatchEvent(new ActionEvent(ActionEvent.EXECUTION_FAILED_FOR_MALUS, this));
					return true;
				}
			}
			var returnValue:Boolean = engageFunctionality(args);
			return returnValue;
		}
		
		protected function operationMalusChance():Boolean {
			var operMal:Number = this.owner.mal / 100;
			_failedForMalus = NumberUtil.randomDecision(operMal);
			return _failedForMalus;
		}
		
		protected function removeCDATA(code:String):String {
			if (code == null)
				return null;
			code = code.replace("<![CDATA[","");
			code = code.replace("]]>","");
			return code;
		}
		
		protected function chargeCost(cost:Object):void
		{
			var f:Faction = this._owner.faction;
			var e:Entity = this._owner;
			f.morphid -= cost.morphid;
			f.xylan -= cost.xylan;
			f.brontite -= cost.brontite;
			e.lif -= cost.lif;
			e.act -= cost.act;
			//e.addToAttribute("lif", -cost.lif);
			//e.addToAttribute("act", -cost.act);
		}
		
		//Code needed to be Implented for each action type.
		
		//Here goes all the functionality code. Not to be inside XML.
		protected function engageFunctionality(args:Object = null):Boolean {
			//inject toValidateEntity
			args["toValidateEntity"] = toValidateEntity;
			if (_functionality == null)
				return true;
			var context:Object = {returnValue:true};
			D.eval(_functionality, context, args);
			if (args.lastNetArgs != null)
				_lastNetArgs = args.lastNetArgs;
			return context.returnValue;
		}
		
		public function engageFunctionalityExternal(args:Object = null):Boolean {
			return engageFunctionality(args);
		}
		
		//Validates input entity
		protected function validateAction(args:Object):Boolean {
			if (_validation == null)
				return true;
			var context:Object = {returnValue:true};
			D.eval(_validation, context, args);
			if (args.toValidateEntity != null)
				toValidateEntity = args.toValidateEntity;
			return context.returnValue;
		}
		
		//Here goes all the charging cost code.
		protected function validateCost(args:Object, charge:Boolean = true):Boolean
		{
			if (_noCost) return true;
			var f:Faction = _owner.faction;
			var cost:Object;
			
			if (chargeStaticCost)
				cost = getStaticCost(args);
			else
				cost = calcultateDynamicCost();
				
			if  (f.morphid < cost.morphid)
				return false;			
			if  (f.xylan < cost.xylan)
				return false;
			if  (f.brontite < cost.brontite)
				return false;
			if  (owner.lif < cost.lif)
				return false;
			if  (owner.act < cost.act)
				return false;
			if (charge)	
				chargeCost(cost);
			return true;
		}
		
		//Array "type:value,...."
		protected function getStaticCost(args:Object):Object {
			var context:Object = {"morphid":_morphidCost, "xylan":0, "brontite":0, "lif":_lifCost, "act":_actCost};
			if (_staticCost != null)
				D.eval(_staticCost, context, args);
			return context;
		}
		
		public function getCostExternal(args:Object = null):Object {
			args["owner"] = _owner;
			args["action"] = this;
			return getStaticCost(args);
		}
		//For use only with input entity
		public function calcultateDynamicCost():Object {
			var context:Object =  {"morphid":0, "xylan":0, "brontite":0, "lif":0, "act":0};
			if (_staticCost != null)
				D.eval(_dynamicCost, context, {"owner":owner, "action":this});
			return context;
		}
		
		//EVENT FIRING
		ActionInternal function executionSuccess():void
		{
			//if (_remoteExecution)
			//	onRemotePostExecute();
			//else
				onPostExecute();
			dispatchEvent(new ActionEvent(ActionEvent.EXECUTION_SUCCESS, this, -1));
		}
				
		public function engage(args:Object = null):void
		{
			args = (args == null) ? {} : args;
			dispatchEvent(new ActionEvent(ActionEvent.ENGAGE, this, -1, args));
			onEngage();
		}
		
		public function selected(args:Object = null):void
		{
			dispatchEvent(new ActionEvent(ActionEvent.SELECTED, this, -1, args));
			onSelected();
		}
		
		public function canceled():void
		{
			dispatchEvent(new ActionEvent(ActionEvent.CANCELED, this));
			onCanceled();
		}
		
		//It's been called to store entities in an array, for further validation
		protected function storeValidatedEntities(entities:Array):void {
			var entity:Entity;
			var valEntity:Entity;
			for each (entity in entities) {
				valEntity = validateEntityForHighLight(entity);
				if (valEntity != null)
					validatedEntitiesForHL.push(valEntity);
			}
			validatedEntitiesForHL = ArrayUtil.stripDuplicates(validatedEntitiesForHL);
		}
		
		//It's been called for further validation
		//can be overrided or set it by script
		protected function validateEntityForHighLight(entity:Entity):Entity {
			if (_highLightValidation == null)
				return entity;
			var args:Object = {entity:entity, owner:owner, action:this};
			var context:Object = {returnValue:true};
			D.eval(_highLightValidation, context, args);
			return (context.returnValue) ? entity : null;
		}
		
		protected function onEngage():void {
		}
		protected function onSelected():void {
			if (!highLightsMap) return;
			if (!requiersInput) {//Highlight current parent
				var cm:ColorMatrixFilter = (validateEntityForHighLight(owner.parentEntity) != null) ? CombatHighlight.SELECTED : CombatHighlight.INVALID; 
				setToValidateEntity(owner.parentEntity, cm);
			} else {
				//find all entities
				if (_range == null) {
					storeValidatedEntities(getEntitiesForHLValFunction.call(null));
					hlUtil.setTileArray(validatedEntitiesForHL);
					hlUtil.lightAndAddIcons();
				} else { //Find entities in range
					if (owner.parentEntity == null) return;
					(owner.parentEntity as Tile).mapTile.dispatchLightArea(range[MAX], range[MIN],
																				validateAndColorEntity);
				}
			}
		}
		protected function onPostExecute():void {
			reset();
		}
		
		protected function onCanceled():void {
			reset();
		}
		
		//protected function onRemotePostExecute():void {}
		
		//RESETS ENTITY FOR NEXT USE
		ActionInternal function reset():void {
			resetHighLightAndRemoveIcons();
			_failedForMalus = false;
			toValidateEntity = null;
			validatedEntitiesForHL = [];
		}
		
		
		//Execute actions from script
		public function executeActionsFromScript(actions:Array, arrayArgs:Array = null):void {
			var am:ActionManager = ActionManager.getInstance();
			arrayArgs = (arrayArgs == null) ? ArrayUtil.createArray(actions.length) : arrayArgs;
			
			var i:int;
			for (i = 0; i < actions.length; i++)
				am.executeActionFromScript(owner, actions[i], arrayArgs[i]); 
		}
		
		//INPUT ENTITY SELECTION
		public function setToValidateEntity(entity:Entity, color:ColorMatrixFilter = null):void {
			if (entity == null) return
			color = (color == null) ? CombatHighlight.SELECTED : color;
			if(entity is Tile) {
				resetToValidateEntity(toValidateEntity);
				toValidateEntity = entity;
				(toValidateEntity as Tile).mapTile.lightMe(color);
				if (color == CombatHighlight.SELECTED)
					(toValidateEntity as Tile).mapTile.addIcon(iconName);
			} else if (entity is Machinery) {
				resetToValidateEntity(toValidateEntity);
				toValidateEntity = entity;
				(toValidateEntity.parentEntity.parentEntity as Tile).mapTile.lightMe(color);
				if (color == CombatHighlight.SELECTED)
					(toValidateEntity.parentEntity.parentEntity as Tile).mapTile.addIcon(iconName);
			}
		}
		
		protected function resetToValidateEntity(entity:Entity):void {
			if (entity == null) return
			if(entity is Tile) {
				(entity as Tile).mapTile.toggleLightToPreviousColor();
				(entity as Tile).mapTile.removeIcon();
			} else if (entity is Machinery) {
				(entity.parentEntity.parentEntity as Tile).mapTile.toggleLightToPreviousColor();
				(entity.parentEntity.parentEntity as Tile).mapTile.removeIcon();
			}
		}
		
		//HIGHLIGHTING CALLBACK
		//It is called when action has range
		protected function validateAndColorEntity(entity:Entity):ColorMatrixFilter {
			if (_tileHighlightcolor == null)
				return null;
			var context:Object = {returnValue:null};
			var args:Object = {entity:entity, owner:owner, action:this};
			D.eval(_tileHighlightcolor, context, args);
			return context.returnValue;
		}
		protected function resetHighLightAndRemoveIcons():void {
			if (!highLightsMap) return;
			if (!requiersInput) {
				if (toValidateEntity != null) {
					(toValidateEntity as Tile).mapTile.darkMe();
					(toValidateEntity as Tile).mapTile.removeIcon();
				}
			} else {
				//find all entities
				if (_range == null)
					hlUtil.darkAndRemoveIcons();
				else { //Find entities in range
					if (owner.parentEntity == null) return;
					(owner.parentEntity as Tile).mapTile.dispatchResetArea();
					if (toValidateEntity != null)
						(toValidateEntity as Tile).mapTile.removeIcon();
				}
			}
		}
		
		public function playSound(loops:int = 1, callback:Function = null):void {
			if (_soundID == null) return;
			if (callback != null)
				SoundManager.getInstance().getSound(_soundID).addEventListener(SoundsEvent.PLAYBACK_COMPLETE, callback, false, 0, true);
			Sounds.play(_soundID, loops);
		}
		
		//SETTERS
		ActionInternal function set markForExecution(v:Boolean):void {_markForExecution = v;}
		ActionInternal function set remoteExecution(v:Boolean):void {_remoteExecution= v;}
		ActionInternal function setMessageNetID(v:String):void {_messageNetID = v;}
		public function set toValidateEntity(v:Entity):void {
			_toValidateEntity = v;
		}
		
		//GETTERS
		public function get id():int {return _id};
		public function get damage():Array {return _damage};
		public function get range():Array {return _range};
		public function get radius():int {return _radius};
		public function get duration():int {return _duration};
		
		public function get lifCost():int {return _lifCost};
		public function get actCost():int {return _actCost};
		public function get morphidCost():int {return _morphidCost};
				
		public function get requiersInput():Boolean {return _requiersInput;}
		public function get failedForMalus():Boolean {return _failedForMalus;}
		
		public function get canBeQuickTagged():Boolean {return _canBeQuickTagged;}
		public function get engagable():Boolean {return _engagable;}
		public function get messageNetID():String {return _messageNetID;}
		public function get toValidateEntity():Entity {return _toValidateEntity;}
		
		
		ActionInternal function isMarkedForDestruction():Boolean {return _markForDestruction;}
		ActionInternal function isMarkedForExecution():Boolean {return _markForExecution;}
		
		//Network Coding
		public function encodeNetworkArgs(args:Object):void {
			
		}
		public function decodeNetworkArgs(args:Object):void {
		}
		
		public function executeFromNet(args:Object):void {
			//inject toValidateEntity
			args["toValidateEntity"] = toValidateEntity;
			if (_netFunctionality == null)
				return;
			D.eval(_netFunctionality, null, args);
		}
		public function configForScriptExecution(args:Object):void {
			if (_configForScriptExecution == null)
				return;
			D.eval(_configForScriptExecution, null, args);
			if (args.toValidateEntity != null)
				toValidateEntity = args.toValidateEntity;
		}
		public function getLastEngagementNetworkArguments():String {
			return _lastNetArgs;
		}
	}
}