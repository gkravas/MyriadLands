package myriadLands.faction {
	
	import flash.errors.IllegalOperationError;
	
	import myriadLands.net.MessageFactory;
	import myriadLands.net.NetworkManager;
		
	public class FactionAllianceManager {
		
		private static var _this:FactionAllianceManager;
	
		protected var alliances:Object;
		protected var factions:Object;
		protected var _player:Faction;
		protected var _netM:NetworkManager;
		
		public function FactionAllianceManager(pvt:PrivateClass) {
			if (pvt == null)
			{
				throw new IllegalOperationError("FactionAllianceManager cannot be instantiated externally. EntityManager.getInstance() method must be used instead.");
				return null;
			}
			alliances = {};
			factions = {};
		}
		
		public static function getInstance():FactionAllianceManager
		{
			if (FactionAllianceManager._this == null)
				FactionAllianceManager._this = new FactionAllianceManager(new PrivateClass());
			return FactionAllianceManager._this;
		}
		
		public static function clear():void
		{
			_this.alliances = {};
			_this.factions = {};
			_this._player = null;
		}
		
		public function addFaction(faction:Faction):void {
			if (faction.isPlayer)
				_player = faction;
				
			var arr:Array = [];
			
			var f:Faction;
			for each(f in factions) {
				(alliances[f.name] as Array).push(new FactionAllianceObj(faction.name, Faction.NEUTRAL));
				arr.push(new FactionAllianceObj(f.name, Faction.NEUTRAL));
			}
			factions[faction.name] = faction;
			alliances[faction.name] = arr;
		}
		
		public function addFactionAlliance(faction:Faction, allianceFaction:Faction, friendState:String):void {
			gatFanctionName(faction);
			gatFanctionName(allianceFaction);
			(alliances[faction.name] as Array).push(new FactionAllianceObj(allianceFaction.name, friendState));
			faction.updateFriendColorState();
			allianceFaction.updateFriendColorState();
		}
		
		public function modifyFactionAlliance(faction:*, allianceFaction:*, friendState:String, fromNet:Boolean = false):void {
			var factionName:String = gatFanctionName(faction);
			var allianceFactionName:String = gatFanctionName(allianceFaction);
			searchForAlliance(alliances[factionName] as Array, allianceFactionName).friendState = friendState;
			searchForAlliance(alliances[allianceFactionName] as Array, factionName).friendState = friendState;
			factions[factionName].updateFriendColorState();
			factions[allianceFactionName].updateFriendColorState();
			
			if(!fromNet)
				_netM.sendLocalGameMessage(MessageFactory.createPlayerChangedFriendStateMessage(factionName, allianceFactionName, friendState));
		}
		
		public function getAlliance(faction:*, allianceFaction:*):String {
			var factionName:String = gatFanctionName(faction);
			var allianceFactionName:String = gatFanctionName(allianceFaction);
			if (factionName == allianceFactionName)
				return Faction.PLAYER;
			return searchForAlliance(alliances[factionName] as Array, allianceFactionName).friendState;
		}
		
		public function getAllianceWithPlayer(allianceFaction:*):String {
			return getAlliance(player, allianceFaction);
		}
		
		protected function searchForAlliance(arr:Array, aFactionName:String):FactionAllianceObj {
			var fao:FactionAllianceObj;
			for each (fao in arr)
				if (fao.faction == aFactionName)
					return fao;
			return null;
		}
		
		protected function gatFanctionName(faction:*):String {
			if (faction is Faction) {
				if (!factions.hasOwnProperty(faction.name))
					new IllegalOperationError("Faction with name: " + faction.name + " doesn't exist");
				return faction.name;
			} else if (faction is String) {
				if (!factions.hasOwnProperty(faction))
					new IllegalOperationError("Faction with name: " + faction + " doesn't exist");
				return faction;
			}
			return null
		}
		
		//SETTERS
		public function set networkManager(v:NetworkManager):void {_netM = v;}
		
		//GETTERS
		public function get player():Faction {return _player;}
	}
} class PrivateClass {}