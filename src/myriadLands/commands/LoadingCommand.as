package myriadLands.commands {
	
	import flash.events.Event;
	
	import myriadLands.core.MainLoader;
	import myriadLands.events.ApplicationEvent;
	
	import org.robotlegs.mvcs.Command;

	public class LoadingCommand extends Command {
		
		public function LoadingCommand() {
			super();
		}
		
		override public function execute():void {
			var mainLoader:MainLoader = new MainLoader();
			mainLoader.addEventListener(Event.COMPLETE, loadingComplete);
			mainLoader.load();
		}
		
		protected function loadingComplete(e:Event):void {
			dispatch(new ApplicationEvent(ApplicationEvent.LOGIN));
		}
	}
}