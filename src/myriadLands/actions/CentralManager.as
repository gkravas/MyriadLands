package myriadLands.actions {
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import gamestone.utils.DebugX;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.ToolTipEvent;
	import mx.managers.PopUpManager;
	
	import myriadLands.core.GameHelperClass;
	import myriadLands.core.Settings;
	import myriadLands.entities.Champion;
	import myriadLands.entities.CombatGround;
	import myriadLands.entities.EntityInternal;
	import myriadLands.entities.Land;
	import myriadLands.entities.Squad;
	import myriadLands.events.ActionEvent;
	import myriadLands.events.CentralManagerEvent;
	import myriadLands.events.CombatMapEvent;
	import myriadLands.events.CompassEvent;
	import myriadLands.events.EntityEvent;
	import myriadLands.events.FactionEvent;
	import myriadLands.events.GameEvent;
	import myriadLands.events.LandEvent;
	import myriadLands.events.MainMenuEvent;
	import myriadLands.events.NetworkEvent;
	import myriadLands.events.WorldMapEvent;
	import myriadLands.faction.Faction;
	import myriadLands.fx.FXManagerOld;
	import myriadLands.net.MLProtocol;
	import myriadLands.net.NetworkManager;
	import myriadLands.ui.MLWindow;
	import myriadLands.ui.asComponents.CombatMap;
	import myriadLands.ui.asComponents.CombatMapTile;
	import myriadLands.ui.asComponents.WorldMap;
	import myriadLands.ui.contents.*;
	import myriadLands.ui.panels.BattleWaitingPanel;
	import myriadLands.ui.panels.BattlefieldGameEndPanel;
	import myriadLands.ui.panels.ChatPanel;
	import myriadLands.ui.panels.DebugPanel;
	
	//use namespace LoginInternal;
	
	public class CentralManager extends EventDispatcher
	{		
		private static var _this:CentralManager;
		
		protected var _mapView:String;
		protected var _worldMap:WorldMap;
		protected var _combatMap:CombatMap;
		
		protected var _selectionWorldMapPanel:SelectionWorldMapWindowContent;
		protected var _attributePanel:AttributeWindowContent;
		protected var _actionPanel:ActionWindowContent;
		protected var _compassPanel:CompassPanel;
		protected var _toolTipPanel:ShoutBoxWindowContent;
		protected var _assetPanel:AssetWindowsContent;
		protected var _productionPanel:ProductionWindowContent;
		protected var _mainMenuPanel:MenuWindowContent;
		protected var _musicPanel:MusicWindowContent;
		protected var _gatePanel:GateWindowContent;
		protected var _resourcePanel:ResourcesWindowContent;
		protected var _selectionCombatPanel:SelectionCombatMapWindowContent;
		protected var _aliancePanel:AlianceWindowContent;
		
		private var battleWaitingPanel:IFlexDisplayObject;
		
		protected var netM:NetworkManager;
		protected var am:ActionManager;
		
		//protected var _gameTimer:Timer;
		
		protected var _gameOverFunction:Function;
		
		protected var worldMapTiles:Array; 
		
		public function CentralManager(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("CentralManager cannot be instantiated externally. CentralManager.getInstance() method must be used instead.");
				return null;
			}
			//_gameTimer = new Timer(Settings.WorldMapRoundTime);
			am = ActionManager.getInstance();
		}
		
		public static function getInstance():CentralManager {
			if (CentralManager._this == null)
				CentralManager._this = new CentralManager(new PrivateClass());
			return CentralManager._this;
		}
		
		public static function destroyInstance():void {			
			CentralManager._this = null;
			FXManagerOld.destroyInstance();
		}
		
		public function init(worldMap:WorldMap, combatMap:CombatMap, compassPanel:CompassPanel, selectionPanel:SelectionWorldMapWindowContent,
							toolTipPanel:ShoutBoxWindowContent, attributePanel:AttributeWindowContent, actionPanel:ActionWindowContent,
							assetPanel:AssetWindowsContent, productionPanel:ProductionWindowContent, mainMenuPanel:MenuWindowContent,
							musicPanel:MusicWindowContent, gatePanel:GateWindowContent, resourcePanel:ResourcesWindowContent,
							selectionCombatPanel:SelectionCombatMapWindowContent, aliancePanel:AlianceWindowContent):void {
			this._worldMap = worldMap;
			this._combatMap = combatMap;
			this._selectionWorldMapPanel = selectionPanel;
			this._attributePanel = attributePanel;
			this._actionPanel = actionPanel;
			this._compassPanel = compassPanel;
			this._toolTipPanel = toolTipPanel;
			this._assetPanel = assetPanel;
			this._productionPanel = productionPanel;
			this._mainMenuPanel = mainMenuPanel;
			this._musicPanel = musicPanel;
			this._gatePanel = gatePanel;
			this._resourcePanel = resourcePanel;
			this._selectionCombatPanel = selectionCombatPanel;
			this._aliancePanel = aliancePanel;
			
			_compassPanel.addEventListener(CompassEvent.SCROLL_WORLD_MAP, _worldMap.scrollTo, false, 0, true);
			_compassPanel.addEventListener(CompassEvent.SCROLL_TO_CITADEL_LAND, _worldMap.scrollToCitadelLand, false, 0, true);
			_compassPanel.addEventListener(CompassEvent.SCROLL_COMBAT_MAP, _combatMap.scrollTo, false, 0, true);
			_compassPanel.addEventListener(CompassEvent.SCROLL_TO_CITADEL_LAND, _combatMap.scrollToCitadelLand, false, 0, true);
			_compassPanel.addEventListener(CompassEvent.ZOOM_MAP, _worldMap.zoom, false, 0, true);
			_compassPanel.addEventListener(CompassEvent.ZOOM_MAP, _combatMap.zoom, false, 0, true);
			
			
			_worldMap.addEventListener(WorldMapEvent.LAND_TILE_CONSTRUCTED,_selectionWorldMapPanel.newLandConstructed, false, 0, true);
			_combatMap.addEventListener(CombatMapEvent.COMBAT_ENDED, combatEnded, false, 0, true);
			
			_mainMenuPanel.addEventListener(MainMenuEvent.TOGGLE_FLOATER_VISIBILITY, showHideFloater, false, 0, true);
			//onResourceTime_gameTimer.addEventListener(TimerEvent.TIMER, onResourceTime, false, 0, true);
						
			netM = NetworkManager.getInstance();
			netM.addEventListener(NetworkEvent.INIT_MAP, initBattlefield);
			netM.addEventListener(NetworkEvent.NETWORK_ACTION_RECEIVED, am.executeNetworkAction);
			netM.addEventListener(NetworkEvent.START_BATTLEFIELD_GAME, startBattlefieldGame);
			netM.addEventListener(NetworkEvent.BATTLEFIELD_CYCLE, onBattlefieldCycle);
		}
		
		protected function initBattlefield(e:NetworkEvent ):void {
			worldMapTiles = e.message.toString().split(",");
			mapView = ActionView.WORLD_MAP;
			_worldMap.createGrid(worldMapTiles, 500, 550, 270, 100);
		}
		
		//When connected to a location and received the map, this function will be executed.
		public function prepareBattlefieldGame(e:GameEvent):void {
			//mapView = ActionView.WORLD_MAP;
			//_worldMap.createGrid(worldMapTiles, 500, 550, 270, 100);
			//For testing inly
			//BattleScenario.worldMapCreated = true;
			//To message handler for the battle scenario
			//dispatchEvent(new Event(Event.COMPLETE));
			_compassPanel.zoomMap();
			ChatPanel.hide();
			battleWaitingPanel = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.root, BattleWaitingPanel, true);
			PopUpManager.centerPopUp(battleWaitingPanel);
			NetworkManager.getInstance().addEventListener(NetworkEvent.UPDATE_BATTLE_WAITING_PANEL, (battleWaitingPanel as BattleWaitingPanel).playerIsReady);
			var currentBattlefieldData:Object = GameHelperClass.currentBattlefield;
			(battleWaitingPanel as BattleWaitingPanel).initText(currentBattlefieldData.playersIn,
																currentBattlefieldData.maxPlayers,
																currentBattlefieldData.readyPlayers);
		}
		
		protected function startBattlefieldGame(e:NetworkEvent):void {
			var players:Array = netM.getFactions();
			var player:Faction;
			for each(player in players)
				player.citadel.engageAbilitiesEX();
			//_gameTimer.start();
			netM.removeEventListener(NetworkEvent.UPDATE_BATTLE_WAITING_PANEL, (battleWaitingPanel as BattleWaitingPanel).playerIsReady);
			PopUpManager.removePopUp(battleWaitingPanel);
			battleWaitingPanel = null;
		}
		
		public function initCombatMap(e:LandEvent):void {
			mapView = ActionView.COMBAT;
			_combatMap.createCombatMap(e.mySquad, e.enemySquad, e.attacker, e.combatLand, e.gridSize, 500, 550, 270, 100);
			_selectionCombatPanel.setSquad(e.mySquad);
			_actionPanel.setEntity(e.mySquad);
			//Player who is being attacked goes left
			//the other goes right
			var playerSquad:Squad;
			if (e.mySquad == e.combatLand.squad) {
				e.mySquad.faction.combatGroundBase = (_combatMap.getMapTile(1, _combatMap.gridWidth) as CombatMapTile).combatGround;
				e.enemySquad.faction.combatGroundBase = (_combatMap.getMapTile(_combatMap.gridWidth, 1) as CombatMapTile).combatGround;
				_combatMap.scrollToMapTile(e.mySquad.faction.combatGroundBase.mapTile);
			} else {
				e.mySquad.faction.combatGroundBase = (_combatMap.getMapTile(_combatMap.gridWidth, 1) as CombatMapTile).combatGround;
				e.enemySquad.faction.combatGroundBase = (_combatMap.getMapTile(1, _combatMap.gridWidth) as CombatMapTile).combatGround;
				_combatMap.scrollToMapTile(e.mySquad.faction.combatGroundBase.mapTile);
			}
			_compassPanel.zoomMap();
		}
		
		public function makeResourceBindings(player:Faction):void {
			_resourcePanel.makeBindings(player);
		}
		
		EntityInternal function entitySelected(e:EntityEvent):void {
			if (e.view == ActionView.SELECTION_PANEL) {
				_toolTipPanel.setEntity(e.entity);
				//For lands not conquared yet
				if (e.entity.faction != null)
					if (!e.entity.faction.isPlayer) return;
				_attributePanel.setEntity(e.entity);
				_actionPanel.setEntity(e.entity);
				resetGatePanel(null);
				resetPorductionPanel(null);
			} else if (e.view == ActionView.WORLD_MAP) {
				//engage function with sacrifice required
				if (!am.actionSelectedAndRequiersInput()) {
					_selectionWorldMapPanel.setLandTile(e.entity as Land);
				}
			} else if (e.view == ActionView.COMBAT) {
				//engage function with sacrifice required
				if (!am.actionSelectedAndRequiersInput()) {
					if (!(e.entity is CombatGround)) {
						_actionPanel.setEntity(e.entity);
						_attributePanel.setEntity(e.entity);
						_toolTipPanel.setText(e.entity.name + "Info");
					}
				}
			}
		}
		
		ActionInternal function updateDynamicCost(e:ActionEvent):void {
			_actionPanel.updateDynamicCost(e.action.calcultateDynamicCost());
		}
		
		ActionInternal function actionExecutionSuccess(e:ActionEvent):void {
			_actionPanel.resetSelectedAction();
			_actionPanel.clearAttributes();
		}
		
		ActionInternal function actionEngage(e:ActionEvent):void {
			_actionPanel.resetSelectedAction();
		}
				
		ActionInternal function actionSelected(e:ActionEvent):void {
			_toolTipPanel.setAction(e.action);
		}
		
		ActionInternal function actionCanceled(e:ActionEvent):void {
			_actionPanel.resetSelectedAction();
		}
		
		ActionInternal function actionFailedForMalus(e:ActionEvent):void {
			DebugX.MyTrace(e.action.data.name + " failed for malus");
		}
		
		public function setToolTipHandler(comp:UIComponent):void {
			comp.addEventListener(ToolTipEvent.TOOL_TIP_SHOW, onToolTipShow, false, 0, true);
			comp.addEventListener(ToolTipEvent.TOOL_TIP_HIDE, onToolTipHide, false, 0, true);
		}
		
		//PRODUCTION PANEL
		public function populateProductionPanel(e:ActionEvent):void {
			_productionPanel.setAction(e.action as ProductionAction);
		}
		
		public function resetPorductionPanel(e:ActionEvent):void {
			_productionPanel.reset();
		}
		
		//GATE PANEL
		public function populateGatePanel(e:ActionEvent):void {
			_gatePanel.setAction(e.action as GateAction);
		}
		
		public function resetGatePanel(e:ActionEvent):void {
			_gatePanel.reset();
		}
		
		//COMBAT MAP PANEL
		public function populateCombatMapSelectionPanel(c:Champion):void {
			_selectionCombatPanel.setSquad(c);
		}
						
		private function showHideFloater(e:MainMenuEvent):void {
			var floater:String =  e.floater;
			var win:MLWindow;
			switch (floater) {
				case "selectionFloater":
					if (mapView == ActionView.WORLD_MAP)
						win = _selectionWorldMapPanel.parent as MLWindow;
					else if (mapView == ActionView.COMBAT)
						win = _selectionCombatPanel.parent as MLWindow; 
				break;
				case "actionFloater":
					win = _actionPanel.parent as MLWindow;
				break;
				case "attributeFloater":
					win = _attributePanel.parent as MLWindow;
				break;
				case "productionFloater":
					if (mapView == ActionView.COMBAT) return;
					win = _productionPanel.parent as MLWindow;
				break;
				case "gateFloater":
					if (mapView == ActionView.COMBAT) return;
					win = _gatePanel.parent as MLWindow;
				break;
				case "resourceFloater":
					if (mapView == ActionView.COMBAT) return;
					win = _resourcePanel.parent as MLWindow;
				break;
				case "assetFloater":
					if (mapView == ActionView.COMBAT) return;
					win = _assetPanel.parent as MLWindow;
				break;
				case "compassFloater":
					win = _compassPanel.parent as MLWindow;
				break;
				case "shoutboxFloater":
					win = _toolTipPanel.parent as MLWindow;
				break;
				case "musicFloater":
					win = _musicPanel.parent as MLWindow;
				break;
				case "exit":
					NetworkManager.getInstance().sendMessage(MLProtocol.PLAYER_REQUEST_LEAVE_BATTLEFIELD,
															{reason:MLProtocol.PLAYER_GAVE_UP_BATTLE});
					factionLost(Settings.player);
				break;
				case "newGame":
					DebugPanel.show();
				break;
				case "forum":
					win = _aliancePanel.parent as MLWindow;
					_aliancePanel.populate();
				break;
			}
			if (win != null && !win.isVisible())
				win.show();
		}
		
		//TOOL TIP
		private function onToolTipShow(e:ToolTipEvent):void {
			e.toolTip.alpha = 0;
			if (_toolTipPanel == null) return;
			_toolTipPanel.setUIComponent(e.currentTarget as UIComponent);
		}
		
		private function onToolTipHide(e:ToolTipEvent):void {
			if (_toolTipPanel == null) return;
			_toolTipPanel.showPreviousToolTip();
		}
		
		//SETTERS
		public function setGameOverFunction(f:Function):void {
			_gameOverFunction = f;
		}
		
		public function set mapView(v:String):void {
			_mapView = v;
			_actionPanel.currentView = _mapView;
			_compassPanel.currentView = _mapView;
			_attributePanel.currentView = _mapView;
			if (_mapView == ActionView.WORLD_MAP) {
				(_productionPanel.parent as MLWindow).show();
				(_gatePanel.parent as MLWindow).show();
				(_productionPanel.parent as MLWindow).show();
				(_resourcePanel.parent as MLWindow).show();
				(_assetPanel.parent as MLWindow).show();
				(_selectionWorldMapPanel.parent as MLWindow).show();
				(_selectionCombatPanel.parent as MLWindow).hide();
				_worldMap.visible = true;
				_combatMap.visible = false;
			} else if (_mapView == ActionView.COMBAT) {
				(_productionPanel.parent as MLWindow).hide();
				(_gatePanel.parent as MLWindow).hide();
				(_productionPanel.parent as MLWindow).hide();
				(_resourcePanel.parent as MLWindow).hide();
				(_assetPanel.parent as MLWindow).hide();
				(_selectionWorldMapPanel.parent as MLWindow).hide();
				(_selectionCombatPanel.parent as MLWindow).show();
				_worldMap.visible = false;
				_combatMap.visible = true;
			} 
		}			
		//GETTERS
		public function get mapView():String {return _mapView;}
		
		
		//EVENTS
		/*private function onLocalActionSuccess(e:ActionEvent):void {
			netM.sendActionMessage(e.action);
			_actionPanel.clearAttributes();
			_actionPanel.resetSelectedAction();
		}*/
		
		private function onBattlefieldCycle(e:NetworkEvent):void {
			dispatchEvent(new CentralManagerEvent(CentralManagerEvent.CYCLE_PASSED));
		}
		
		private function combatEnded(e:CombatMapEvent):void {
			_combatMap.clear();
			mapView = ActionView.WORLD_MAP;
			if (e.looser.loosesGame) {
				factionLost(e.looser);
			}
		}
		
		EntityInternal function entityUpdated(e:EntityEvent):void {
			if (e.attirbutesUpdated) {
				if (_attributePanel.getEntity() == e.entity)
					_attributePanel.updateEntity();
			}
			if (e.actionsUpdated) {
				if (_actionPanel.getEntity() == e.entity)
					_actionPanel.setEntity(e.entity);
			}
			if (e.contentUpdated) {
				if (mapView == ActionView.WORLD_MAP) {
					var land:Land = (!e.entity is Land) ? e.entity.parentEntity as Land : e.entity as Land;
					if (_selectionWorldMapPanel.getLandTile() != land)
						return;
					else
						_selectionWorldMapPanel.setLandTile(land);
				}
			}
		}
		
		public function factionUpdated(e:FactionEvent):void {
			var faction:Faction = e.faction;
			if (faction.isPlayer) {
				switch (e.type) {
					case FactionEvent.ENTITY_ADDED_TO_INVENTORY:
						_assetPanel.addToInventory(e.entity);
					break;
					case FactionEvent.ENTITY_REMOVED_FROM_INVENTORY:
						_assetPanel.removeFromInventory(e.entity);
					break;
					case FactionEvent.ENTITY_ADDED_TO_VAULT:
						_assetPanel.addToVault(e.entity);
					break;
					case FactionEvent.ENTITY_REMOVED_FROM_VAULT:
						_assetPanel.removeFromVault(e.entity);
					break;
					case FactionEvent.ENTITY_ADDED_TO_EXPORT:
						_assetPanel.addToExport(e.entity);
					break;
					case FactionEvent.ENTITY_REMOVED_FROM_EXPORT:
						_assetPanel.removeFromExport(e.entity);
					break;
					case FactionEvent.ENTITY_ADDED_TO_IMPORT:
						_assetPanel.addToImport(e.entity);
					break;
					case FactionEvent.ENTITY_REMOVED_FROM_IMPORT:
						_assetPanel.removeFromImport(e.entity);
					break;
					case FactionEvent.MAX_PRESERVED_ENTITIES_CHANGED:
						_assetPanel.setMaxPreservedEntities(e.faction.maxPreservedEntities);
					break;
					case FactionEvent.FACTION_LOST:
						factionLost(e.faction);
					break;
				}
			} else {
				switch (e.type) {
					case FactionEvent.ENTITY_REMOVED_FROM_IMPORT:
						_assetPanel.removeFromImport(e.entity);
					break;
					case FactionEvent.FACTION_LOST:
						factionLost(e.faction);
					break;
				}
			}
		}
		
		protected function factionLost(f:Faction):void {
			f.destroy();
			if (f == Settings.player) {
				//_gameTimer.stop();
				BattlefieldGameEndPanel.show(_gameOverFunction, true, MLProtocol.PLAYER_LOST_BATTLE);
			} else {
				if (netM.getFactionsNum() == 1 && netM.getFactionPlayer() != null)
					BattlefieldGameEndPanel.show(_gameOverFunction, false);
			}
		}
	}
}
class PrivateClass {}