package myriadLands.entities
{
	use namespace EntityInternal;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import gamestone.graphics.ImgLoader;
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.StringUtil;
	
	import mx.core.BitmapAsset;
	
	import myriadLands.actions.AbilityAction;
	import myriadLands.actions.ActionView;
	import myriadLands.components.CentralComponent;
	import myriadLands.core.ResourcePack;
	import myriadLands.events.CentralManagerEvent;
	import myriadLands.events.EntityEvent;
	import myriadLands.events.EntityModifierEvent;
	import myriadLands.faction.Faction;
	import myriadLands.loaders.ActionLoader;
	
	public class Entity extends EventDispatcher {
		
		public static const PREFIX:String = "entity";
		
		public static const TYPE_PART:int = 0;
		public static const ENTITTY_NAME_PART:int =1;
		public static const ID_PART:int = 2;
		
		//public static const STRUCTURE_TYPE:String = "structure";
		//public static const SQUAD_TYPE:String = "squad";
		
		protected var _name:String;
		protected var _networkID:String;
		protected var _isRare:Boolean;
		protected var _state:String;
		
		protected var _prc:ResourcePack;
		protected var _upk:Number;
		protected var _sel:int;
		protected var _rep:Number;
		protected var _rez:Number;
		protected var _gat:Number;
		
		protected var _cap:int;
		protected var _mal:int;
		
		protected var _lif:int;
		protected var _lifrg:int;
		protected var _act:int;
		protected var _actrg:int;
		protected var _atk:int;
		protected var _def:int;
		protected var _crc:int;
		
		protected var _equ:int;
		protected var _unt:int;
		protected var _mch:int;

		protected var _spn:ResourcePack;
		protected var _crf:Number;
		protected var _grd:Array;
		protected var _extraDmg:int;
		
		protected var _abilitiesInitialized:Boolean;
		
		protected var _availableActions:Array;
		protected var _availableAbilities:Array;
		protected var _abilities:Array;
				
		protected var _data:EntityData;
		protected var _renderableAttributes:Array;
		
		protected var _faction:Faction;
		protected var _parentEntity:Entity;
		protected var _lastParentEntity:Entity;
		protected var _upgradedAttributes:Object;
		protected var _upgradedActionAttributes:Object;
		protected var _actionAttributes:Object;
		
		protected var _cComponent:CentralComponent;
		protected var _entityModifiers:Array;
		
		protected var isDestroyed:Boolean;
		
		protected var imgLoader:ImgLoader;
		
		public function Entity(dataName:String, data:EntityData)
		{
			imgLoader = ImgLoader.getInstance();
			_upgradedAttributes = {};
			_upgradedActionAttributes = {};
			_abilitiesInitialized = false;
			_entityModifiers = [];
			_renderableAttributes = [];
			_name = dataName;
			_data = data;
			setDataFromXML();
			this._isRare = false;
			_cComponent = CentralComponent.createForEntity(this, onCycle);
		}
		
		public function destroy():void {
			if (isDestroyed) return;
			imgLoader = null;
			_upgradedAttributes = null;
			_upgradedActionAttributes = null;
			_entityModifiers = null;
			_renderableAttributes = null;
			_name = null;
			_data = null;
			_state = null;
			_parentEntity = null;
			EntityManager.getInstance().removeEntity(this.networkID);
			_cComponent.destroy();
			_cComponent = null;
			isDestroyed = true;
		}
		
		EntityInternal function renew(dataName:String, data:EntityData):void {
			_name = dataName;
			_data = data;
			setDataFromXML();
		}
		
		protected function setDataFromXML():void
		{
			if (_data == null)
				throw new IllegalOperationError("Entity function data with name " + _name + ", does not exist. ");
				
			this._prc = ResourcePack.resourcePackFromString(this.data.attributes["prc"]);
			this._upk = parseInt(this.data.attributes["upk"])/100;
			this._sel = parseInt(this.data.attributes["sel"]);
			this._rep = parseInt(this.data.attributes["rep"])/100;
			this._rez = parseInt(this.data.attributes["rez"])/100;
			this._gat = parseInt(this.data.attributes["gat"])/100;
			
			this._cap = parseInt(this.data.attributes["cap"]);
			
			this._lif = parseInt(this.data.attributes["lif"]);
			this._lifrg = parseInt(this.data.attributes["lifrg"]);
			this._act = parseInt(this.data.attributes["act"]);
			this._actrg = parseInt(this.data.attributes["actrg"]);
			this._atk = parseInt(this.data.attributes["atk"]);
			this._def = parseInt(this.data.attributes["def"]);
			this._crc = parseInt(this.data.attributes["crc"]);
			
			if (this.data.attributes.hasOwnProperty("grd"))
				this._grd = StringUtil.splitToInt(this.data.attributes["grd"],"-");
			
			this._mal = parseInt(this.data.attributes["mal"]);			
			
			this._equ = parseInt(this.data.attributes["equ"]);
			this._unt = parseInt(this.data.attributes["unt"]);
			this._mch = parseInt(this.data.attributes["mch"]);
		
			this._spn = ResourcePack.resourcePackFromString(data.attributes["spn"]);
			this._crf = parseInt(data.attributes["crf"])/100;
			
			this._availableActions = this.data.availableActions;
			this._abilities = ActionLoader.getInstance().getAvailableAbilities(this);
		}
		
		protected function engageAbilities():void {
			var ability:AbilityAction;
			for each(ability in _abilities) {
				ability.engageAbility();
			}
		}
		
		public function getStringData():Array
		{
			var arr:Array = [];
			var value:String;
			for each(var field:String in _renderableAttributes)
			{
				value = this[field];
				arr.push(field + ": " + value);
			}
			return arr;
		}
						
		public function removeAction(action:int):void {
			_availableActions = ArrayUtil.remove(_availableActions, action);
			fireUpdate(false, true, false);
		}
		
		public function addAction(action:int):void {
			_availableActions.push(action);
			fireUpdate(false, true, false);
		}		
		
		EntityInternal function setActions(actions:Array):void {
			_availableActions = actions;
			fireUpdate(false, true, false);
		}
		
		public function getBitmapAssetIco():BitmapAsset	{
			return imgLoader.getBitmapAsset(data.name + "-ico");
		}
		
		public function getBitmapAssetBu():BitmapAsset {
			return imgLoader.getBitmapAsset(data.name + "-bu");
		}
		
		//Event firing
		public function fireSelectedEvent(view:String):void
		{
			dispatchEvent(new EntityEvent(EntityEvent.SELECTED, this, view));
		}
		
		public function fireUpdate(attributes:Boolean, functions:Boolean, content:Boolean):void
		{
			dispatchEvent(new EntityEvent(EntityEvent.UPDATE, this, null, attributes, functions, content));
		}
		
		//ATTRIBUTE MALIPULATION
		public function getAttributeUpgradeTimes(att:String):int {
			return _upgradedAttributes["_" + att];
		}
		
		public function addAttributeUpgradeTimes(att:String):void {
			if (_upgradedAttributes["_" + att] == undefined)
				_upgradedAttributes["_" + att] = 0;
			_upgradedAttributes["_" + att] += 1;
		}
		
		public function addToAttribute(att:String, value:int, exitLimit:Boolean = false):void {
			setAttibute(att, this[att] + value, exitLimit);
		}
		
		public function multiplyAttribute(att:String, factor:int, exitLimit:Boolean = false):void {
			setAttibute(att, this[att] * (1 + (factor / 100)), exitLimit);
		}
		
		public function setAttibute(attributeName:String, value:int, exitLimit:Boolean = false):void {
			if (!exitLimit) {
				var oldValue:int = this[attributeName];
				var max:int = parseInt(data.attributes[attributeName.replace("_", "")]);
				value = (value > max) ? max : value;
				value = (value < 0) ? 0 : value; 
				//Check out of limits
				if (oldValue >= max && value >= max) return;
				if (oldValue <= 0 && value <= 0) return;
				//If it is equal
				if (oldValue == value) return;
			}
			try {
				if (hasOwnProperty(attributeName))
					this[attributeName] = value;
				else
					this["_" + attributeName] = value;
			} catch(err:ReferenceError) {
				this["_" + attributeName] = value;
			}
			fireUpdate(true, false, false);
		}
		
		/**
		 * Modifies an entity's attributes for N cycles 
		 * @param attributesMod
		 * @param cycles
		 * 
		 */
		public function modifyEntityFor(attributesMod:String, cycles:int, styleName:String):void {
			var em:EntityModifier = new EntityModifier(this);
			_entityModifiers.push(em);			
			em.modifyEntity(attributesMod, cycles, styleName);
			em.addEventListener(EntityModifierEvent.ENDED, modificationEnded, false, 0, true);
		}
		
		/**
		 *Runs thru entity modifiers and informs about cycle pass
		 */		
		protected function modificationCyclePass():void {
			var em:EntityModifier;
			for each(em in _entityModifiers)
				em.onCyclePass();
		}
		
		//EVENTS
		protected function onCycle(e:CentralManagerEvent):void {
			modificationCyclePass();
			if (_upk == 0 || faction == null) return;
			faction.xylan -= upk;
		}
		
		protected function modificationEnded(e:EntityModifierEvent):void {
			var em:EntityModifier = e.entityModifier;
			_entityModifiers =  ArrayUtil.remove(_entityModifiers, em);
			em.removeEventListener(EntityModifierEvent.ENDED, modificationEnded);
			em.destroy();
			em = null;
		}
		
		//SETTER
		public function set atk(v:int):void {_atk = v;}
		public function set faction(value:Faction):void {
			if (_faction == value) return;
			_faction = value; 
			if (!_abilitiesInitialized) {
				engageAbilities();
				_abilitiesInitialized = true;
			}
		}		
		public function set parentEntity(value:Entity):void {
			_lastParentEntity = _parentEntity;
			_parentEntity = value;
		}
		public function set mal(value:int):void {_mal = value;}

		public function set lif(value:int):void {
			//if ((_lif == value) || (value >  data.attributes["lif"]) || (_lif == data.attributes["lif"] && )) return;
			_lif = value;
			_lif = (_lif < 0) ? 0 : _lif;
			if (state == EntityState.IN_COMBAT) {
				dispatchEvent(new EntityEvent(EntityEvent.LIF_CHANGED, this, ActionView.COMBAT));
				if (_lif == 0) {
					engageAbilities();
					dispatchEvent(new EntityEvent(EntityEvent.ENTITY_DIED, this, ActionView.COMBAT));
				}
			}
		}
		
		public function set act(value:int):void {_act = value;}
		public function set sel(value:int):void {_sel = value;}
		
		public function set state(value:String):void {
			var oldState:String = _state;
			_state = value;
			stateChanged(oldState, value);
			//_state = value;
			if (_state == EntityState.IN_VAULT)
				_abilitiesInitialized = false;
			dispatchEvent(new EntityEvent(EntityEvent.STATE_CHANGED, this));
		}
		
		protected function stateChanged(currentState:String, newState:String):Boolean {
			if (currentState != newState) {
				if (newState == EntityState.IN_WORLD_MAP)
					engageAbilities();
				return true;
			}
			return false;
		}
		
		EntityInternal function setNetworkID(id:String):void {
			this._networkID = id;
		}
		
		//GETTERS
		EntityInternal function get abilitiesInitialized():Boolean {return _abilitiesInitialized;}
		public function get name():String {return _name;}
		public function get availableActions():Array {return _availableActions;}
		public function get availableAbilities():Array {return _abilities;}
		public function get faction():Faction {return _faction;}
		public function get data():EntityData {return _data;}
		public function get parentEntity():Entity {return _parentEntity;}
		public function get lastParentEntity():Entity {return _lastParentEntity;}
		public function get mal():int {return _mal;}
		public function get rep():Number {return _rep;}
		public function get rez():Number {return _rez;}
		public function get sel():int {return _sel;}
		public function get gat():Number {return _gat;}
		public function get isRare():Boolean {return _isRare;}
		public function get upk():int {return _prc.multiplyBy(_upk).xylan;}
		public function get cap():int {return _cap;}
		public function get xylanPC():int {return _prc.xylan;}
		public function get morphidPC():int {return _prc.morphid;}
		public function get brontitePC():int {return _prc.brontite;}
		public function get lif():int {return _lif;}
		public function get lifrg():int {return _lifrg;}
		public function get act():int {return _act;}
		public function get actrg():int {return _actrg;}
		public function get atk():int {return _atk;}
		public function get def():int {return _def;}
		public function get crc():int {return _crc;}
		public function get equ():int {return _equ;}
		public function get unt():int {return _unt;}
		public function get mch():int {return _mch;}
		public function get crf():Number {return _crf;}
		public function get grd():Array {return _grd;}
		public function get extraDmg():int {return _extraDmg;}
		public function get xylanSpawned():int {return _spn.xylan;}
		public function get morphidSpawned():int {return _spn.morphid;}
		public function get brontiteSpawned():int {return _spn.brontite;}
		public function get state():String {return _state;}
		public function get networkID():String {return _networkID;}
	}
}