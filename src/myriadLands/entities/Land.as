package myriadLands.entities
{	
	import gamestone.utils.NumberUtil;
	
	import myriadLands.actions.CentralManager;
	import myriadLands.core.Settings;
	import myriadLands.events.CentralManagerEvent;
	import myriadLands.events.LandEvent;
	import myriadLands.faction.Faction;
	import myriadLands.ui.asComponents.WorldMapTile;
	
	public class Land extends Tile
	{
		public static const PREFIX:String = "land";
		
		public static const DEMOLISH_DESTROY_TYPE:int = 0;
		
		protected var _structure:Structure;
		protected var _squad:Squad;		
		protected var _isRuin:Boolean;
		protected var _explored:Boolean;
		protected var _inBattle:Boolean;
		
		public function Land(dataName:String, data:EntityData)
		{
			super(dataName, data);
			_renderableAttributes = ["xylanSpawned", "morphidSpawned", "brontiteSpawned", "crf", "sel", "cap"];
			addEventListener(LandEvent.GO_TO_COMBAT, CentralManager.getInstance().initCombatMap, false, 0, true);
		}
				
		protected override function setDataFromXML():void
		{
			super.setDataFromXML();
		}
		
		public override function getStringData():Array
		{
			var arr:Array = [];
			var value:String;
			for each(var field:String in _renderableAttributes)
			{
				value = this[field];
				arr.push(field + ": " + value);
			}
			return arr;
		}
		
		public function explore(chance:int, ruinName:String = ""):void {
			if (_explored) return;
			//var _ruinName:String = ruinName == "" ? Ruin.getRandomRuin() : ruinName;
			_isRuin = NumberUtil.randomDecision(chance * 0.1);
			_isRare = _isRuin;
			_explored = true;
			assignRuin(faction, ruinName);
			//return _ruinName;
		}
		
		public function attack(attacker:Squad, gridSize:int):void {
			var mySquad:Squad;
			var enemySquad:Squad;
			if (squad.faction == Settings.player) {
				mySquad = squad;
				enemySquad = attacker;
			} else {
				mySquad = attacker;
				enemySquad = squad;
			}
			dispatchEvent(new LandEvent(LandEvent.GO_TO_COMBAT, mySquad, enemySquad, attacker.faction, this, gridSize));
		}
		
		public function assignToFaction(faction:Faction):void {
			if (faction.availableLands == 0) return;
			if (this.faction ==  null) {
				faction.addLand(this);
			} else {
				if (this.faction != faction) {
					this.faction.removeLand(this);
					faction.addLand(this);
				}
			}
		}
		
		/*public function assignFlagstone(faction:Faction):void
		{
			assignToFaction(faction);
			var flagstone:Structure = EntityLoader.getInstance().getEntity(EntityType.FLAGSTONE);
			assignStructure(flagstone);
		}*/
		
		public function assignRuin(faction:Faction, ruinName:String):void
		{
			assignToFaction(faction);
			worldMapTile.convertLandTo(ruinName);
		}
		
		protected function assignStructure(structure:Structure):void {
			structure.parentEntity = this;
			structure.state = EntityState.IN_WORLD_MAP;
			worldMapTile.assignStructure(structure);
		}
		
		protected function removeStructure():void {
			//faction.removeActiveStructure(structure);
			structure.state = EntityState.IN_VAULT;
			worldMapTile.removeStructure();
			if (structure is Citadel)
				faction.gameLost();
			faction = null;
		}
		
		public function destroyStructure(destructionType:int = 0):void {
			structure = null;
		}
				
		//SETTERS
		public function set structure(structure:Structure):void {
			if (structure == null) {
				removeStructure();
				_structure = null;
			} else {
				if (_structure != null) {
					_structure.parentEntity = null;
					_structure.faction.addToVault(_structure);
					//worldMapTile.removeStructure();
				}
				_structure = structure;
				_structure.parentEntity = this;
				assignStructure(structure);
			}
			fireUpdate(false, false, true);
		}
		
		public function set squad(sq:Squad):void {
			if (sq == null) {
				_squad = null;
				worldMapTile.removeSquadGlow();
			} else {
				if (_squad != null)
					_squad.parentEntity = null;
				_squad = sq;
				_squad.parentEntity = this;
				worldMapTile.addSquadGlow();
			}
			fireUpdate(false, false, true);
		}
		
		//SETTERS
		EntityInternal function setInBattle(v:Boolean):void {_inBattle = v;}
		//GETTERS
		public function get structure():Structure {return _structure;}
		public function get squad():Squad {return _squad;}
		public function get explored():Boolean {return _explored;}
		public function get worldMapTile():WorldMapTile {return mapTile as WorldMapTile;}
		public function get inBattle():Boolean {return _inBattle;}		
		
		//EVENTS
		protected override function onCycle(e:CentralManagerEvent):void	{
			if (faction == null) return;
			faction.xylan += _spn.xylan;
			faction.morphid += _spn.morphid;
			faction.brontite += _spn.brontite;
		}
	}
}