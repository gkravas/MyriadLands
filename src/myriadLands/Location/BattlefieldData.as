package myriadLands.Location {
	
	public class BattlefieldData {
		
		protected var _name:String;
		protected var _locationName:String;
		protected var _maxPlayers:int;
		protected var _playersIn:int;
		protected var _readyPlayers:int;
		protected var _open:Boolean;
		protected var update:Function;
			
		public function BattlefieldData(locationName:String, name:String, maxPlayers:int, playersIn:int, open:Boolean) {
			_name = name;
			_locationName = locationName;
			_maxPlayers = maxPlayers;
			_playersIn = playersIn;
			_readyPlayers = 0;
			_open = open;
		}
		
		public function setUpdateCallback(f:Function):void {
			update = f;
		}
		
		public function getDataObject():Object {
			return {name:name, maxPlayers:maxPlayers, playersIn:playersIn, open:_open};
		}
		
		//SETTERS
		public function set locationName(v:String):void {_locationName = v;}
		public function set maxPlayers(v:int):void {
			_maxPlayers = v;
			update.apply(null, [_playersIn, _maxPlayers, _readyPlayers]);
		}
		public function set playersIn(v:int):void {
			_playersIn = v;
			update.apply(null, [_playersIn, _maxPlayers, _readyPlayers]);
		}
		public function set readyPlayers(v:int):void {
			_readyPlayers = v;
			update.apply(null, [_playersIn, _maxPlayers, _readyPlayers]);
		}
		
		//GETTERS
		public function get name():String {return _name;}
		public function get locationName():String {return _locationName;}
		public function get maxPlayers():int {return _maxPlayers;}
		public function get playersIn():int {return _playersIn;}
		public function get readyPlayers():int {return _readyPlayers;}
	}
}