package myriadLands.actions {
	import gamestone.utils.ArrayUtil;
	
	import myriadLands.entities.Entity;
	import myriadLands.entities.Land;
	import myriadLands.entities.Structure;
	import myriadLands.entities.Tile;
	
	public class StaticWorldMapAuraAction extends StaticCombatAuraAction {
						
		public function StaticWorldMapAuraAction(dataName:String, owner:Entity) {
			super(dataName, owner);
		}
						
				
		override protected function applyAura():Boolean {
			var land:Land;
			for each (land in validatedEntitiesForHL)
				applyToEntity(land);
			return true;
		}
				
		override protected function applyToEntity(tile:Tile):void {
			var structure:Structure = (tile as Land).structure;
			var arr:Array;
			var arrText:Array = [];
			for each (arr in _applyToAttributes) {
				var endChar:String = (arr[2] == "%") ? arr[2] : "";
				var prosimo:String = (parseInt(arr[1]) >= 0) ? "+" : "-"; 
				if (arr[2] == "%")
					structure.multiplyAttribute(arr[0], arr[1], true);
				else
					structure.addToAttribute(arr[0], arr[1], true);
				arrText.push(prosimo + " " + Math.abs(arr[1]) + endChar + "" + _d.getLeema(arr[0]));
			}
			addEffects(tile, arrText);
			tile.mapTile.showAura(_auraColor);
		}
		
		override protected function populateEntitiesForVal():Array {
			return owner.faction.getEntities();
		}
		
		override protected function validateEntityForHighLight(entity:Entity):Entity {
			if (ArrayUtil.inArrayFromArray(entity.data.type, _applyToType))
				return entity.parentEntity;
			else
				return null;
		}
	}
}