package myriadLands.actions {
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import myriadLands.core.Settings;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.EntityManager;
	import myriadLands.events.ActionEvent;
	import myriadLands.events.EntityEvent;
	import myriadLands.events.NetworkEvent;
	import myriadLands.loaders.ActionLoader;
	import myriadLands.net.MLProtocol;
	import myriadLands.net.NetworkManager;
	
	use namespace ActionInternal;
	
	/*For synchronization reasons, all local actions are validated and then being send over net.
	Every internal, first all actions which were aquired over net, are executed and then local
	validation is being runned.
	*/
	public class ActionManager extends EventDispatcher {
		
		protected static const  PLAYER:String = "player";
		protected static const  ENITY_NET_ID:String = "entityNetID";
		protected static const  ACTION_ID:String = "actionID";
		protected static const  ARGS:String = "args";
		
		protected static var _this:ActionManager;
		
		protected var _actionExecutionTread:Timer;
		protected var _actionsForExecution:Array;
		protected var _actionsForValidation:Array;
		protected var al:ActionLoader;
		protected var em:EntityManager;
		protected var netM:NetworkManager;
		protected var _currentAction:Action;
		
		public function ActionManager(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("ActionManager cannot be instantiated externally. ActionManager.getInstance() method must be used instead.");
				return null;
			}
			netM = NetworkManager.getInstance();
			al = ActionLoader.getInstance();
			em = EntityManager.getInstance();
			_actionsForExecution = [];
			_actionsForValidation = [];
			_actionExecutionTread = new Timer(Settings.ACTION_EXECUTION_INTERVAL);
			//First executes and then validates actions, so all players are synced
			_actionExecutionTread.addEventListener(TimerEvent.TIMER, executeAndValidate, false, 0, true);
			_actionExecutionTread.start();
		}
		
		public static function getInstance():ActionManager {
			if (ActionManager._this == null)
				ActionManager._this = new ActionManager(new PrivateClass());
			return ActionManager._this;
		}
		
		EntityInternal function entitySelected(e:EntityEvent):void {
			if (e.view == ActionView.SELECTION_PANEL) {
				if (currentAction == null) return;
				currentAction.canceled();
				currentAction = null;
			} else if (e.view == ActionView.WORLD_MAP) {
				//engage function with sacrifice required
				if (currentAction != null && currentAction.requiersInput)
					executeAction({"inputEntity":e.entity});
			} else if (e.view == ActionView.COMBAT) {
				//engage function with sacrifice required
				if (currentAction != null && currentAction.requiersInput)
					executeAction({"inputEntity":e.entity});
			}
		}
		//Standard actions, validated from local player only
		protected function executeAction(args:Object = null):void {
			_actionsForValidation.push(new ActionExecutionObject(currentAction, args))
			//currentAction = null;
		}
		//Ability actions. Are executed on each client, localy. That's why if apply to attribute
		//value must be constant
		protected function executeAbilityAction(action:Action, args:Object = null):void {
			//if (!isLocalPlayerAction(action.owner)) return;
			if (action.virtualValidate(args))
				_actionsForExecution.push(new ActionExecutionObject(action, args));
		}
		//Pool actions, validated from local player only
		public function executePoolAction(action:Action, args:Object = null):void {
			if (action.virtualValidate(args))
				_actionsForValidation.push(new ActionExecutionObject(action, args));
		}
		
		/*public function executeActionExternal(owner:Entity, actionID:String, args:Object = null):void {
			var action:Action = al.getActionOfEntity(actionID, owner);
			_actionsForExecution.push(new ActionExecutionObject(action, args, true));
		}*/
		
		//Actions executed by other actions. Used only localy, for traffic and sync reasons.
		public function executeActionFromScript(owner:Entity, actionID:String, args:Object = null):void {
			//if (isLocalPlayerAction(owner)) return;
			args = (args == null) ? {} : args;
			var action:Action = al.getActionOfEntity(actionID, owner);
			if (action.virtualValidate(args))
				_actionsForExecution.push(new ActionExecutionObject(action, args, false, true));
		}
		
		protected function isLocalPlayerAction(owner:Entity):Boolean {
			return (owner.faction == netM.getFactionPlayer());
		}
		public function executeNetworkAction(e:NetworkEvent):void {
			var isLocalPlayer:Boolean = (e.networkAction[PLAYER] == netM.getFactionPlayer().name);
			var owner:Entity = em.getEntityByID(e.networkAction[ENITY_NET_ID]);
			var action:Action = al.getActionOfEntity(e.networkAction[ACTION_ID], owner);
			//If it does call another action, then the called function will be called on multiple clients
			if (isLocalPlayer) currentAction = null;
			var arguments:Object = {};
			arguments["lastNetArray"] = e.networkAction[ARGS];
			arguments["owner"] = owner;
			arguments["action"] = action;
			action.setMessageNetID(e.networkAction[MLProtocol.BATTLEFIELD_MSG_ID]);
			_actionsForExecution.push(new ActionExecutionObject(action, arguments, !isLocalPlayer));
		}
		
		public function actionSelectedAndRequiersInput():Boolean {
			return currentAction != null && currentAction.requiersInput;
		}
		
		ActionInternal function actionEngage(e:ActionEvent):void {
			if (e.action is AbilityAction)
				executeAbilityAction(e.action, e.args);
			else if (!currentAction.requiersInput)
				executeAction(e.args);
		}
		
		ActionInternal function actionSelected(e:ActionEvent):void {
			if (currentAction != null)
				currentAction.canceled();
			currentAction = e.action;
		}
		
		//EVENTS
		private function executeAndValidate(e:TimerEvent):void {
			executeWaitingActions();
			validateLocalActions();
		}
		
		private function executeWaitingActions():void {
			var action:ActionExecutionObject;
			var toExecute:Array = [];
			var i:int
			for (i = 0; i < _actionsForExecution.length; i++) {
				action = _actionsForExecution[i];
				if (action == null) continue;
				if (action.isExecuted) {
					delete _actionsForExecution[i];
					continue;
				}
				toExecute.push(action);
			}
			for (i = 0; i < toExecute.length; i++) {
				action = toExecute[i];
				action.execute();
				action.action.markForExecution = false;
				if (action.action.isMarkedForDestruction())
					action.action.destroy();
				action = null;
				delete toExecute[i];
			}
		}
		
		private function validateLocalActions():void {
			var action:ActionExecutionObject;
			var toValidate:Array = [];
			var i:int
			for (i = 0; i < _actionsForValidation.length; i++) {
				action = _actionsForValidation[i];
				if (action == null) continue;
				if (action.isValidated) {
					delete _actionsForValidation[i];
					continue;
				}
				toValidate.push(action);
			}
			for (i = 0; i < toValidate.length; i++) {
				action = toValidate[i];
				if (action.validate()) {
					netM.sendMessage(MLProtocol.ACTION_PERFORMED, action.action);
					action.action.reset();
				}
				delete toValidate[i];
			}
		}
		
		protected function get currentAction():Action {return _currentAction;}
		protected function set currentAction(v:Action):void {
			if (v == null)
				_currentAction = null;
			else
				_currentAction = v;
		}
	}
}
class PrivateClass {}