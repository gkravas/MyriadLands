package myriadLands.actions
{
	import myriadLands.net.NetworkManager;
	import myriadLands.actions.ActionInternal;
	
	use namespace ActionInternal;
	
	public class ActionExecutionObject {
		
		protected var _action:Action;
		protected var _args:Object;
		protected var _isExecuted:Boolean;
		protected var _isValidated:Boolean;
		protected var _isRemoteAction:Boolean;
		protected var _isActionExecutedFromScript:Boolean;
		
		public function ActionExecutionObject(action:Action, args:Object, isRemoteAction:Boolean = false, isActionExecutedFromScript:Boolean = false)	{
			_action = action;
			_args = args;
			_isRemoteAction = isRemoteAction;
			_isActionExecutedFromScript = isActionExecutedFromScript;
		}
		
		public function destroy():void {
			_action.destroy();
			_action = null;
			_args = null;
			//_externalExecution = false;
			_isExecuted = true;
		}
		
		public function execute():void {
			_isExecuted = true;
			if (_isActionExecutedFromScript)
				action.configForScriptExecution(args);
			else
				action.decodeNetworkArgs(args);
			if (isRemoteAction) {
				action.remoteExecution = true;
				action.executeFromNet(args);
				action.executionSuccess();
			} else {
				if (action.execute(args))
					action.executionSuccess();
			}
		}
		
		public function validate():Boolean {
			_isValidated = true;
			if (_action.validate(args)) {
				action.encodeNetworkArgs(args);
				return true;
			}
			return false;
		}
		
		//GETTERS
		public function get action():Action {return _action;}
		public function get args():Object {return _args;}
		public function get isExecuted():Boolean {return _isExecuted;}
		public function get isValidated():Boolean {return _isValidated;}
		public function get isRemoteAction():Boolean {return _isRemoteAction;}	
	}
}