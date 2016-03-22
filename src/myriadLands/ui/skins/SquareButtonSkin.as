package myriadLands.ui.skins { 

  import mx.skins.ProgrammaticSkin;
  
  import myriadLands.ui.css.MLFilters;

  public class SquareButtonSkin extends ProgrammaticSkin {

     public function SquareButtonSkin() {
        super();
     }

     override protected function updateDisplayList(w:Number, h:Number):void {
		switch (name)
	     {            
		     case "downSkin":
		     graphics.lineStyle(2, getStyle("downColor"), alpha);
	         graphics.beginFill(0x000000, alpha);
	         graphics.drawRect(2, 2, w - 4, h - 4);
		     break;
	     	 
	     	 case "overSkin":
		     graphics.lineStyle(2, getStyle("overColor"), alpha);
	         graphics.beginFill(0x000000, alpha);
	         graphics.drawRect(2, 2, w - 4, h - 4);
		     break;
		     
		     case "upSkin":
	         graphics.lineStyle(2, getStyle("upColor"), alpha);
	         graphics.beginFill(0x000000, alpha);
	         graphics.drawRect(2, 2, w - 4, h - 4);
		     break;
		     
		     case "disabledSkin":
		     graphics.lineStyle(2, getStyle("disabledColor"), alpha);
	         graphics.beginFill(0x000000, alpha);
	         graphics.drawRect(2, 2, w - 4, h - 4);
		     break;
	     }
     }
  }
}