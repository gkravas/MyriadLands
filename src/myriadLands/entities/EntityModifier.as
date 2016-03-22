package myriadLands.entities
{
	import flash.events.EventDispatcher;
	
	import gamestone.localization.LocalizationDictionary;
	
	import myriadLands.events.EntityModifierEvent;
	
	use namespace EntityInternal;
	/**
	 * Modifies entities attributes for some time
	 * @author George Kravas
	 */
	public class EntityModifier extends EventDispatcher
	{
		protected static const NAME:int = 0;
		protected static const VALUE:int = 1;
		protected static const TYPE:int = 2;
		
		protected var _entity:Entity;
		protected var _attributesModName:Array;
		protected var _attributesModValue:Array;
		protected var _attributesModType:Array;
		protected var _remainingCycles:int;
		protected var _d:LocalizationDictionary;
		
		public function EntityModifier(entity:Entity) {
			_d = LocalizationDictionary.getInstance();
			_entity = entity;
			_attributesModName = [];
			_attributesModValue = [];
			_attributesModType = [];
		}
		
		public function destroy():void {
			_d = null;
			_entity = null;
			_attributesModName = null;
			_attributesModValue = null;
			_attributesModType = null;
		}
		
		/**
		 * Starts modification of the entity. 
		 * @param attributesMod Attributes Modification.
		 * @param cycles Number of cycles for the modification.
		 * 
		 */		
		public function modifyEntity(attributesMod:String, cycles:int, styleName:String):void {
			parseAttributesMod(attributesMod);
			var arrText:Array = [];
			var val:int;
			var attName:String;
			var endChar:String;
			var prosimo:String;
			for (var i:int = 0; i < _attributesModName.length; i++) {
				attName = _attributesModName[i];
				val = _attributesModValue[i];
				endChar = (_attributesModType[i] == "%") ? _attributesModType[i] : "";
				prosimo = (val >= 0) ? "+" : "-"; 
				if (_attributesModType[i] == "%")
					_entity.multiplyAttribute(attName, val, true);
				else
					_entity.addToAttribute(attName, val, true);
				arrText.push(prosimo + " " + Math.abs(val) + endChar + "" + _d.getLeema(attName));
			}
			_remainingCycles = cycles;
			dispatchEvent(new EntityModifierEvent(EntityModifierEvent.STARTED, this));
			if (_entity.parentEntity is Tile)
				addEffects(_entity.parentEntity as Tile, arrText, styleName);
		}
		
		/**
		 * Parses the attributesMod and populates _attributesModName and _attributesModValue arrays.
		 * @param attributesMod
		 * 
		 */		
		protected function parseAttributesMod(attributesMod:String):void {
			var arrStr:Array = attributesMod.split(",");
			var str:String;
			var eAttMod:Array;
			var i:int = 0;
			for each(str in arrStr) {
				eAttMod = str.split(":");
				_attributesModName[i] = eAttMod[EntityModifier.NAME];
				_attributesModValue[i] = parseInt(eAttMod[EntityModifier.VALUE]);
				_attributesModType[i] = eAttMod[EntityModifier.TYPE];
				i++;
			}
		}
		/**
		 * Decrease the cycle counter, when comes to 0 returns entity to its previous state
		 * and fires EntityModifierEvent.ENDED event.
		 */		
		public function onCyclePass():void {
			_remainingCycles--;
			if (_remainingCycles == 0)
				returnEntityToPreviousState();
			dispatchEvent(new EntityModifierEvent(EntityModifierEvent.ENDED, this));
		}
		
		/**
		 * Return entity to its previous state.
		 */		
		protected function returnEntityToPreviousState():void {
			var attName:String;
			for (var i:int = 0; i < _attributesModName.length; i++) {
				attName = _attributesModName[i];
				_entity.setAttibute(attName, _entity[attName] / (1 + _attributesModValue[i]));
			}
		}
		
		protected function addEffects(tile:Tile, text:Array, styleName:String):void {
			tile.mapTile.addAnimatedTextArray(text, styleName);
		}
		
		//GETTERS
		public function get remainingCycles():int {
			return _remainingCycles;
		}
	}
}