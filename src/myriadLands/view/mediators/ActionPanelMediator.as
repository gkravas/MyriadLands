package myriadLands.view.mediators {
	
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	
	import flash.events.MouseEvent;
	
	import gamestone.events.ActionEvent;
	
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.events.FlexEvent;
	
	import myriadLands.actions.Action;
	import myriadLands.entities.Entity;
	import myriadLands.events.EntityEvent;
	import myriadLands.loaders.ActionLoader;
	import myriadLands.ui.buttons.ActionButton;
	import myriadLands.ui.contents.ActionWindowContent;
	import myriadLands.ui.css.MLFilters;
	
	import org.robotlegs.mvcs.Mediator;

	public class ActionPanelMediator extends Mediator {
		
		/*private const FULL_MENU_MODE:String = "fullMenuMode";
		private const QUICK_TAG_MODE:String = "quicktagMode";
		private const INVALID_MODE:String = "invalid";
		
		[Inject]
		public var view:ActionWindowContent;
		[Inject]
		public var actionLoader:ActionLoader;
		
		private var currentTween:TweenMax;
			
		private var currentEntity:Entity;
		private var selectedAction:Action;
		private var selectedQuickTagAction:Action;
			
		public function ActionPanelMediator() {
			super();
		}
		
		override public function onRegister():void {
			eventMap.mapListener(eventDispatcher, EntityEvent.SELECTED, populateWithAvailableAction, EntityEvent);
			eventMap.mapListener(view, FlexEvent.ENTER_STATE, stateChanged);
		}
		
		//EVENTS
		protected function populateWithAvailableAction(e:EntityEvent):void {
			setEntity(e.entity);
		}
		
		protected function stateChanged(e:FlexEvent):void {
			playCloseTween();
		}
		//TWEEN MOTION FUNCTIONALITY
		protected function playCloseTween():void {
			currentTween.pause();
			//We need to track only one tween, because all will end simultaniusly
			var t1:TweenMax = MLFilters.getPanelOpenCloseEffect(view.invalidActions, 0.5, 0);
			var t2:TweenMax = MLFilters.getPanelOpenCloseEffect(view.quickTagList, 0.5, 0);
			currentTween = MLFilters.getPanelOpenCloseEffect(view.actionList, 0.5, 0, populateWithAction);
			new TimelineMax({tweens:[t1, t2, currentTween], align:TweenAlign.START});
		}
		
		protected function populateWithAction():void {
			view.actionListGrid.addEventListener(FlexEvent.UPDATE_COMPLETE, playOpenTween, false, 0, true);
			populateWithActions();
		}
		
		protected function playOpenTween():void {
			view.actionListGrid.removeEventListener(FlexEvent.UPDATE_COMPLETE, playOpenTween);
			view.changeModeButton.setIconName(view.currentState + "-cur");
			switch (view.currentState) {
				case FULL_MENU_MODE:
					currentTween = MLFilters.getPanelOpenCloseEffect(view.actionList, 0.5, view.actionList.maxHeight);
				break;
				case QUICK_TAG_MODE:
					currentTween = MLFilters.getPanelOpenCloseEffect(view.quickTagList, 0.5, view.quickTagList.maxHeight);
				break;
				case INVALID_MODE:
					currentTween = MLFilters.getPanelOpenCloseEffect(view.invalidActions, 0.5, view.invalidActions.maxHeight);
				break;
			}
		}
		//END TWEENS
		
		private function populateWithActions():void {
			clearActionButtons();
			actionListGrid.removeAllChildren();
			if (currentEntity == null) return;
			var actions:Array = actionLoader.getAvailableActions(currentEntity, _currentView);
			actions = actions.concat(actionLoader.getAvailableAbilities(currentEntity, _currentView));
			var actionD:Action;
			
			for each (actionD in actions) {
				if (actionFilters.indexOf(actionD.data.type) == -1) continue;
				var aName:String = actionD.data.name
				var row:GridRow = new GridRow();
				var item:GridItem = new GridItem();
				var action:ActionButton = new ActionButton;
				item.addChild(action);
				row.addChild(item);
				actionListGrid.addChild(row);
				
				action.setAction(actionD);
				_d.registerLeemaBinding(action, "actionName", aName + "Name");
				actionButtons.push(action);
				if (quickTag1.getQuickTagActions().indexOf(aName) > -1)
					action.setQuickTagIcon(1);
				else if (quickTag2.getQuickTagActions().indexOf(aName) > -1)
					action.setQuickTagIcon(2);
				else if (quickTag3.getQuickTagActions().indexOf(aName) > -1)
					action.setQuickTagIcon(3);
				else
					action.setQuickTagIcon(0);
				action.addEventListener(MouseEvent.CLICK, actionButtonClicked, false, 0, true);
				action.addEventListener(ActionEvent.SELECTED, showToolTipAndCost, false, 0, true);
				action.addEventListener(ActionEvent.QUICK_TAG_CHANGED, actionQuickTagChanded, false, 0, true);
			}
		}
		
		private function clearActionButtons():void {
			view.actionListGrid.verticalScrollPosition = 0;
			var action:ActionButton;
			for each(action in actionButtons) {
				_d.unregisterLeemaBinding(action, "actionName", action.getAction().data.name+ "Name");
				action.getAction().markForDestroy();
			}
			actionButtons = [];
		}
			
		protected function setEntity(entity:Entity):void {
			//destroyActions();
			currentEntity = entity;
			//Land has no actions
			if (entity.availableActions.length == 0 && entity.availableAbilities.length == 0)
				setInvalid();
			else {
				setActionList();
			}
		}
		
		public function setInvalid():void {
			//actionListGrid.removeAllChildren();
			view.currentState = INVALID_MODE;
			changeModeButton.setIconName(mode + "-cur");
			playChangeModeTween();
		}
		
		private function setActionList():void {
			//populateWithActions();
			quickTag1.setActionList(currentEntity.availableActions.concat(currentEntity.availableAbilities));
			quickTag2.setActionList(currentEntity.availableActions.concat(currentEntity.availableAbilities));
			quickTag3.setActionList(currentEntity.availableActions.concat(currentEntity.availableAbilities));
			mode = FULL_MENU_MODE;
			changeModeButton.setIconName(mode + "-sym");
			playChangeModeTween();
		}*/
	}
}