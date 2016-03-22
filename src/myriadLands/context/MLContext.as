package myriadLands.context {
	
	import myriadLands.commands.CreateSelectLocationCommand;
	import myriadLands.commands.LoadingCommand;
	import myriadLands.commands.LoginCommand;
	import myriadLands.commands.StartGameCommand;
	import myriadLands.core.Settings;
	import myriadLands.entities.EntityManager;
	import myriadLands.events.ApplicationEvent;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.services.net.DarkstarService;
	import myriadLands.services.net.IGameServerService;
	import myriadLands.ui.asComponents.WorldMapTile;
	import myriadLands.ui.contents.ActionWindowContent;
	import myriadLands.view.mediators.ActionPanelMediator;
	
	import org.robotlegs.mvcs.Context;

	public class MLContext extends Context {
		
		public static const ENTITY_LOADER:String = "entityLoader";
		
		public function MLContext() {
			super();
		}
		
		//All the setup is being done here
		override public function startup():void {
			// Controller
			commandMap.mapEvent(ApplicationEvent.LOADING, LoadingCommand, ApplicationEvent);
			commandMap.mapEvent(ApplicationEvent.LOGIN, LoginCommand, ApplicationEvent);
			commandMap.mapEvent(ApplicationEvent.CREATE_SELECT_LOCATION, CreateSelectLocationCommand, ApplicationEvent);
			commandMap.mapEvent(ApplicationEvent.START_GAME, StartGameCommand, ApplicationEvent);
			// Model
			injector.mapSingleton(EntityLoader);
			injector.mapSingleton(EntityManager);
			injector.mapClass(WorldMapTile, WorldMapTile);
			
			// Services
			injector.mapSingletonOf(IGameServerService, DarkstarService);
			// View
			mediatorMap.mapView(ActionWindowContent, ActionPanelMediator);
			// Startup complete
			super.startup();
		}
		
	}
}