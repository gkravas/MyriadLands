package myriadLands.faction
{
	import flash.events.EventDispatcher;
	
	import gamestone.utils.ArrayUtil;
	
	import myriadLands.actions.ActionView;
	import myriadLands.actions.CentralManager;
	import myriadLands.entities.Citadel;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.Entity;
	import myriadLands.entities.EntityState;
	import myriadLands.entities.EntityType;
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.entities.Structure;
	import myriadLands.events.CentralManagerEvent;
	import myriadLands.events.FactionEvent;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.net.NetInternal;
	import myriadLands.net.NetworkManager;
	import myriadLands.ui.asComponents.WorldMapTile;
	import myriadLands.ui.css.MLFilters;
	
	[Bindable]
	public class Faction extends EventDispatcher
	{
		
		public static const FRIEND:String = "friend";
		public static const NEUTRAL:String = "neutral";
		public static const FOE:String = "foe";
		public static const PLAYER:String = "player";
		
		protected var _name:String;
		///The central land, with the citadel in
		protected var _centralMapTile:WorldMapTile;
		//Contains all entities on the map of the faction
		//Here we put all entities and the entities inside other entities
		protected var entities:Array;
		//Contains all dead entities of the faction
		protected var vault:Array;
		//Contains all entities ready for export of the faction
		protected var tradeExport:Array;
		//Contains all entities ready for import of the faction
		protected var tradeImport:Array;
		//Contains all entities ready for addition of the faction
		protected var inventory:Array;
		//Contains all lands of this faction
		protected var lands:Array;
		//Contains all structures of this faction
		protected var structures:Array;
		//Contains all battlegroups of this faction
		protected var battlegroups:Array;
		
		protected var _morphid:int=0;
		protected var _maxMorphid:int=0;
		protected var _xylan:int=0;
		protected var _maxXylan:int=0;
		protected var _brontite:int=0;
		protected var _maxBrontite:int=0;
		
		protected var _activeBattlegroups:int;
		protected var _maxBattlegroups:int;
		protected var _activeLands:int;
		protected var _maxLands:int;
		protected var _activeStructures:int;
		protected var _maxStructures:int;
		
		protected var _preservedEntities:int;
		protected var _maxPreservedEntities:int;
		
		protected var el:EntityLoader;
		protected var cm:CentralManager;
		
		protected var recyclingEnabled:Boolean;
		protected var tradeEnabled:Boolean;
		protected var fam:FactionAllianceManager;
		//protected var _friendState:String;
		protected var _isPlayer:Boolean;
		protected var _strokeColor:uint;
		protected var _combatTileBase:CombatGround;
		
		protected var entitiesInVaultForDestruction:Object;
		
		protected var _loosesGame:Boolean;
		protected var _isInBattle:Boolean;
		
		NetInternal var networkEntityCnt:int = 0;
		
		public function Faction(name:String, color:String) {
			_name = name;
			_isPlayer = false;
			fam = FactionAllianceManager.getInstance();
			//_friendState = Faction.NEUTRAL;
			entities = [];
			vault = [];
			tradeExport = [];
			tradeImport = [];
			inventory = [];
			lands = [];
			structures = [];
			battlegroups = [];
			entitiesInVaultForDestruction = {};
			_strokeColor = parseInt(color);
			
			maxLands = 1;
			maxStructures = 1;
			el = EntityLoader.getInstance();
			cm = CentralManager.getInstance();
		}
		
		public function destroy():void {
			var ent:Entity;
			for each(ent in entities) {
				if (ent is Land || ent is Structure) continue;
				if (ent is Squad) {
					if (ent.parentEntity != null) {
						if (ent.parentEntity is Land)
							(ent.parentEntity as Land).squad = null;
						else if (ent.parentEntity is CombatGround)
							(ent.parentEntity as CombatGround).entityOn = null;
					}
				}
				ent.destroy();
				ent = null;
			}
			entities = null;
			vault = null;
			tradeExport = null;
			tradeImport = null;
			inventory = null;
			lands = null;
			structures = null;
			battlegroups = null;
			
			var obj:Object;
			var netID:int;
			for each(obj in entitiesInVaultForDestruction) {
				netID = obj.entity.networkID;
				entitiesInVaultForDestruction[netID] = null;
				delete entitiesInVaultForDestruction[netID];
				obj.entity.destroy();
			}
			entitiesInVaultForDestruction = null;
			
			el = null;
			cm = null;
			_combatTileBase = null;
			NetworkManager.getInstance().removeFaction(this);
		}
		
		public function init(centralMapTile:WorldMapTile):void {
			initListeners();
			//_strokeColor = isPlayer ? MLFilters.PLAYER_GLOW : MLFilters.NEUTRAL_GLOW;
			_centralMapTile = centralMapTile;
			_centralMapTile.construct();
			_centralMapTile.landTileEntity.assignToFaction(this);
			createCitadel();
			if (isPlayer) {
				_centralMapTile.scrollToMe();
				_centralMapTile.landTileEntity.fireSelectedEvent(ActionView.WORLD_MAP);
				_centralMapTile.landTileEntity.structure.fireSelectedEvent(ActionView.SELECTION_PANEL);
			}
		}
		
		private function initListeners():void {
			addEventListener(FactionEvent.ENTITY_ADDED_TO_INVENTORY, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_REMOVED_FROM_INVENTORY, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_ADDED_TO_VAULT, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_REMOVED_FROM_VAULT, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_ADDED_TO_EXPORT, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_REMOVED_FROM_EXPORT, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_ADDED_TO_IMPORT, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.ENTITY_REMOVED_FROM_IMPORT, cm.factionUpdated,false ,0, true);
			
			addEventListener(FactionEvent.FACTION_LOST, cm.factionUpdated,false ,0, true);
			addEventListener(FactionEvent.MAX_PRESERVED_ENTITIES_CHANGED, cm.factionUpdated, false ,0, true);
			cm.addEventListener(CentralManagerEvent.CYCLE_PASSED, onCyclePass, false, 0, true);
			
		}
		
		public function addLand(land:Land):Boolean
		{
			if (activeLands == maxLands)
				return false;
			lands.push(land);
			addEntity(land);
			activeLands += 1;
			land.faction = this;
			return true;
		}
		
		public function removeLand(land:Land):void
		{
			lands = ArrayUtil.remove(lands, land);
			removeEntity(land);
			activeLands -= 1;
			land.faction = null;
		}
		
		public function getLands():Array
		{
			return lands;
		}
		
		public function addActiveStructure(str:Structure):Boolean
		{
			if (activeStructures == maxStructures)
				return false;
			structures.push(str);
			activeStructures++;
			return true;
		}
		
		public function removeActiveStructure(str:Structure):Boolean
		{
			if (activeStructures == 0) return false;
			structures = ArrayUtil.remove(structures, str);
			activeStructures--;
			return true;
		}
		
		public function getActiveStructures():Array
		{
			return structures;
		}
		
		public function addActiveBattlegroup(squad:Squad):Boolean
		{
			if (activeBattlegroups == maxBattlegroups)
				return false;
			if (ArrayUtil.inArray(battlegroups, squad))
				return false;
			battlegroups.push(squad);
			//addEntity(squad);
			activeBattlegroups += 1;
			return true;
		}
		
		public function removeActiveBattlegroup(squad:Squad):void
		{
			battlegroups = ArrayUtil.remove(battlegroups, squad);
			//removeEntity(squad);
			activeBattlegroups -= 1;
		}
		
		public function getActiveBattlegroup():Array
		{
			return battlegroups;
		}
		
		public function addEntity(entity:Entity):void
		{
			if (ArrayUtil.inArray(entities, entity)) return;
			entities.push(entity);
			entity.faction = this;
		}
		
		public function removeEntity(entity:Entity):void
		{
			entities = ArrayUtil.remove(entities, entity);
			entity.faction = null;
		}
		
		public function getEntities():Array
		{
			return entities;
		}
		
		public function addToVault(entity:Entity):Boolean
		{
			if (availablePreservedEntities == 0) return false;
			preservedEntities++;
			vault.push(entity);
			entitiesInVaultForDestruction[entity.networkID] = {cycles:20, entity:entity};
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_ADDED_TO_VAULT, entity, this));
			entity.state = EntityState.IN_VAULT;
			return true;
		}
		
		public function removeFromVault(entity:Entity):Boolean
		{
			if (availablePreservedEntities == maxPreservedEntities) return false;
			preservedEntities--;
			vault = ArrayUtil.remove(vault, entity);
			entitiesInVaultForDestruction[entity.networkID] = null;
			delete entitiesInVaultForDestruction[entity.networkID];
			//new addition, may cause bug
			entity.destroy();
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_REMOVED_FROM_VAULT, entity, this));
			return true;
		}
		
		public function getVault():Array
		{
			return vault;
		}
		
		protected function vaultCyclePassed():void {
			var o:Object;
			for each (o in entitiesInVaultForDestruction) {
				o.cycles--;
				if (o.cycles == 0)
					removeFromVault(o.entity);
			}
		}
		
		public function addToExportion(entity:Entity):void
		{
			tradeExport.push(entity);
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_ADDED_TO_EXPORT, entity, this));
		}
		
		public function removeFromExportion(entity:Entity):void
		{
			tradeExport = ArrayUtil.remove(tradeExport, entity);
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_REMOVED_FROM_EXPORT, entity, this));
		}
		
		public function getExportion():Array
		{
			return tradeExport;
		}
		
		/**
		 *Just dummy for assetPool panel entity addition. For use with action classes. 
		 * @param entity
		 */		
		public function addToImportion(entity:Entity):void
		{
			//tradeImport.push(entity);
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_ADDED_TO_IMPORT, entity, this));
		}
		
		/**
		 *Just dummy for assetPool panel entity removal. For use with action classes. 
		 * @param entity
		 */		
		public function removeFromImportion(entity:Entity):void
		{
			//tradeImport = ArrayUtil.remove(tradeImport, entity);
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_REMOVED_FROM_IMPORT, entity, this));
		}
		
		/*public function getImportion():Array
		{
			return tradeImport;
		}*/
		
		public function addToInventory(entity:Entity):void
		{
			inventory.push(entity);
			entity.state = EntityState.IN_INVENTORY;
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_ADDED_TO_INVENTORY, entity, this));
		}
		
		public function removeFromInventory(entity:Entity):void
		{
			inventory = ArrayUtil.remove(inventory, entity);
			dispatchEvent(new FactionEvent(FactionEvent.ENTITY_REMOVED_FROM_INVENTORY, entity, this));
		}
		
		public function getInventory():Array {
			return inventory;
		}
		
		protected function createCitadel():void {
			var citadel:Citadel = el.getEntity(EntityType.CITADEL, null);
			addEntity(citadel);
			addActiveStructure(citadel);
			_centralMapTile.landTileEntity.structure = citadel;
			citadel.fixID(_centralMapTile.landTileEntity.networkID.replace("land_", ""));
		}
				
		public function getEntityByNetworkID(id:String):Entity {
			var entity:Entity;
			for each (entity in entities) {
				if (entity.networkID == id )
					break;
			} return entity;
		}
		
		public function gameLost():void {
			dispatchEvent(new FactionEvent(FactionEvent.FACTION_LOST, null, this));
		}
		
		public function gameWon():void {
			
		}
		
		public function updateFriendColorState():void {
			return;
			if (this.isPlayer) return;
			var friendState:String = fam.getAlliance(fam.player, this);
			if (friendState == Faction.FRIEND)
				_strokeColor = MLFilters.FRIEND_GLOW;
			else if (friendState == Faction.NEUTRAL)
				_strokeColor = MLFilters.NEUTRAL_GLOW;
			else if (friendState == Faction.FOE)
				_strokeColor = MLFilters.FOE_GLOW;
				
			var str:Structure;
			for each(str in structures)
				(str.parentEntity as Land).worldMapTile.showPlayerGlow();
		}
		
		protected function onCyclePass(e:CentralManagerEvent):void {
			vaultCyclePassed();
		}
		
		public function getAllianceWithFaction(faction:Faction):String {
			return fam.getAlliance(this, faction);
		}
		
		public function isFactionAlliance(faction:Faction, arr:Array):Boolean {
			var friendState:String = getAllianceWithFaction(faction);
			return ArrayUtil.inArray(arr, friendState);
		}
		
		//GETTERS
		public function get citadel():Citadel {return _centralMapTile.landTileEntity.structure as Citadel;}
		public function get centralMapTile():WorldMapTile {return _centralMapTile;}
		public function get name():String {return _name;}
		//public function get friendState():String {return _friendState;}
		public function get isPlayer():Boolean { return _isPlayer;}
		public function get getRecyclingEnabled():Boolean { return recyclingEnabled;}
		public function get getTradeEnabled():Boolean { return tradeEnabled;}
		
		public function get morphid():int { return _morphid;}
		public function get maxMorphid():int { return _maxMorphid;}
		public function get xylan():int { return _xylan;}
		public function get maxXylan():int { return _maxXylan;}
		public function get brontite():int { return _brontite;}
		public function get maxBrontite():int { return _maxBrontite;}
		
		public function get activeBattlegroups():int { return _activeBattlegroups;}
		public function get maxBattlegroups():int { return _maxBattlegroups;}
		public function get availableBattlegroups():int { return _maxBattlegroups - activeBattlegroups;}
		public function get activeLands():int { return _activeLands;}
		public function get maxLands():int { return _maxLands;}
		public function get availableLands():int { return _maxLands - _activeLands;}
		public function get activeStructures():int { return _activeStructures;}
		public function get maxStructures():int { return _maxStructures;}
		public function get availableStructures():int { return _maxStructures - _activeStructures;}
		
		public function get preservedEntities():int { return _preservedEntities;}
		public function get maxPreservedEntities():int { return _maxPreservedEntities;}
		public function get availablePreservedEntities():int { return _maxPreservedEntities - _preservedEntities;}
		
		public function get strokeColor():uint { return _strokeColor;}
		
		public function get combatGroundBase():CombatGround { return _combatTileBase;}
		public function get loosesGame():Boolean { return _loosesGame;}
		public function get isInBattle():Boolean { return _isInBattle;}
		
		//SETTERS				
		NetInternal function setIsPlayer(v:Boolean):void {_isPlayer = v;}
		public function setRecyclingEnabled(v:Boolean):void	{recyclingEnabled = v;}
		public function setTradeEnabled(v:Boolean):void {tradeEnabled = v;}
		
		public function set morphid(v:int):void {
			if (v >= 0)
				_morphid = (v < _maxMorphid) ? v :_maxMorphid;
		}
		public function set maxMorphid(v:int):void {_maxMorphid = v;}
		public function set xylan(v:int):void {
			if (v >= 0)
				_xylan = (v < _maxXylan) ? v :_maxXylan;
		}
		public function set maxXylan(v:int):void {_maxXylan = v;}
		public function set brontite(v:int):void {
			if (v >= 0)
				_brontite = (v < _maxBrontite) ? v :_maxBrontite;
		}
		public function set maxBrontite(v:int):void {_maxBrontite = v;}
		
		public function set activeBattlegroups(v:int):void {if (_activeBattlegroups < _maxBattlegroups) _activeBattlegroups = v;}
		public function set maxBattlegroups(v:int):void {_maxBattlegroups = v;}
		public function set activeLands(v:int):void {if (_activeLands < _maxLands) _activeLands = v;}
		public function set maxLands(v:int):void {_maxLands = v;}
		public function set activeStructures(v:int):void {if(_activeStructures < _maxStructures) _activeStructures = v;}
		public function set maxStructures(v:int):void {_maxStructures = v;}
		
		public function set preservedEntities(v:int):void {if(_preservedEntities < _maxPreservedEntities) _preservedEntities = v;}
		public function set maxPreservedEntities(v:int):void {
			_maxPreservedEntities = v;
			dispatchEvent(new FactionEvent(FactionEvent.MAX_PRESERVED_ENTITIES_CHANGED, null, this));
		}
		
		public function set combatGroundBase(v:CombatGround):void {_combatTileBase = v;}
		public function set loosesGame(v:Boolean):void {_loosesGame = v;}
		public function set isInBattle(v:Boolean):void {_isInBattle = v;}
	}
}