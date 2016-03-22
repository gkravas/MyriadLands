package myriadLands.actions {
	
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityManager;
	import myriadLands.entities.Land;
	import myriadLands.entities.Tile;
	
	public class DeployFlagstone extends GateAction {
		
		public function DeployFlagstone(dataName:String, owner:Entity) {
			super(dataName, owner);
			getEntitiesForHLValFunction = function a():Array {return EntityManager.getInstance().getLands();};
		}
				
		override protected function validateEntityForHighLight(entity:Entity):Entity {
			var land:Land = entity as Land;
			if (land.worldMapTile.constructed)
				if (land.structure == null)
					return land;
			
			return null;
		}
		
		override protected function validateAction(args:Object):Boolean {
			var inputEntity:Entity = args[INPUT_ENTITY] as Entity;
			if (inputEntity == toValidateEntity) return true;
			if (inputEntity.faction == null) {
				if (inputEntity is Land) {
					var land:Land = inputEntity as Land;
					if (land.worldMapTile.constructed) {
						if (land.structure == null) {
							setToValidateEntity(land);
							return false;
						}
					}
				}
			}
			return false;
		}
	}
}