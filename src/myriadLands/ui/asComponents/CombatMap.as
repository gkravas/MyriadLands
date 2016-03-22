package myriadLands.ui.asComponents
{
	import flash.events.MouseEvent;
	
	import gamestone.utils.NumberUtil;
	
	import myriadLands.actions.ActionView;
	import myriadLands.combat.CombatManager;
	import myriadLands.core.Settings;
	import myriadLands.entities.Citadel;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.EntityManager;
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.events.CombatEvent;
	import myriadLands.events.CombatMapEvent;
	import myriadLands.events.CompassEvent;
	import myriadLands.events.MapTileEvent;
	import myriadLands.faction.Faction;
		
	public class CombatMap extends TiledMap {
		
		public static const SCENE_ID:String = "CombatMap";
		
		protected static const COMBAT_TILE_VARIATIONS:int = 5;
		
		protected var _mySquad:Squad;
		protected var _enemySquad:Squad;
		protected var _mySquadLand:Land;
		protected var _enemySquadLand:Land;
		protected var _combatLand:Land;
		
		protected var _factionToDestroy:Faction;
		
		protected var _combatMgr:CombatManager;
		
		public function CombatMap() {
			super();
			_combatMgr = new CombatManager(this);
			_combatMgr.addEventListener(CombatEvent.COMBAT_ENDED, onCombatEnded, false, 0, true);
			_entityPrefix = CombatGround.PREFIX;
		}
		
		protected function createCompatMapSpecs(gridSize:int):Array {
			var arr:Array = [];
			var total:int = Math.pow(gridSize, 2);
			for (var i:int = 0; i < total; i++) {
				arr.push(NumberUtil.randomInt(1, COMBAT_TILE_VARIATIONS));
			}
			return arr;
		}
		
		public function createCombatMap(mySquad:Squad, enemySquad:Squad, attacker:Faction, combatLand:Land, gridSize:int, tileW:int, tileH:int, offSetX:int = 0, offSetY:int = 0):void {
			_mySquad = mySquad;
			_enemySquad = enemySquad;
			_combatLand = combatLand;
			_mySquadLand = mySquad.parentEntity as Land;
			_enemySquadLand = enemySquad.parentEntity as Land; 
			createGrid(createCompatMapSpecs(gridSize), tileW, tileH, offSetX, offSetY);
			zoom(new CompassEvent(CompassEvent.ZOOM_MAP, 0, 0, Settings.zoom));
			_combatMgr.init(mySquad, enemySquad, attacker);
		}
		
		override public function clear():void {
			super.clear();
			_mySquad = null;
			_enemySquad = null;
			_combatLand = null;
			_gridSize = 0;
			_combatMgr.clear();
			
			//Here it must be destroyed for safety reasons
			//if (_factionToDestroy != null)
			//	_factionToDestroy.gameLost();
		}
		
		override protected function createTile(posX:int, posY:int, index:int):MapTile {
			var tile:CombatMapTile = new CombatMapTile(index, tileSpecs[index]);
			tile.width = tileWidth;
			tile.height = tileHeight;
			tile.x = posX;
			tile.y = posY;
			tile.scaleX = TiledMap.DECREASE_DIMENSION_MULT;
			tile.scaleY = TiledMap.DECREASE_DIMENSION_MULT;
			tile.mouseEnabled = false;
			tile.addEventListener(MapTileEvent.LIGHT_PATH, onLightPath, false, 0, true);
			tile.addEventListener(MapTileEvent.RESET_PATH, onResetPath, false, 0, true);
			tile.addEventListener(MapTileEvent.LIGHT_AREA, onLightArea, false, 0, true);
			tile.addEventListener(MapTileEvent.RESET_AREA, onResetArea, false, 0, true);
			tiles.push(tile);
			return tile;
		}
		
		override protected function transformTileNumbers():void {
			super.transformTileNumbers();
		}
				
		public function scrollToCombatGround(x:int, y:int):void {
			(EntityManager.getInstance().getEntityByID(entityPrefix + "_" + x + "_" + y) as CombatGround).combatMapTile.scrollToMe();
		}
		
		//EVENTS
		protected function scrollToChampion(e:CompassEvent):void {
			if (_mySquad.parentEntity == null) return;
			(_mySquad.parentEntity as CombatGround).combatMapTile.scrollToMe();
		}
		
		override protected function onMouseDown(e:MouseEvent):void {
			var tile:CombatMapTile = getFirstHitedTile() as CombatMapTile;
			if (tile != null)
				tileDown = tile;
		}
		
		override protected function onMouseUp(e:MouseEvent):void {
			var tile:CombatMapTile = getFirstHitedTile() as CombatMapTile;
			if (tileDown == tile && tileDown != null)
				tileDown.tileEntity.fireSelectedEvent(ActionView.COMBAT);
			tileDown = null;
		}
		
		protected function onCombatEnded(e:CombatEvent):void {
			
			//Afix squads and lands
			var winnerSquad:Squad = (_mySquad.faction == e.winner) ? _mySquad : _enemySquad;
			var _looserSquadPreviousLand:Land = (winnerSquad == _enemySquad) ? _mySquadLand : _enemySquadLand;
			//First looser, because looser's land might be combat land
			_looserSquadPreviousLand.squad = null;			
			winnerSquad.parentEntity = _combatLand;
			_combatLand.squad = winnerSquad;
			
			if (_combatLand.faction == e.looser) {
				//Citadel are not being aquiered
				if (_combatLand.structure is Citadel)
					e.looser.loosesGame = true;
				else {
					e.looser.removeActiveStructure(_combatLand.structure);
					e.looser.removeEntity(_combatLand.structure);
					e.winner.addEntity(_combatLand.structure);
					e.winner.addActiveStructure(_combatLand.structure);
				}
				e.looser.removeLand(_combatLand);
				e.winner.addLand(_combatLand);
			}
			dispatchEvent(new CombatMapEvent(CombatMapEvent.COMBAT_ENDED, null, e.winner, e.looser));
		}
		
		//GETTERS
		override public function get sceneID():String {return SCENE_ID;}
	}
}