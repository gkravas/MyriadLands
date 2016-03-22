package myriadLands.fx
{
	import away3d.cameras.TargetCamera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Plane;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
	import gamestone.display.MySprite;
	import gamestone.graphics.ImgLoader;
	import gamestone.graphics.RGB;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	
	import myriadLands.ui.asComponents.CombatMap;
	import myriadLands.ui.asComponents.WorldMap;
	import myriadLands.ui.css.MLFilters;
	
	public class FXManagerOld {
		
		public static const ICON_SCALE:Number = 1;//0.4;
		protected static const ROTATION_SPEED:Number = 2.5;
		
		protected static  var _this:FXManagerOld;
		
		protected var imgLoader:ImgLoader;
		
		protected var registeredScenes:Object;
		
		public function FXManagerOld(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("FXManager cannot be instantiated externally. FXManager.getInstance() method must be used instead.");
				return null;
			}
			imgLoader = ImgLoader.getInstance(); 
			registeredScenes = {};
		}
		
		public static function getInstance():FXManagerOld
		{
			if (FXManagerOld._this == null)
				FXManagerOld._this = new FXManagerOld(new PrivateClass());
			return FXManagerOld._this;
		}
		
		public static function destroyInstance():void {			
			FXManagerOld._this = null;
		}
		
		public function registerScene(parent:Canvas, id:String):void {
			if (registeredScenes.hasOwnProperty(id)) 
				throw new Error("FXManager: Scene with ID: " + id + " already exists");
			parent.id = id;
			registeredScenes[parent.id] = {parent:parent, objects:[]};
			parent.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void {			
			/*var parent:Canvas = e.currentTarget as Canvas;
			var objects:Object = getObjectsByID(parent.id);
			if (objects.length == 0) return;
			var icon:Image;
			for each(icon in objects)
				rotateOnCenterY(icon);*/
			//SimpleZSorter.sortClips(parent);
		}
		
		protected static function rotateOnCenterY(e:Event):void {
			var icon:Image = e.currentTarget as Image;
			icon.rotationY += ROTATION_SPEED;
			/*icon.transform.matrix3D.prependTranslation(icon.width * 0.5, icon.height * 0.5, 0);
			icon.transform.matrix3D.prependRotation(ROTATION_SPEED, Vector3D.Y_AXIS);
			icon.transform.matrix3D.prependTranslation(-icon.width * 0.5, -icon.height * 0.5, 0);*/
		}
		
		public function scrollTo2D(id:String, x:int, y:int):void {
			//var view3D:View3D =  getView3DByID(id);
			//view3D.camera.x = x * view3D.scene.scaleX;
			//view3D.camera.y = y * view3D.scene.scaleY;
			//var uic:UIComponent = getParentByID(id);
		}
		
		public function zoomTo2D(id:String, zoomMult:Number, x:int, y:int, sWidth:int, sHeight:int):void {
			//var view3D:View3D =  getView3DByID(id);			
			//view3D.scene.scale(zoomMult);
			//var uic:UIComponent = getParentByID(id);
		}
		
		/**
		 * Adds a plane with an icon to FXScene
		 */		
		protected function addIconPlane(sceneID:String, ba:BitmapAsset, position:Point, color:uint, scale:Number):Image {
			//var view3D:View3D =  getView3DByID(sceneID);
			
			var plane:Image = new Image();
			plane.source = ba;
			ba.transform.colorTransform =  MySprite.getColorTransformFromRGB(RGB.hex2rgb(color), new RGB(0, 0, 0));
			plane.scaleX = scale;
			plane.scaleY = scale;
			//plane.scaleZ = scale;
			(getParentByID(sceneID) as Canvas).addChild(plane);
			plane.x = position.x - ba.width * 0.5;
			plane.y = position.y;
			plane.z = 0;
			var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.fieldOfView = 1;
			pp.projectionCenter = new Point();
			plane.transform.perspectiveProjection = pp;
			//plane.addEventListener(Event.ENTER_FRAME, rotateOnCenterY, false, 0, true);
			getObjectsByID(sceneID).push(plane);
			return plane;
		}
		
		public static function addIconPlaneEX(parent:View3D, iconName:String, position:Point, color:uint, scale:Number):Plane {
			var ba:BitmapAsset = ImgLoader.getInstance().getBitmapAsset(iconName);
			
			var plane:Plane = new Plane({width:ba.width, height:ba.height, segmentsW:3,segmentsH:3});
			plane.extra = {};
			plane.material = new BitmapMaterial(ba.bitmapData, {color:color});
			plane.centerPivot();
			plane.bothsides = true;
			plane.rotationX = 90;
			plane.scaleX = scale;
			plane.scaleY = scale;
			plane.scaleZ = scale;
			parent.scene.addChild(plane);
			plane.x = position.x;
			plane.y = position.y;
			
			(parent.camera as TargetCamera3D).target = plane;
			parent.camera.z = - 1;
			parent.render();
			return plane;
		}
		protected function removeIconPlane(sceneID:String, index:int):void {
			var arr:Array = getObjectsByID(sceneID);
			(getParentByID(sceneID) as Canvas).removeChild(arr[index]);
			arr[index] = null;
			clearSceneObjectsArray(sceneID);
		}
		
		public static function removeIconPlaneEX(parent:View3D, icon:Plane):void {
			icon.removeEventListener(Event.ENTER_FRAME, rotateOnCenterY, false);
			parent.scene.addChild(icon);
		}
		
		protected function clearSceneObjectsArray(sceneID:String):void {
			var arr:Array = getObjectsByID(sceneID);
			var o:Object;
			for each (o in arr) {
				if (o != null)
					return;
			}
			setObjectsOfScene(sceneID, []);
		}
		
		//For the WorldMap
		public function addWorldMapActionIconPlane(iconName:String, position:Point, scale:Number = FXManagerOld.ICON_SCALE):int {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(WorldMap.SCENE_ID)) return -1;
			var plane:Image = addIconPlane(WorldMap.SCENE_ID, imgLoader.getBitmapAsset(iconName), position, MLFilters.ORANGE, scale);
			//makeRotationY(plane, 3, 360, -1);
			return getObjectsByID(WorldMap.SCENE_ID).indexOf(plane);
		}
		public function removeWorldMapActionIconPlane(index:int):void {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(WorldMap.SCENE_ID)) return;
			if ((getObjectsByID(WorldMap.SCENE_ID)[index] as Image) == null) return;
			//(getObjectsByID(WorldMap.SCENE_ID)[index] as UIComponent).extra.tween = null;
			removeIconPlane(WorldMap.SCENE_ID, index);
		}
		
		//For the CombatMap
		public function addCombatMapActionIconPlane(iconName:String, position:Point, scale:Number = FXManagerOld.ICON_SCALE):int {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(CombatMap.SCENE_ID)) return -1;
			var plane:Image = addIconPlane(CombatMap.SCENE_ID, imgLoader.getBitmapAsset(iconName), position, MLFilters.ORANGE, scale);
			//makeRotationY(plane, 3, 360, -1);
			return getObjectsByID(CombatMap.SCENE_ID).indexOf(plane);
		}
		
		public function removeCombatMapActionIconPlane(index:int):void {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(CombatMap.SCENE_ID)) return;
			if ((getObjectsByID(CombatMap.SCENE_ID)[index] as Image) == null) return;
			//(getObjectsByID(CombatMap.SCENE_ID)[index] as UIComponent).extra.tween = null;
			removeIconPlane(CombatMap.SCENE_ID, index);
		}
		
		protected function makeRotationY(obj:Object3D, duration:int, degrees:int, loops:int):void {
			obj.extra.tween = MLFilters.getRotationIconTween(obj, duration, degrees, loops);
		}
		
		//HELPING FUNCTIONS
		protected function checkRegisteredScene(id:String):Boolean {
			if (!registeredScenes.hasOwnProperty(id)) 
				throw new Error("FXManager: Scene with ID: " + id + " does not exist.");
			return true;
		}
		protected function setObjectsOfScene(id:String, arr:Array):void {
			checkRegisteredScene(id);
			registeredScenes[id].objects = [];
		}
		protected function getObjectsByID(id:String):Array {
			checkRegisteredScene(id);
			return registeredScenes[id].objects as Array;
		}
		protected function getParentByID(id:String):Canvas {
			checkRegisteredScene(id);
			return registeredScenes[id].parent as Canvas;
		}

	}
}class PrivateClass {}