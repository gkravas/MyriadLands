package myriadLands.net
{
	import com.pdsClient.client.ClientChannel;
	import com.pdsClient.client.PDSClientEvent;
	import com.pdsClient.client.SimpleClient;
	import com.pdsClient.util.PDSByteArray;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.StringUtil;
	
	import mx.collections.ArrayCollection;
	
	import myriadLands.core.Settings;
	import myriadLands.events.NetworkEvent;
	import myriadLands.faction.Faction;
	import myriadLands.faction.FactionAllianceManager;
	import myriadLands.loaders.LocationLoader;
	
	public class NetworkManager extends EventDispatcher{
		
		private static var _this:NetworkManager;
		public static const BATTLEFIELD_CHANNEL_PREFIX:String = "_BattlefieldChannel";
		public static const OPEN_GAME_CHANNEL_NAME:String = "openGameChannel";
		public static const COMBAT_CHANNEL_PREFIX:String = "_CombatChannel";
		
		protected var client:SimpleClient;
		protected var mHandler:MessageHandler;
		protected var factions:Array;
		protected var fam:FactionAllianceManager;
		
		protected var _username:String;
		protected var _password:String;
		
		//CHANNELS
		protected var localGameplayChannel:ClientChannel;
		protected var openGameChannel:ClientChannel;
		protected var battleChannel:ClientChannel;
		
		protected var battleFields:Object;
		
		public function NetworkManager(pvt:PrivateClass) {
			if (pvt == null)
			{
				throw new IllegalOperationError("NetworkManager cannot be instantiated externally. NetworkManager.getInstance() method must be used instead.");
				return null;
			}
			Security.loadPolicyFile("assets/xml/domain.xml");
			
			battleFields = {};
			
			fam = FactionAllianceManager.getInstance();
			fam.networkManager = this;
			
			factions = [];
			mHandler = new MessageHandler();
			client = new SimpleClient(Settings.HOST, Settings.PORT);
			
			client.addEventListener(PDSClientEvent.LOGIN_SUCCESS, onLoginSuccess);
            client.addEventListener(PDSClientEvent.LOGIN_FAILURE, onLoginFailure);
            client.addEventListener(PDSClientEvent.CHANNEL_JOIN, onChannelJoin);
            client.addEventListener(PDSClientEvent.CHANNEL_LEAVE, onChannelLeave);
            
            client.addEventListener(PDSClientEvent.SESSION_MESSAGE, onSessionMessage);
            client.addEventListener(PDSClientEvent.CHANNEL_MESSAGE, onChannelMessage);
            client.addEventListener(PDSClientEvent.RAW_MESSAGE, onRawMessage);
            
            createBattleFieldCollections(LocationLoader.getInstance().getLocationNames());
		}
		
		public static function getInstance():NetworkManager
		{
			if (NetworkManager._this == null)
				NetworkManager._this = new NetworkManager(new PrivateClass());
			return NetworkManager._this;
		}
		
		public static function clear():void {
			var f:Faction;
			for each(f in _this.factions)
				f.destroy();
			_this.factions = [];
			FactionAllianceManager.clear();
		}
		
		public function createBattleFieldCollections(locations:Array):void {
			var location:String;
			for each (location in locations)
				battleFields[location] = new ArrayCollection();
		}
		
		public function login(username:String, password:String):void {
			_username = username;
			_password = password;
			client.login(username, password);
		}
		//NOT USED
		public function logout(force:Boolean):void {
			client.logout(force);
		}
		
		public function setLoginListener(loginListener:Function):void {
			mHandler.setLoginListener(loginListener);
		}
		
		public function sendSessionMessage(message:PDSByteArray):void {
			//if (!Settings.loggedIn) return;
			client.sessionSend(message);
		}
		
		public function sendLocalGameMessage(message:PDSByteArray):void {
			if (localGameplayChannel == null) return;
			//message.compress(CompressionAlgorithm.DEFLATE);
			client.channelSend(localGameplayChannel, message);
		}
		
		public function sendOpenGameMessage(message:PDSByteArray):void {
			if (openGameChannel == null) return;
			//message.compress(CompressionAlgorithm.DEFLATE);
			client.channelSend(openGameChannel, message);
		}
		
		public function sendBattleMessage(message:PDSByteArray):void {
			if (battleChannel == null) return;
			//message.compress(CompressionAlgorithm.DEFLATE);
			client.channelSend(battleChannel, message);
		}
		
		public function sendMessage(type:int, args:Object = null):void {
			mHandler.sendMessage(type, this, args);
		}
		
		public function localPlayerIsInBattle():Boolean {
			return (battleChannel != null);
		}
		
		public function addFaction(faction:Faction):void {
			factions.push(faction);
			fam.addFaction(faction);
		}
		
		public function removeFaction(faction:Faction):void {
			ArrayUtil.remove(factions, faction);
		}
		
		public function removeFactionByName(name:String):void {
			ArrayUtil.remove(factions, getFactionByName(name));
		}
		
		public function getFactionByName(name:String):Faction {
			var f:Faction;
			for each(f in factions)
				if (f.name == name)
					return f;
			return null;
		}
		
		public function getFactionPlayer():Faction {
			return getFactionByName(Settings.username);
		}
		
		public function getFactionsNum():int {
			return factions.length;
		}
		
		public function getFactions():Array {
			return factions;
		}
		
		public function addBattleField(data:String):void {
			var arr:Array = data.split(":");
			//var bf:BattlefieldData = new BattlefieldData(arr[0], arr[1], arr[2], arr[3], arr[4]);
			var o:Object = {locationName:arr[0], name:arr[1], maxPlayers:parseInt(arr[2]), playersIn:parseInt(arr[3]),
							open:StringUtil.parseBoolean(arr[4]), readyPlayers:0};
			battleFields[o.locationName].addItem(o);
		}
		
		public function removeBattleField(location:String, battlefieldName:String):void {
			var arr:ArrayCollection = (battleFields[location] as ArrayCollection);
			var bf:Object;
			var i:int = 0;
			for each (bf in arr) {
				if (bf.name == battlefieldName) {
					arr.removeItemAt(arr.getItemIndex(bf));
					break;
				}
			}
			dispatchPopulateLocationBattlefieldsPanel();
		}
		
		public function updateBattleField(location:String, name:String, playersIn:int, readyPlayers:int):void {
			var arr:ArrayCollection = (battleFields[location] as ArrayCollection);
			var bf:Object;
			var i:int = 0;
			for each (bf in arr) {
				if (bf.name == name) {
					bf.playersIn = playersIn;
					bf.readyPlayers = readyPlayers;
					break;
				}
			}
			dispatchPopulateLocationBattlefieldsPanel();
		}
		
		public function getBattlefields(location:String):ArrayCollection {
			return battleFields[location];
		}
		
		public function getBattlefield(location:String, battlefieldName:String):Object {
			var arr:ArrayCollection = (battleFields[location] as ArrayCollection);
			var bf:Object;
			var i:int = 0;
			for (i = 0; i < arr.length; i++) {
				bf = arr.getItemAt(i);
				if (bf.name == battlefieldName)
					return bf;
			}
			return null
		}
				
		public function dispatchInitMap(locationMap:String):void {
			var b:ByteArray = new ByteArray();
			b.writeUTF(locationMap);
			dispatchEvent(new NetworkEvent(NetworkEvent.INIT_MAP, b));
		}
		
		public function dispatchNetworkActionReceived(player:String, entityNetID:String, action:String, args:String, bfMsgID:String):void {
			dispatchEvent(new NetworkEvent(NetworkEvent.NETWORK_ACTION_RECEIVED, null,
								{"player":player, "entityNetID":entityNetID, "actionID":action, "args":args.split(","), "bfMsgID":bfMsgID}));
		}
		
		public function dispatchPopulateLocationBattlefieldsPanel():void {
			dispatchEvent(new NetworkEvent(NetworkEvent.POPULATE_LOCATION_BATTLEFIELDS_PANEL, null));
		}
		
		public function dispatchUpdateBattleWaitngPanel():void {
			dispatchEvent(new NetworkEvent(NetworkEvent.UPDATE_BATTLE_WAITING_PANEL, null));
		}
		
		public function dispatchStartBattlefieldGame():void {
			dispatchEvent(new NetworkEvent(NetworkEvent.START_BATTLEFIELD_GAME, null));
		}
		public function dispatchStartBattle():void {
			dispatchEvent(new NetworkEvent(NetworkEvent.START_BATTLE, null));
		}
		public function dispatchBattlefieldCycle():void {
			dispatchEvent(new NetworkEvent(NetworkEvent.BATTLEFIELD_CYCLE, null));
		}
		
		//EVENTS
		protected function onLoginSuccess(event:PDSClientEvent):void  {
            trace("connected to server");
            Settings.loggedIn = true;
            sendSessionMessage(MessageFactory.createLoginMessage(_username, _password));
        }
        
        protected function onLoginFailure(event:PDSClientEvent):void  {
            trace("onLoginFailure:" + event.failureMessage);
            mHandler.loginFailed();
        }
        
        protected function onLoginRedirect(event:PDSClientEvent):void  {
            trace("onLoginRedirect:" + event.host + " :" + event.port);
        }
        
        protected function onChannelJoin(e:PDSClientEvent):void {
            trace("##### CHANNEL JOIN [" + e.channel.name + "]");
            if (e.channel.name.indexOf(BATTLEFIELD_CHANNEL_PREFIX) > 0)
            	localGameplayChannel = e.channel;
            else if (e.channel.name == OPEN_GAME_CHANNEL_NAME)
            	openGameChannel = e.channel;
            else if (e.channel.name.indexOf(COMBAT_CHANNEL_PREFIX) > 0) {
            	battleChannel = e.channel;
            	dispatchStartBattle();
            }
        }
        
        protected function onChannelLeave(e:PDSClientEvent):void {
            trace("##### CHANNEL LEAVE [" + e.channel.name + "]");
            if (e.channel.name.indexOf(BATTLEFIELD_CHANNEL_PREFIX) > 0)
            	localGameplayChannel = null;
            else if (e.channel.name == OPEN_GAME_CHANNEL_NAME)
            	openGameChannel = null;
            else if (e.channel.name.indexOf(COMBAT_CHANNEL_PREFIX) > 0)
            	battleChannel = null;
        }
        
        protected function onSessionMessage(e:PDSClientEvent):void {
        	//needs fixing
        	//e.sessionMessage.uncompress(CompressionAlgorithm.DEFLATE);
        	var msg:String = e.sessionMessage.toString();
        	trace("session message :" + msg);
            mHandler.handleMessage(new XML(msg), this);
        }
        
        protected function onChannelMessage(e:PDSClientEvent):void {
        	//e.channelMessage.uncompress(CompressionAlgorithm.DEFLATE);
        	var msg:String = e.channelMessage.toString();
            trace("channel message :" + msg);
            mHandler.handleMessage(new XML(msg), this);
        }
        
        protected function onRawMessage(e:PDSClientEvent):void {
            trace("raw message :" );
        }
	}
}
class PrivateClass {}