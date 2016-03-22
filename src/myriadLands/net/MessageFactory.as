package myriadLands.net
{
	import com.pdsClient.util.PDSByteArray;
	import com.pdsClient.util.XMLPacketier;
	
	import myriadLands.entities.Entity;
	
	public class MessageFactory
	{
		public function MessageFactory()
		{
		}
		
		public static function createLoginMessage(username:String, password:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.LOGIN_REQUEST,
													"user":username, "password": password},
													[MLProtocol.TYPE, MLProtocol.USER,
													 MLProtocol.PASSWORD]);
		}
		
		public static function createActionMessage(username:String, entity:Entity, actionID:int, args:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.ACTION_PERFORMED,
													"user":username, "entity":entity.networkID, "action": actionID, "args":args},
													[MLProtocol.TYPE, MLProtocol.USER,
													MLProtocol.ENTITY, MLProtocol.ACTION,
													MLProtocol.ARGS]);
		}
		
		public static function createLocationJoinRequestMessage(username:String, battlefieldName:String, password:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.REQUEST_JOIN_BATTLEFIELD,
													"user":username, "battlefieldName":battlefieldName, "password":password},
													[MLProtocol.TYPE, MLProtocol.USER, MLProtocol.BATTLEFIELD_NAME, MLProtocol.PASSWORD]);
		}
		
		public static function createRequestOtherPlayersPositionMessage(username:String, location:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.REQUEST_OTHER_PLAYERS_JOINED_LOCATION,
													"user":username, "location":location},
													[MLProtocol.TYPE, MLProtocol.USER, MLProtocol.LOCATION]);
		}
		public static function createPlayerChangedFriendStateMessage(username:String, toUser:String, friendState:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.PLAYER_FRIEND_STATE_CHANGED, "user":username,
													"friendState":friendState, "toUser":toUser},
													[MLProtocol.TYPE, MLProtocol.USER, MLProtocol.FRIEND_STATE, MLProtocol.TO_USER]);
		}
		public static function createCreateBattlefieldMessage(username:String, location:String, battlefieldName:String, maxPlayers:int, password:String, battlefieldWidth:int):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.CREATE_BATTLEFIELD, "user":username,
													"location":location, "battlefieldName":battlefieldName,
													"maxPlayers":maxPlayers, "password":password, "battlefieldWidth":battlefieldWidth},
													[MLProtocol.TYPE, MLProtocol.USER, MLProtocol.LOCATION, MLProtocol.BATTLEFIELD_NAME,
													MLProtocol.MAX_PLAYERS, MLProtocol.PASSWORD, MLProtocol.BATTLEFIELD_WIDTH]);
		}
		public static function createPlayerRequestLeaveBattlefieldMessage(username:String, reason:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.PLAYER_REQUEST_LEAVE_BATTLEFIELD, "user":username, "reason":reason}, [MLProtocol.TYPE, MLProtocol.USER, MLProtocol.REASON]);
		}
		public static function createPlayerReadyInBattlefieldMessage(username:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.PLAYER_READY_IN_BATTLEFIELD, "user":username}, [MLProtocol.TYPE, MLProtocol.USER]);
		}
		public static function createLogoutRequestMessage(username:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.LOGOUT_REQUEST, "user":username}, [MLProtocol.TYPE, MLProtocol.USER]);
		}
		//Universal for all chat messaged
		public static function createChatMessage(type:int, username:String, msg:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":type, "user":username, "chatMsg":msg}, [MLProtocol.TYPE, MLProtocol.USER, MLProtocol.CHAT_MESSAGE]);
		}
		
		public static function createPlayersGoToBattleMessage(oponent:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.PLAYERS_GO_TO_BATTLE, "oponent":oponent}, [MLProtocol.TYPE, MLProtocol.OPONENT]);
		}
		public static function createPlayersLeaveBattleMessage(oponent:String):PDSByteArray {
			return XMLPacketier.createXMLSGSPacket({"type":MLProtocol.PLAYERS_LEAVE_BATTLE, "oponent":oponent}, [MLProtocol.TYPE, MLProtocol.OPONENT]);
		}
	}
}