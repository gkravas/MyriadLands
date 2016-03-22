package myriadLands.core {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import gamestone.events.AssetLoaderEvent;
	import gamestone.graphics.ImgLoader;
	import gamestone.utils.AssetLoader;
	
	import myriadLands.loaders.ActionLoader;
	import myriadLands.loaders.EntityLoader;
	import myriadLands.loaders.LocationLoader;
	import myriadLands.parsers.DefaultImgParser;
	import myriadLands.parsers.IconsParser;
	import myriadLands.ui.panels.PlanetPanel;
		
	public class MainLoader extends EventDispatcher {
		
		public static const XML_FOLDER:String = "assets/xml/";
		public static const IMAGES_PATH:String = "assets/images/";
		public static const SOUNDS_PATH:String = "assets/sounds/";
		
		public static const IMAGES_XML:String = "images.xml";
		public static const ENTITIES_XML:String = "entities.xml";
		public static const FUNCTIONS_XML:String = "functions.xml";
		public static const DICTIONARY_XML:String = "dictionary.xml";
		public static const SOUNDS_XML:String = "sounds.xml";
		public static const LOCATIONS_XML:String = "locations.xml";
		public static const PROTOCOL_XML:String = "protocol.xml";		
		
		private var assetLoader:AssetLoader;
		//private var loadingPanel:LoadingPanel;
		private var imgLoader:ImgLoader;
		
		public function MainLoader() {
			imgLoader = ImgLoader.getInstance();
		}
		
		/*public function load():void {
			imgLoader.addEventListener(LoaderEvent.EXTERNAL_IMAGES_COMPLETE, initLoadingScreen);
			loadingPanel.loadImages();
		}
		
		protected function initLoadingScreen(e:LoaderEvent):void
		{
			imgLoader.removeEventListener(LoaderEvent.EXTERNAL_IMAGES_COMPLETE, initLoadingScreen);
			loadingPanel.init();
			init();
		}*/
		
		public function load():void {
			imgLoader.addManager("ML", new DefaultImgParser());
			imgLoader.addManager("icons", new IconsParser());
			//imgLoader.addEventListener(LoaderEvent.IMAGE_LOADED, updateProgress, false, 0 ,true);
			imgLoader.setPath(IMAGES_PATH);
			//ImgLoader.smoothing = true;
			ImgLoader.setDebug(ImgLoader.DEBUG_LEVEL_4);
			
			assetLoader = AssetLoader.getInstance();
			assetLoader.enableLoader(AssetLoader.DICTIONARY, XML_FOLDER + DICTIONARY_XML);
			
			assetLoader.addLoader(LocationLoader.getInstance(), XML_FOLDER + LOCATIONS_XML);
			assetLoader.addLoader(ActionLoader.getInstance(), XML_FOLDER + FUNCTIONS_XML);
			assetLoader.addLoader(EntityLoader.getInstance(), XML_FOLDER + ENTITIES_XML);
			
			assetLoader.addLoader(imgLoader, XML_FOLDER + IMAGES_XML);
			//assetLoader.enableLoader(AssetLoader.NETWORK, XML_FOLDER + PROTOCOL_XML);
			assetLoader.enableLoader(AssetLoader.SOUNDS, XML_FOLDER + SOUNDS_XML);
			assetLoader.addEventListener(AssetLoaderEvent.ASSET_LOADING_COMPLETE, assetsLoaded);
			assetLoader.load();	
		}
		
		protected function assetsLoaded(event:Event):void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/*protected function updateProgress(e:LoaderEvent):void
		{
			loadingPanel.setProgress(e.current , e.total)
		}*/
	}
	
}