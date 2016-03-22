package myriadLands.actions {
	
	import gamestone.utils.StringUtil;
	
	import myriadLands.combat.CombatHighlight;
	import myriadLands.combat.CombatVars;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.entities.Tile;
	import myriadLands.entities.Unit;
	import myriadLands.ui.asComponents.HighlightUtil;
	import myriadLands.ui.css.MLFilters;
	
	import r1.deval.D;

	/**
	 * This action adds to attributes of a group or groups of entities, In the field. 
	 * @author George Kravas
	 * 
	 */	
	public class DynamicCombatAuraAction extends Action {
		
		//protected var _validateEntities:Array;
		protected var _applyToAttributes:Array;
		
		protected var _auraColor:uint;
		protected var _squads:Array;
		
		public function DynamicCombatAuraAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			styleName = "AuraInfo";
			iconName = "aura-cur";
			_auraColor = MLFilters.PURPLE;
			hlUtil = new HighlightUtil(CombatHighlight.SELECTED, iconName);
			getEntitiesForHLValFunction = populateEntitiesForVal;
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			_applyToAttributes = StringUtil.splitToArray2D(_data.attributes["applyToAttributes"]);
		}
				
		override protected function engageFunctionality(args:Object = null):Boolean {
			if (_functionality == null)
				return applyAura();
				
			var context:Object = {returnValue:true};
			D.eval(_functionality, context, args);
			if (args.lastNetArgs != null)
				_lastNetArgs = args.lastNetArgs;
			return context.returnValue;
		}
		
		override public function executeFromNet(args:Object):void {
			populateEntitiesForVal();
			storeValidatedEntities(getEntitiesForHLValFunction.call(null));
			engageFunctionality(args);
		}
		
		protected function applyAura():Boolean {
			var cg:CombatGround;
			for each (cg in validatedEntitiesForHL)
				applyToEntity(cg);
			return true;
		}
		
		protected function populateEntitiesForVal():Array {
			var entities:Array = [];
			if (CombatVars.enemySquad.parentEntity)
				entities.push(CombatVars.enemySquad.parentEntity);
			if (CombatVars.mySquad.parentEntity)
				entities.push(CombatVars.mySquad.parentEntity);
			for each(var unit:Unit in  CombatVars.enemySquad.getUnits().concat(CombatVars.mySquad.getUnits())) {
				if (unit.parentEntity != null)
					entities.push(unit.parentEntity);
			}
			return entities;
		}
		
		override protected function onSelected():void {
			if (!highLightsMap) return;
			populateEntitiesForVal();
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
		
		override protected function resetHighLightAndRemoveIcons():void {
			if (!highLightsMap) return;
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
		
		protected function applyToEntity(tile:Tile):void {
			var entityOn:Entity = (tile as CombatGround).entityOn;
			var arr:Array;
			var arrText:Array = [];
			for each (arr in _applyToAttributes) {
				var endChar:String = (arr[2] == "%") ? arr[2] : "";
				var prosimo:String = (parseInt(arr[1]) >= 0) ? "+" : "-"; 
				if (arr[2] == "%")
					entityOn.multiplyAttribute(arr[0], parseInt(arr[1]) * validatedEntitiesForHL.length, true);
				else
					entityOn.addToAttribute(arr[0], parseInt(arr[1]) * validatedEntitiesForHL.length, true);
				arrText.push(prosimo + " " + Math.abs(arr[1]) + endChar + "" + _d.getLeema(arr[0]));
			}
			addEffects(tile, arrText);
			tile.mapTile.showAura(_auraColor);
		}
		
		protected function addEffects(tile:Tile, text:Array):void {
			tile.mapTile.addAnimatedTextArray(text, styleName);
		}
		
	}
}