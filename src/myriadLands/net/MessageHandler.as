package myriadLands.net
{
	import com.pdsClient.util.PDSByteArray;
	
	import flash.events.Event;
	
	import gamestone.localization.LocalizationDictionary;
	import gamestone.utils.DebugX;
	
	import mx.controls.Alert;
	
	import myriadLands.actions.Action;
	import myriadLands.actions.CentralManager;
	import myriadLands.core.GameHelperClass;
	import myriadLands.core.Settings;
	import myriadLands.entities.EntityManager;
	import myriadLands.entities.Land;
	import myriadLands.faction.Faction;
	import myriadLands.faction.FactionAllianceManager;
	import myriadLands.ui.panels.ChatPanel;
	
	use namespace NetInternal;
	
	public class MessageHandler
	{
		protected var loginListener:Function;
		
		public function MessageHandler() {
		}
		
		public function setLoginListener(loginListener:Function):void {
			this.loginListener = loginListener;
		} 
		
		public function handleMessage(message:XML, netM:NetworkManager): void {
			var type:int = parseInt(message.child(MLProtocol.TYPE));
			var bfMsgID:String = String(message.child(MLProtocol.BATTLEFIELD_MSG_ID));
			switch (type) {
				case MLProtocol.LOGIN_SUCCESS:
					loginSuccess();
				break;
				case MLProtocol.LOGIN_FAILURE:
					loginFailed();
				break;
				case MLProtocol.ACTION_PERFORMED:
					actionPerformed(message.child(MLProtocol.USER),
												 message.child(MLProtocol.ENTITY),
												 message.child(MLProtocol.ACTION),
												 message.child(MLProtocol.ARGS),
												 bfMsgID,
												 netM); 
				break;
				case MLProtocol.PLAYER_JOINED_BATTLEFIELD:
					var user:String = message.child(MLProtocol.USER);
					playerJoined(user, message.child(MLProtocol.BATTLEFIELD_NAME), message.child(MLProtocol.CITADEL_COORDS),
								String(message.child(MLProtocol.COLOR)), String(message.child(MLProtocol.BATTLEFIELD_MAP)), netM);
					//IF player joined is local player. Request other players location
					if (user == Settings.username)
						sendRequestOtherPlayersPosition(message.child(MLProtocol.USER), message.child(MLProtocol.BATTLEFIELD_NAME), netM);
					netM.dispatchUpdateBattleWaitngPanel();
				break;
				case MLProtocol.REQUEST_JOIN_BATTLEFIELD_FAILED:
				var d:LocalizationDictionary = LocalizationDictionary.getInstance();
					Alert.show(d.getLeema(message.child(MLProtocol.REASON)), d.getLeema("joinBattleFail"), Alert.OK,
								null, null, null, Alert.OK);
				break;
				case MLProtocol.PLAYER_LEFT_BATTLEFIELD:
					playerLeft(message.child(MLProtocol.USER), message.child(MLProtocol.LOCATION), netM);
					if (GameHelperClass.currentBattlefield.readyPlayers > GameHelperClass.currentBattlefield.playersIn)
						GameHelperClass.currentBattlefield.readyPlayers = GameHelperClass.currentBattlefield.playersIn;
					netM.dispatchUpdateBattleWaitngPanel();
				break;
				case MLProtocol.OTHER_PLAYERS_JOINED_BATTLEFIELD:
					otherPlayersJoinedBattlefield(message.child(MLProtocol.USERS), message.child(MLProtocol.COLORS), netM);
					netM.dispatchUpdateBattleWaitngPanel();
				break;
				case MLProtocol.PLAYER_FRIEND_STATE_CHANGED:
					playerFriendStateChanged(message.child(MLProtocol.USER), message.child(MLProtocol.TO_USER), message.child(MLProtocol.FRIEND_STATE), netM);
				break;
				case MLProtocol.AQUIRE_BATTLEFIELDS:
					battlefieldsAquired(String(message.child(MLProtocol.BATTLEFIELDS)), netM);
				break;
				case MLProtocol.BATTLEFIELD_CREATION_SUCCESS:
					netM.addBattleField(message.child(MLProtocol.ARGS));
					netM.dispatchPopulateLocationBattlefieldsPanel();
					if (message.child(MLProtocol.USER) == Settings.username) {
						var battlefieldName:String = String(message.child(MLProtocol.ARGS)).split(":")[1];
						sendLocationJoinRequestMessage(netM, battlefieldName, GameHelperClass.battlefieldCreationPassword);
					}
				break;
				case MLProtocol.BATTLEFIELD_CREATION_FAIL:
					
				break;
				case MLProtocol.BATTLEFIELD_UPDATE:
					netM.updateBattleField(message.child(MLProtocol.LOCATION),
										   message.child(MLProtocol.BATTLEFIELD_NAME),
										   message.child(MLProtocol.PLAYERS_IN_BATTLEFIELD),
										   message.child(MLProtocol.PLAYERS_READY_IN_BATTLEFIELD));
					netM.dispatchUpdateBattleWaitngPanel();
				break;
				case MLProtocol.BATTLEFIELD_REMOVED:
					netM.removeBattleField(message.child(MLProtocol.LOCATION),
										   message.child(MLProtocol.BATTLEFIELD_NAME));
				break;
				case MLProtocol.BATTLEFIELD_READY_FOR_GAME:
					netM.dispatchStartBattlefieldGame();
				break;
				case MLProtocol.CHAT_OPEN_MESSAGE:
					ChatPanel.addMessage(message.child(MLProtocol.USER),
										   message.child(MLProtocol.CHAT_MESSAGE));
				break;
				case MLProtocol.CHAT_BATTLEFIELD_MESSAGE:
					ChatPanel.addMessage(message.child(MLProtocol.USER),
										   message.child(MLProtocol.CHAT_MESSAGE));
				break;
				case MLProtocol.BATTLEFIELD_CYCLE:
					netM.dispatchBattlefieldCycle();
				break;
			}
		}
		
		protected function actionPerformed(user:String, entityNetID:String, action:String, args:String, bfMsgID:String, netM:NetworkManager):void {
			DebugX.MyTrace("action " + action + " performed by " + entityNetID + " of faction " + user);
			DebugX.MyTrace("args : " + args);
			DebugX.MyTrace("battlefield message id : " + bfMsgID);
			//netM.getFactionByName(user).engageActionRemoted(entityNetID, action, args.split(","));
			netM.dispatchNetworkActionReceived(user, entityNetID, action, args, bfMsgID);
		}
		
		protected function playerJoined(user:String, battlefieldName:String, citadelCoords:String, color:String, locationMap:String, netM:NetworkManager):void {
			if (netM.getFactionByName(user) != null) return;
			DebugX.MyTrace("Player " + user + " joined location with name " + battlefieldName);
			DebugX.MyTrace("citadel coords are " + citadelCoords);
			var f:Faction = new Faction(user, color);
			//Checks if this faction is player's and then make the bindings to GUI
			if (user == Settings.username) {
				f.setIsPlayer(true);
				CentralManager.getInstance().makeResourceBindings(f);
				CentralManager.getInstance().addEventListener(Event.COMPLETE, mapCreated);
				//MUST BE HERE
				GameHelperClass.currentBattlefield = NetworkManager.getInstance().getBattlefield(GameHelperClass.currentLocation.name, battlefieldName);
				//
				netM.dispatchInitMap(locationMap);
				Settings.player = f;
			}
			netM.addFaction(f);
			f.init((EntityManager.getInstance().getEntityByID("land_" + citadelCoords) as Land).worldMapTile);
			//if (netM.getFactionsNum() == 2 )
			//	BattleScenario.createCombatScenario();
		}
		
		protected function playerLeft(user:String, location:String, netM:NetworkManager):void {
			DebugX.MyTrace("Player " + user + " left location");
			netM.removeFactionByName(user);
		}
		
		protected function otherPlayersJoinedBattlefield(users:String, colors:String, netM:NetworkManager):void {
			DebugX.MyTrace("otherPlayersJoinedLocation " + users);
			if (users == "") return;
			var arr:Array = users.split(",");
			var arr1:Array = colors.split(",");
			var item:String;
			var user:Array;
			var color:String;
			var i:int = 0;
			for each(item in arr) {
				user = item.split(":");
				color = arr1[i];
				playerJoined(user[1], GameHelperClass.currentBattlefield.name, user[0], color, null, netM);
				i++;
			}
		}
		
		protected function sendRequestOtherPlayersPosition(user:String, battlefieldName:String, netM:NetworkManager):void {
			DebugX.MyTrace("Player " + user + " requests other players position");
			netM.sendSessionMessage(MessageFactory.createRequestOtherPlayersPositionMessage(user, battlefieldName));
		}
		
		protected function playerFriendStateChanged(user:String, toUser:String, friendState:String, netM:NetworkManager):void {
			DebugX.MyTrace("Player " + user + " chahged friend state to <<" + friendState + ">> for user " + toUser);
			FactionAllianceManager.getInstance().modifyFactionAlliance(user, toUser, friendState, true);
		}
		
		public function loginSuccess():void {
			DebugX.MyTrace("Login Success");
			loginListener.call(this, "true");
		}
		
		public function loginFailed():void {
			DebugX.MyTrace("Login Failure");
			loginListener.call(this, "false");
		}
		
		protected function battlefieldsAquired(locations:String, netM:NetworkManager):void {
			if (locations == "") return;
			var arr:Array = locations.split(",");
			var data:String;
			for each (data in arr)
				netM.addBattleField(data);
		}
		
		
		//SENDING
		public function sendMessage(type:int, netM:NetworkManager, args:Object = null):void {
			switch (type) {
				case MLProtocol.ACTION_PERFORMED:
					sendActionMessage(args as Action, netM);
				break;
				case MLProtocol.REQUEST_JOIN_BATTLEFIELD:
					sendLocationJoinRequestMessage(netM, args.name, args.password);
				break;
				case MLProtocol.CREATE_BATTLEFIELD:
					sendCreateBattlefieldMessage(args, netM);
				break;
				case MLProtocol.PLAYER_READY_IN_BATTLEFIELD:
					sendPlayerReadyInBattlefieldMessage(netM);
				break;
				case MLProtocol.PLAYER_REQUEST_LEAVE_BATTLEFIELD:
					sendPlayerRequestLeaveBattlefieldMessage(netM, args.reason);
				break;
				case MLProtocol.LOGOUT_REQUEST:
					sendPlayerLogoutRequestMessage(netM);
					//netM.logout(args.force);
				break;
				case MLProtocol.CHAT_OPEN_MESSAGE:
					sendOpenChatMessage(netM, args.msg);
				break;
				case MLProtocol.CHAT_BATTLEFIELD_MESSAGE:
					sendBattleChatMessage(netM, args.msg);
				break;
				case MLProtocol.PLAYERS_GO_TO_BATTLE:
					sendPlayersGoToBattle(netM, args.oponent);
				break;
				case MLProtocol.PLAYERS_LEAVE_BATTLE:
					sendPlayersLeaveBattle(netM, args.oponent);
				break;
			}
		}
		
		protected function sendActionMessage(action:Action, netM:NetworkManager):void {
			var msg:PDSByteArray = MessageFactory.createActionMessage(Settings.username, action.owner, action.data.id, action.getLastEngagementNetworkArguments());
			if (!netM.localPlayerIsInBattle())
				netM.sendLocalGameMessage(msg);
			else
				netM.sendBattleMessage(msg);
		}
		
		protected function sendLocationJoinRequestMessage(netM:NetworkManager, battlefieldName:String, password:String):void {
			netM.sendSessionMessage(MessageFactory.createLocationJoinRequestMessage(Settings.username, battlefieldName, password));
		}
		
		protected function sendCreateBattlefieldMessage(args:Object, netM:NetworkManager):void {
			netM.sendSessionMessage(MessageFactory.createCreateBattlefieldMessage(Settings.username, args.location, args.battlefieldName, args.maxPlayers, args.password, args.battlefieldWidth));
		}
		
		protected function sendPlayerReadyInBattlefieldMessage(netM:NetworkManager):void {
			netM.sendLocalGameMessage(MessageFactory.createPlayerReadyInBattlefieldMessage(Settings.username));
		}
		
		protected function sendPlayerRequestLeaveBattlefieldMessage(netM:NetworkManager, reason:String):void {
			netM.sendLocalGameMessage(MessageFactory.createPlayerRequestLeaveBattlefieldMessage(Settings.username, reason));
		}
		
		protected function sendPlayerLogoutRequestMessage(netM:NetworkManager):void {
			netM.sendSessionMessage(MessageFactory.createLogoutRequestMessage(Settings.username));
		}
		
		protected function sendOpenChatMessage(netM:NetworkManager, msg:String):void {
			netM.sendOpenGameMessage(MessageFactory.createChatMessage(MLProtocol.CHAT_OPEN_MESSAGE, Settings.username, msg));
		}
		
		protected function sendBattleChatMessage(netM:NetworkManager, msg:String):void {
			netM.sendOpenGameMessage(MessageFactory.createChatMessage(MLProtocol.CHAT_BATTLEFIELD_MESSAGE, Settings.username, msg));
		}
		
		protected function sendPlayersGoToBattle(netM:NetworkManager, oponent:Faction):void {
			netM.sendLocalGameMessage(MessageFactory.createPlayersGoToBattleMessage(oponent.name));
		}
		
		protected function sendPlayersLeaveBattle(netM:NetworkManager, oponent:Faction):void {
			netM.sendLocalGameMessage(MessageFactory.createPlayersLeaveBattleMessage(oponent.name));
		}
		//EVENTS
		protected function mapCreated(e:Event):void {
			var netM:NetworkManager = NetworkManager.getInstance(); 
			//if (netM.getFactionsNum() == 2 )
			//	BattleScenario.createCombatScenario();
		}
	}
}