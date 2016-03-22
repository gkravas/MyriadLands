package myriadLands.net
{
	public class MLProtocol
	{
		public static const LOGOUT_REQUEST:int = 0;
		public static const LOGIN_REQUEST:int = 1;
	    public static const LOGIN_SUCCESS:int = 2;
	    public static const LOGIN_FAILURE:int = 3;
	    public static const ACTION_PERFORMED:int = 4;
	    public static const PLAYER_JOINED_BATTLEFIELD:int = 5;
	    public static const PLAYER_LEFT_BATTLEFIELD:int = 6;
	    public static const REQUEST_JOIN_BATTLEFIELD:int = 7;
	    public static const OTHER_PLAYERS_JOINED_BATTLEFIELD:int = 8;
	    public static const REQUEST_OTHER_PLAYERS_JOINED_LOCATION:int = 9;
	    public static const PLAYER_FRIEND_STATE_CHANGED:int = 10;
	    public static const AQUIRE_BATTLEFIELDS:int = 11;
	    public static const CREATE_BATTLEFIELD:int = 12;
	    public static const BATTLEFIELD_CREATION_SUCCESS:int = 13;
    	public static const BATTLEFIELD_CREATION_FAIL:int = 14;
    	public static const BATTLEFIELD_UPDATE:int = 15;
    	public static const BATTLEFIELD_REMOVED:int = 16;
    	public static const PLAYER_READY_IN_BATTLEFIELD:int = 17;
    	public static const BATTLEFIELD_READY_FOR_GAME:int = 18;
    	public static const PLAYER_REQUEST_LEAVE_BATTLEFIELD:int = 19;
    	public static const REQUEST_JOIN_BATTLEFIELD_FAILED:int = 20;
    	public static const CHAT_OPEN_MESSAGE:int = 21;
    	public static const CHAT_BATTLEFIELD_MESSAGE:int = 22;
    	public static const PLAYERS_GO_TO_BATTLE:int = 23;
    	public static const PLAYERS_LEAVE_BATTLE:int = 24;
    	public static const BATTLEFIELD_CYCLE:int = 25;
    	public static const COMBAT_CYCLE:int = 26;
	    
		public static const TYPE:String = "type";
    	public static const PASSWORD:String = "password";
    	public static const USER:String = "user";
    	public static const USERS:String = "users";
    	public static const ACTION:String = "action";
    	public static const ENTITY:String = "entity";
    	public static const ARGS:String = "args";
    	public static const LOCATION:String = "location";
    	public static const CITADEL_COORDS:String = "citadel";
		public static const BATTLEFIELD_MAP:String = "battlefieldMap";
		public static const FRIEND_STATE:String = "friendState";
		public static const TO_USER:String = "toUser";
		public static const BATTLEFIELDS:String = "battlefields";
		public static const MAX_PLAYERS:String = "maxPlayers";
		public static const BATTLEFIELD_WIDTH:String = "battlefieldWidth";
		public static const BATTLEFIELD_NAME:String = "battlefieldName";
		public static const PLAYERS_IN_BATTLEFIELD:String = "playersIn";
    	public static const OPEN_GAME:String = "openGame";
		public static const REASON:String = "reason";
		public static const PLAYERS_READY_IN_BATTLEFIELD:String = "playersReadyInBattlefield";
		public static const MESSAGE:String = "message";
		public static const COLOR:String = "color";
		public static const COLORS:String = "colors";
		public static const CHAT_MESSAGE:String = "chatMsg";
		public static const BATTLEFIELD_MSG_ID:String = "bfMsgID";
		public static const OPONENT:String = "oponent";
		
		public static const PLAYER_LOST_BATTLE:int = 0;
		public static const PLAYER_DISCONECTED_BY_FORCE:int = 1;
		public static const PLAYER_GAVE_UP_BATTLE:int = 2;
	}
}