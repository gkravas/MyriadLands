package myriadLands.events
{
	import flash.events.Event;
	
	import myriadLands.actions.Action;
	
	public class ActionEvent extends Event
	{
		//For action manager only
		//public static const EXECUTED:String = "executed";
		public static const ENGAGE:String = "engage";
		public static const SELECTED:String = "selected";
		public static const CANCELED:String = "canceled";
		public static const QUICK_TAG_CHANGED:String = "quickTagChanged";
		public static const POPULATE_PRODUCTION_PANEL:String = "populateProductionPanel";
		public static const RESET_PRODUCTION_PANEL:String = "resetProductionPanel";
		public static const POPULATE_GATE_PANEL:String = "populateGatePanel";
		public static const RESET_GATE_PANEL:String = "resetGatePanel";
		public static const UPDATE_DYNAMIC_COST:String = "updateDynamicCost";
		
		public static const EXECUTION_SUCCESS:String = "executionSuccess";
		public static const EXECUTION_FAILED_FOR_MALUS:String = "executionFailedForMalus";
		
		protected var _action:Action;
		protected var _quickTag:int;
		protected var _args:Object;
		
		public function ActionEvent(type:String, action:Action = null, quickTag:int = -1, args:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_action = action;
			_quickTag = quickTag;
			_args = args;
		}
		
		public function get action():Action	{
			return _action;
		}
		
		public function get quickTag():int {
			return _quickTag;
		}
		
		public function get args():Object {
			return _args;
		}
		
		public override function clone():Event {
			return new ActionEvent(type, _action, _quickTag, args, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("ActionEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}