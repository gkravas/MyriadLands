package myriadLands.actions
{
	import myriadLands.entities.*;
	import flash.geom.Point;
	import myriadLands.ui.asComponents.MapTile;

	public class MovementAction extends Action {
		
		protected static const TARGET_LAND:int = 0;
				
		public function MovementAction(dataName:String, owner:Entity) {
			super(dataName, owner);
			iconName = "move-cur";
		}
		
	}
}