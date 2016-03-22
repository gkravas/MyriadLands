package myriadLands.ui.skins { 

  import mx.skins.ProgrammaticSkin;
  
  import myriadLands.ui.css.MLFilters;

  public class MLWindowCloseButtonSkin extends ProgrammaticSkin {

     public function MLWindowCloseButtonSkin() {
        super();
     }

     override protected function updateDisplayList(w:Number, h:Number):void {
	     switch (name)
	     {            
		     case "downSkin":
		     graphics.beginFill(MLFilters.OCHRA);
		     graphics.drawRect(0, 0, w, h);
		     break;
	     	 
	     	 case "overSkin":
		     graphics.beginFill(MLFilters.OCHRA);
		     graphics.drawRect(0, 0, w, h);
		     break;
		     
		     case "upSkin":
	         graphics.beginFill(MLFilters.ORANGE);
	         graphics.drawRect(0, 0, w, h);
		     break;
		     
		     case "disabledSkin":
		     graphics.beginFill(MLFilters.GREY);
		     graphics.drawRect(0, 0, w, h);
		     break;
	     }
     }
  }
}