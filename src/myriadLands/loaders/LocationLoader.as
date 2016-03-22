package myriadLands.loaders {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import gamestone.utils.XMLLoader;
	
	import myriadLands.Location.LocationData;
	
	public class LocationLoader extends XMLLoader {
		
		private static var _this:LocationLoader;
		
		private var locations:Object;
		private var locationNames:Array;
		
		public function LocationLoader(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("LocationLoader cannot be instantiated externally. LocationLoader.getInstance() method must be used instead.");
				return null;
			}
			locations = {};
			locationNames = [];
		}
		
		public static function getInstance():LocationLoader {
			if (LocationLoader._this == null)
				LocationLoader._this = new LocationLoader(new PrivateClass());
			return LocationLoader._this;
		}
		
		protected override function xmlLoaded(e:Event):void {
			var xml:XML = XML(xmlLoader.data);
			xmlLoader = null;
			
			var location:XML;
			
			for each(location in xml.location) {
				var lData:LocationData= new LocationData();
				lData.name = String(location.attribute("name"));
				lData.tileWidth = String(location.attribute("tileWidth")).split("-");
				lData.coords = String(location.attribute("coords")).split(",");
				lData.availableLandTypes = String(location.attribute("availableLandTypes")).split(",");
				lData.maxPlayers = String(location.attribute("maxPlayers")).split("-");
				
				locations[lData.name] = lData;
				locationNames.push(lData.name);
			}
			super.xmlLoaded(e);
		}
		
		public function getLocations():Object {
			return locations;
		}
		
		public function getLocation(name:String):LocationData {
			return locations[name];
		}
		
		public function getLocationNames():Array {
			return locationNames;
		}
	}
}
class PrivateClass {}