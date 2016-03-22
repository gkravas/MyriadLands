package myriadLands.entities
{
	public class Combatant extends Unit
	{
		protected var _reflex:int;
		protected var _attackRating:int;
		protected var _defenceRating:int;
		protected var _criticalChance:int;
		protected var _criticalFactor:int;
		protected var _actionPoints:int;

		public function Combatant(dataName:String, data:EntityData)
		{
			super(dataName, data);
			_renderableAttributes = _renderableAttributes.concat(["reflex", "attackRating", "defenceRating", "criticalChance", "criticalFactor", "actionPoints"]);
		}
		
		protected override function setDataFromXML():void
		{
			super.setDataFromXML();
			this._reflex = parseInt(this.data.attributes["reflex"]);
			this._attackRating = parseInt(this.data.attributes["attackRatingattackRating"]);
			this._defenceRating = parseInt(this.data.attributes["defenceRating"]);
			this._criticalChance = parseInt(this.data.attributes["criticalChance"]);
			this._criticalFactor = parseInt(this.data.attributes["criticalFactor"]);
			this._actionPoints = parseInt(this.data.attributes["actionPoints"]);
		}
		
	}
}