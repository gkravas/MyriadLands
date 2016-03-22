package myriadLands.fx
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.math.Number3D;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Plane;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.Point;
	
	import gamestone.graphics.ImgLoader;
	
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
	import myriadLands.ui.asComponents.CombatMap;
	import myriadLands.ui.asComponents.WorldMap;
	import myriadLands.ui.css.MLFilters;
	
	public class FXManager {
		
		public static const ICON_SCALE:Number = 1;//0.4;
		
		protected static  var _this:FXManager;
		
		protected var imgLoader:ImgLoader;
		
		protected var registeredScenes:Object;
		
		public function FXManager(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("FXManager cannot be instantiated externally. FXManager.getInstance() method must be used instead.");
				return null;
			}
			imgLoader = ImgLoader.getInstance(); 
			registeredScenes = {};
		}
		
		public static function getInstance():FXManager
		{
			if (FXManager._this == null)
				FXManager._this = new FXManager(new PrivateClass());
			return FXManager._this;
		}
		
		public static function destroyInstance():void {			
			FXManager._this = null;
		}
		
		public function registerScene(parent:IFXAble, id:String):void {
			if (registeredScenes.hasOwnProperty(id)) 
				throw new Error("FXManager: Scene with ID: " + id + " already exists");
			var view3D:View3D = new View3D();
			registeredScenes[id] = {scene:parent, view3D:view3D, objects:[]};
			var par:UIComponent = parent as UIComponent; 
			par.addChild(view3D);
			par.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			view3D.camera.lookAt(new Number3D(0, 0, 0));
		}
		
		private function onEnterFrame(e:Event):void {			
			var parent:IFXAble = e.currentTarget as IFXAble;
			var objects:Object = getObjectsByID(parent.sceneID);
			if (objects.length == 0) return;
			var view3D:View3D =  getView3DByID(parent.sceneID);
			view3D.render();				
		}
		
		public function scrollTo2D(id:String, x:int, y:int):void {
			var view3D:View3D =  getView3DByID(id);
			view3D.camera.x = x * view3D.scene.scaleX;
			view3D.camera.y = y * view3D.scene.scaleY;
		}
		
		public function zoomTo2D(id:String, zoomMult:Number, x:int, y:int, sWidth:int, sHeight:int):void {
			var view3D:View3D =  getView3DByID(id);			
			view3D.scene.scale(zoomMult);
		}
		
		/**
		 * Adds a plane with an icon to FXScene
		 */		
		public function addIconPlane(sceneID:String, ba:BitmapAsset, position:Point, color:uint, scale:Number):Plane {
			var view3D:View3D =  getView3DByID(sceneID);
			
			var plane:Plane = new Plane({width:ba.width, height:ba.height, segmentsW:3,segmentsH:3});
			plane.extra = {};
			plane.material = new BitmapMaterial(ba.bitmapData, {color:color});
			plane.centerPivot();
			plane.bothsides = true;
			plane.rotationX = 90;
			plane.scaleX = scale;
			plane.scaleY = scale;
			plane.scaleZ = scale;
			getView3DByID(sceneID).scene.addChild(plane);
			plane.x = position.x;
			plane.y = position.y;
			getObjectsByID(sceneID).push(plane);
			return plane;
		}
		
		public function removeIconPlane(sceneID:String, index:int):void {
			var arr:Array = getObjectsByID(sceneID);
			getView3DByID(sceneID).scene.removeChild(arr[index]);
			//For rerendering, so removed objects disapear
			getView3DByID(sceneID).render();
			arr[index] = null;
		}
		
		protected function clearSceneObjectsArray(sceneID:String):void {
			var arr:Array = getObjectsByID(sceneID);
			var o:Object;
			for each (o in arr) {
				if (o != null)
					return;
			}
			arr = [];
		}
		
		//For the WorldMap
		public function addWorldMapActionIconPlane(iconName:String, position:Point, scale:Number = FXManager.ICON_SCALE):int {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(WorldMap.SCENE_ID)) return -1;
			var plane:Plane = addIconPlane(WorldMap.SCENE_ID, imgLoader.getBitmapAsset(iconName), position, MLFilters.ORANGE, scale);
			makeRotationY(plane, 3, 360, -1);
			return getObjectsByID(WorldMap.SCENE_ID).indexOf(plane);
		}
		public function removeWorldMapActionIconPlane(index:int):void {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(WorldMap.SCENE_ID)) return;
			if ((getObjectsByID(WorldMap.SCENE_ID)[index] as Object3D) == null) return;
			(getObjectsByID(WorldMap.SCENE_ID)[index] as Object3D).extra.tween = null;
			removeIconPlane(WorldMap.SCENE_ID, index);
		}
		
		//For the CombatMap
		public function addCombatMapActionIconPlane(iconName:String, position:Point, scale:Number = FXManager.ICON_SCALE):int {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(CombatMap.SCENE_ID)) return -1;
			var plane:Plane = addIconPlane(CombatMap.SCENE_ID, imgLoader.getBitmapAsset(iconName), position, MLFilters.ORANGE, scale);
			makeRotationY(plane, 3, 360, -1);
			return getObjectsByID(CombatMap.SCENE_ID).indexOf(plane);
		}
		
		public function removeCombatMapActionIconPlane(index:int):void {
			//For safe coding, external actions
			if (!registeredScenes.hasOwnProperty(CombatMap.SCENE_ID)) return;
			if ((getObjectsByID(CombatMap.SCENE_ID)[index] as Object3D) == null) return;
			(getObjectsByID(CombatMap.SCENE_ID)[index] as Object3D).extra.tween = null;
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
		protected function getView3DByID(id:String):View3D {
			checkRegisteredScene(id);
			return registeredScenes[id].view3D as View3D;
		}
		protected function getObjectsByID(id:String):Array {
			checkRegisteredScene(id);
			return registeredScenes[id].objects as Array;
		}
		protected function getParentByID(id:String):IFXAble {
			checkRegisteredScene(id);
			return registeredScenes[id].parent as IFXAble;
		}

	}
}class PrivateClass {}