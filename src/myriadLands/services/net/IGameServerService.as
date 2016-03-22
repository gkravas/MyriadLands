package myriadLands.services.net {
	
	public interface IGameServerService {
		function sendMessage(id:int, args:Object):void
		function login(username:String, password:String):void
		function logout(forced:Boolean):void
	}
}