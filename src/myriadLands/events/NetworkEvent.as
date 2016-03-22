package myriadLands.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
		
	public class NetworkEvent extends Event
	{
		public static const LOGIN_SUCCESS:String = "loginSuccess";
		public static const LOGIN_FAILURE:String = "loginFailure";
		public static const LOGOUT:String = "logout";
		public static const DISCONECTED:String = "disconected";
		
		public static const CHANNEL_MESSAGE_RECEIVED:String = "channelMessageReceived";
		public static const SESSION_MESSAGE_RECEIVED:String = "sessionMessageReceived";
		public static const RAW_MESSAGE_RECEIVED:String = "rawMessageReceived";
		public static const CHAT_MESSAGE_RECEIVED:String = "chatMessageReceived";
		
		public static const INIT_MAP:String = "initMap";
		public static const NETWORK_ACTION_RECEIVED:String = "networkActionReceived";
		public static const START_BATTLEFIELD_GAME:String = "startBattlefieldGame";
		public static const START_BATTLE:String = "startBattle";
		public static const BATTLEFIELD_CYCLE:String = "battlefieldCycle";
		
		public static const POPULATE_LOCATION_BATTLEFIELDS_PANEL:String = "populateLocationBattlefieldsPanel";
		public static const UPDATE_BATTLE_WAITING_PANEL:String = "updateBattleWaitingPanel";
		
		
		protected var _message:ByteArray;
		protected var _networkAction:Object;
		
		public function NetworkEvent(type:String, message:ByteArray, networkAction:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_message = message;
			_networkAction = networkAction;
		}
		
		public function get message():ByteArray {
			return _message;
		}
		
		public function get networkAction():Object {
			return _networkAction;
		}
		
		public override function clone():Event {
			return new NetworkEvent(type, message, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("NetworkEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}