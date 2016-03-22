package myriadLands.events {
	
	import flash.events.Event;

	public class ApplicationEvent extends Event {
		
		public static const PRE_INITIALIZATION:String = "preInitialization";
		public static const LOADING:String = "loading";
		public static const LOGIN:String = "login";
		public static const CREATE_SELECT_LOCATION:String = "createSelectLocation";
		public static const START_GAME:String = "startGame";
		public static const GAME_OVER:String = "gameOver";
		
		public function ApplicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}
}