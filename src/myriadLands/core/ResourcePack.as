package myriadLands.core
{	
	public class ResourcePack
	{
		protected var _xylan:int;
		protected var _morphid:int;
		protected var _brontite:int;
		
		protected var _isNull:Boolean;
				
		public function ResourcePack(xylan:int, morphid:int, brontite:int, isNull:Boolean = false)
		{
			_xylan = xylan;
			_morphid = morphid;
			_brontite = brontite;
			_isNull = isNull;
		}
		
		public static function resourcePackFromString(str:String):ResourcePack
		{
			if (str == null) return new ResourcePack(0, 0, 0, true);
			var cost:Array = str.split(",");
			if (cost == null) 
				return new ResourcePack(0, 0, 0, true);
			else
				return (new ResourcePack(parseInt(cost[0]), parseInt(cost[1]), parseInt(cost[2])));
		}
		
		public function get xylan():int
		{
			return _xylan;
		}
		
		public function get morphid():int
		{
			return _morphid;
		}
		
		public function get brontite():int
		{
			return _brontite;
		}
		
		public function toArray():Array
		{
			if (_isNull)
				return null;
			else
			{
				return ["xylan:" + xylan, 
						"morphid:" + morphid, 
						"brontite:" + brontite];
			}
		}
		
		public function multiplyBy(factor:Number):ResourcePack {
			return new ResourcePack(this._xylan * factor, this._morphid * factor, this._brontite * factor);
		}
	}
}