package myriadLands.core
{
	import flash.display.StageDisplayState;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import myriadLands.faction.Faction;
	import myriadLands.net.NetInternal;
	
	use namespace NetInternal;
	
	public class Settings
	{
		public static const rotationPlanetSpeed:Number = 1;
		
		public static const WorldMapRoundTime:int = 60 * 10;
		public static const CombatMapRoundTime:int = 60 * 1000;
		
		public static const ACTION_EXECUTION_INTERVAL:int = 10;
		public static const RENDER_EXECUTION_INTERVAL:int = 50;
				
		public static const MOUSE_NAVIGATOR_SENSITIVITY:int = 10;
		public static var MAX_GRID_TILE_WIDTH:int = 30;
		//TWEENS
		public static const STRUCTURE_DESTRUCTION_DURATION:int = 4;//SAME AS DEMOLITION SOUND
		public static const STRUCTURE_DEPLOY_DURATION:int = 3;//SAME AS GATE SOUND
		public static const SHOW_PLAYER_GLOW_DURATION:int = 1;
		public static const SQUAD_GLOW_DURATION:int = 3;//SAME AS GATE SOUND
		public static const ENTITY_ON_GLOW_DURATION:int = 1;//SAME AS GATE ON COMBAT MAP SOUND
		//GUI
		public static const ENTITY_LIST_COUNT:int = 4;
		public static const ENTITY_LIST_ITEM_WIDTH:int = 60;
		//Network
		public static var loggedIn:Boolean = false;
		public static const HOST:String= "localhost";//"protractorgames.servegame.com";//
		public static const PORT:int = 62964;
		public static var player:Faction;
		protected static var _username:String;
		protected static var _password:String;
		public static function get username():String { return _username;}
		public static function get password():String { return _password;}
		NetInternal static function setUsername(value:String):void { _username = value;}		
		NetInternal static function setPassword(value:String):void { _password = value;}
		//SOUND
		public static var musicVolume:int = 0;
		public static var soundVolume:int = 0;
		public static var voiceOvers:Boolean = true;
		public static var MAX_CONCURRENT_VOICES:int = 10;		
		//SCREEN
		public static var zoom:Number = 0;
		public static var isFullScreen:Boolean = false;
		public static var screenWidth:int = 1024;
		public static var screenHeight:int = 768;
		//PATH
		public static const SETTINGS_FILE:String = "Settings.dat";
				
		public static function setFullScreen(value:Boolean):void {
			Settings.isFullScreen = value;
			if (!Settings.isFullScreen) {
				//FlexGlobals.topLevelApplication.maximize();
				//Settings.screenWidth = FlexGlobals.topLevelApplication.width;
				//Settings.screenHeight = FlexGlobals.topLevelApplication.height;
				FlexGlobals.topLevelApplication.width = Settings.screenWidth;
				FlexGlobals.topLevelApplication.height = Settings.screenHeight;
			} else {
				FlexGlobals.topLevelApplication.stage.nativeWindow.width = Settings.screenWidth;
				FlexGlobals.topLevelApplication.stage.nativeWindow.height = Settings.screenHeight;
				FlexGlobals.topLevelApplication.stage.stageWidth = Settings.screenWidth;
				FlexGlobals.topLevelApplication.stage.stageHeight = Settings.screenHeight;
			}
			FlexGlobals.topLevelApplication.stage.displayState = (Settings.isFullScreen) ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
		}
		//SAVE LOAD FUNCTIONS	
		public static function save():void {
			var stream:FileStream = new FileStream;
			var file:File =  File.applicationStorageDirectory.resolvePath(SETTINGS_FILE);
			file.nativePath;
			stream.open(file, FileMode.WRITE);
			//SOUND
			stream.writeInt(musicVolume);
			stream.writeInt(soundVolume);
			//SCREEN
			stream.writeBoolean(isFullScreen);
			stream.writeInt(screenWidth);
			stream.writeInt(screenHeight);
			stream.close();
		}
		public static function load():void {
			var file:File =  File.applicationStorageDirectory.resolvePath(SETTINGS_FILE);
			if (!file.exists)
				save();
			else {
				var stream:FileStream = new FileStream;
				stream.open(file, FileMode.READ);
				//SOUND
				Settings.musicVolume = stream.readInt();
				Settings.soundVolume = stream.readInt();
				//SCREEN
				Settings.isFullScreen = stream.readBoolean();
				Settings.screenWidth = stream.readInt();
				Settings.screenHeight = stream.readInt();
				stream.close();
			}			
		}
		public function Settings() {}
	}
}