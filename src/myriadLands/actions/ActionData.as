package myriadLands.actions
{
	
	public class ActionData
	{
		public static const MORPHID_COST:String = "morphidCost";
		public static const LP_COST:String = "lpCost";
		public static const AP_COST:String = "apCost";
		public static const NO_COST:String = "noCost";
		public static const RANGE:String = "range";
		public static const RADIUS:String = "radius";
		public static const DAMAGE:String = "damage";
		public static const DURATION:String = "duration";
		public static const REQUIERES_INPUT:String = "requiersInput";
		public static const ARGUMENTS:String = "arguments";
		public static const STATIC_COST:String = "staticCost";
		public static const DYNAMIC_COST:String = "dynamicCost";
		public static const VALIDATION:String = "validation";
		public static const FUNCTIONALITY:String = "functionality";
		public static const NET_FUNCTIONALITY:String = "netFunctionality";
					
		public static const ATTRIBUTES:Array= [MORPHID_COST, LP_COST, AP_COST, NO_COST, RANGE, RADIUS, DAMAGE,
												DURATION, REQUIERES_INPUT, ARGUMENTS, STATIC_COST, DYNAMIC_COST,
												VALIDATION, FUNCTIONALITY, NET_FUNCTIONALITY];
			
		public var id:int;
		public var name:String;
		public var type:String;
		public var actionSuperClass:String;
		public var actionClass:String;
		public var view:String;
		public var availability:ActionAvailabilityType;
		
		public var attributes:Object;
		
		public function ActionData()
		{
			this.attributes = {};
		}

	}
}