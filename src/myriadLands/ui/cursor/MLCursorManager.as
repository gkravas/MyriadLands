package myriadLands.ui.cursor {
	import flash.ui.Mouse;
	
	import mx.managers.CursorManager;
	
	
	public class MLCursorManager {
		
		
		public static const SELECT:int = 0;
		public static const BROWSE:int = 1;
		
		//Images for cursors
		[Embed(source="/assets/images/mouse/select.png")]
        protected static var selectCur:Class;
        [Embed(source="/assets/images/mouse/browse.png")]
        protected static var browseCur:Class;
        
		//img array same as static comst IDs
		protected static const cursors:Array = [selectCur, browseCur];
		
		public static function destroyCursors():void {
			CursorManager.removeAllCursors();
		}
		
		public static function setCursor(cursorName:int):void {
			if (CursorManager.currentCursorID != CursorManager.NO_CURSOR)
				CursorManager.removeCursor(CursorManager.currentCursorID);
			CursorManager.setCursor(cursors[cursorName]);
		}
		
		public static function showCursor():void {
			//CursorManager.showCursor();
			Mouse.show();
		}
		
		public static function hideCursor():void {
			//CursorManager.hideCursor();
			Mouse.hide();
		}
	}
}