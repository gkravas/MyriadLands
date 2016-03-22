package myriadLands.components
{	
	import flash.errors.IllegalOperationError;
	
	import myriadLands.actions.Action;
	import myriadLands.actions.ActionInternal;
	import myriadLands.actions.ActionManager;
	import myriadLands.actions.CentralManager;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.events.ActionEvent;
	import myriadLands.events.CentralManagerEvent;
	import myriadLands.events.EntityEvent;
	
	use namespace ActionInternal;
	use namespace EntityInternal;	
	
	public class CentralComponent {
		
		public static const ENTITY_TYPE:String = "entity";
		public static const ACTION_TYPE:String = "action";
		
		protected var cm:CentralManager;
		protected var am:ActionManager;
		protected var _action:Action;
		protected var _entity:Entity;
		protected var _type:String;
		
		protected var _onCycleFunction:Function;
		
		public function CentralComponent(pvt:PrivateClass) {
			if (pvt == null)
			{
				throw new IllegalOperationError("CentralComponent cannot be instantiated externally. Use static methods instead.");
				return null;
			}
			cm = CentralManager.getInstance();
			am = ActionManager.getInstance();
		}
		
		public function destroy():void {
			if (_type == CentralComponent.ENTITY_TYPE)
				destroyForEntity();
			else
				destroyForAction();
			cm = null;
			_type = null;
		}
		
		//DECONSTRUCTORS
		protected function destroyForEntity():void {
			//everything works with weak reafernces
			//if (_entity == null) return;
			//Events
			_entity.removeEventListener(EntityEvent.SELECTED, am.entitySelected);
			_entity.removeEventListener(EntityEvent.SELECTED, cm.entitySelected);
			_entity.removeEventListener(EntityEvent.UPDATE, cm.entityUpdated);
			cm.removeEventListener(CentralManagerEvent.CYCLE_PASSED, _onCycleFunction);
			//Rest
			_entity = null;
		}
		protected function destroyForAction():void {
			//everything works with weak reafernces
			//if (_action == null) return;
			//Events
			_action.removeEventListener(ActionEvent.ENGAGE, am.actionEngage);
			_action.removeEventListener(ActionEvent.ENGAGE, cm.actionEngage);
			_action.removeEventListener(ActionEvent.EXECUTION_SUCCESS, cm.actionExecutionSuccess);
			_action.removeEventListener(ActionEvent.SELECTED, am.actionSelected);
			_action.removeEventListener(ActionEvent.SELECTED, cm.actionSelected);
			_action.removeEventListener(ActionEvent.CANCELED, cm.actionCanceled);
			_action.removeEventListener(ActionEvent.UPDATE_DYNAMIC_COST, cm.updateDynamicCost);
			_action.removeEventListener(ActionEvent.EXECUTION_FAILED_FOR_MALUS, cm.actionFailedForMalus);
			//Rest
			_action = null;
		}
		
		//STATIC
		public static function createForEntity(entity:Entity, onCycleFunction:Function):CentralComponent {
			var cc:CentralComponent = new CentralComponent(new PrivateClass);
			cc._type = CentralComponent.ENTITY_TYPE;
			cc._entity = entity;
			cc._onCycleFunction = onCycleFunction;
			//Events
			cc._entity.addEventListener(EntityEvent.SELECTED, cc.am.entitySelected, false, 1, true);
			cc._entity.addEventListener(EntityEvent.SELECTED, cc.cm.entitySelected, false, 0, true);
			cc._entity.addEventListener(EntityEvent.UPDATE, cc.cm.entityUpdated, false, 0, true);
			cc.cm.addEventListener(CentralManagerEvent.CYCLE_PASSED, cc._onCycleFunction, false, 0, true);
			return cc;
		}
		
		public static function createForAction(action:Action):CentralComponent {
			var cc:CentralComponent = new CentralComponent(new PrivateClass);
			cc._type = CentralComponent.ACTION_TYPE;
			cc._action = action;
			//Events
			cc._action.addEventListener(ActionEvent.ENGAGE, cc.am.actionEngage, false, 0, true);
			cc._action.addEventListener(ActionEvent.ENGAGE, cc.cm.actionEngage, false, 1, true);
			cc._action.addEventListener(ActionEvent.EXECUTION_SUCCESS, cc.cm.actionExecutionSuccess, false, 0, true);
			cc._action.addEventListener(ActionEvent.SELECTED, cc.am.actionSelected, false, 0, true);
			cc._action.addEventListener(ActionEvent.SELECTED, cc.cm.actionSelected, false, 1, true);
			cc._action.addEventListener(ActionEvent.CANCELED, cc.cm.actionCanceled, false, 0, true);
			cc._action.addEventListener(ActionEvent.UPDATE_DYNAMIC_COST, cc.cm.updateDynamicCost, false, 0, true);
			cc._action.addEventListener(ActionEvent.EXECUTION_FAILED_FOR_MALUS, cc.cm.actionFailedForMalus, false, 0, true);
			return cc;
		}
	}
}
class PrivateClass {}