package myriadLands.combat
{
	import flash.filters.ColorMatrixFilter;
	
	import myriadLands.ui.css.MLFilters;
	
	public class CombatHighlight
	{
		public static const AVAILABLE:ColorMatrixFilter = MLFilters.BLUE_FILL;
		public static const VALID:ColorMatrixFilter = MLFilters.GREEN_FILL;
		public static const INVALID:ColorMatrixFilter = MLFilters.RED_FILL;
		public static const SELECTED:ColorMatrixFilter = MLFilters.YELLOW_FILL;
		
		public function CombatHighlight()	{}

	}
}