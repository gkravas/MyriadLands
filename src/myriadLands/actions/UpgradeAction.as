package myriadLands.actions
{
	import myriadLands.combat.CombatHighlight;
	import myriadLands.entities.Entity;
	import myriadLands.entities.Tile;
	import myriadLands.ui.css.MLFilters;
	
	import r1.deval.D;

	public class UpgradeAction extends Action
	{
		protected var _attribute:String;
		protected var _value:int;
		protected var _times:int;
		protected var _isPercentage:Boolean;
		
		public function UpgradeAction(dataName:String, owner:Entity)
		{
			super(dataName, owner);
			iconName = "upgrade-cur";
			styleName = "UpgradeInfo";
		}
		
		override protected function setDataFromXML():void {
			super.setDataFromXML();
			var upgradeArgs:Array = String(this._data.attributes["upgradeArgs"]).split(":");
			
			_attribute = upgradeArgs[0];
			_value = parseInt(upgradeArgs[1]);
			_times = parseInt(upgradeArgs[2]);
			_isPercentage = (upgradeArgs[3] == "%") ? true : false;
			_soundID = "upgrade";
		}
				
		override protected function engageFunctionality(args:Object=null):Boolean {
			playSound(3);
			upgradeEntity();
			return true;
		}		
		
		override public function executeFromNet(args:Object):void {
			upgradeEntity();
		}
		
		override protected function getStaticCost(args:Object):Object {
			var upgradedTimes:int = _owner.getAttributeUpgradeTimes(_attribute);
			var mult:int =  (upgradedTimes == 0) ? 1 : upgradedTimes * _times;
			args.mult = mult;
			var context:Object = {"morphid":_morphidCost * mult, "xylan":0, "brontite":0, "lif":_lifCost, "act":_actCost};
			if (_staticCost != null)
				D.eval(_staticCost, context, args);
			return context;
		}
		
		protected function upgradeEntity():void {
			var lastChar:String = (_isPercentage) ? "%" : "";
			var prosimo:String = (_value >= 0) ? "+" : "-";
			if (_isPercentage) {
				_owner.multiplyAttribute(_attribute, _value, true);
			} else {
				_owner.addToAttribute(_attribute, _value, true);
			}
			_owner.addAttributeUpgradeTimes(_attribute);
			(owner.parentEntity as Tile).mapTile.addAnimatedText(prosimo + " " + Math.abs(_value) + lastChar + " " + _d.getLeema(_attribute), styleName);
			(owner.parentEntity as Tile).mapTile.showAura(MLFilters.BLUE);
		}
		
		override protected function onPostExecute():void {
			super.onPostExecute();
			if (_owner.getAttributeUpgradeTimes(_attribute) == times)
				_owner.removeAction(_data.id);
		}
		
		//NETWORK ENCODE, DECODE
		override public function encodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			_lastNetArgs = toValidateEntity.networkID;
		}
		
		override public function decodeNetworkArgs(args:Object):void {
			//0 is toValidate entity
			toValidateEntity = eManger.getEntityByID(args.lastNetArray[0]);
		}
		
		//GETTERS
		public function get attribute():String {return _attribute;}
		public function get value():int {return _value;}
		public function get times():int {return _times;}
	}
}