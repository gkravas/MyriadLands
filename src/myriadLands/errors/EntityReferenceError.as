package myriadLands.errors
{
	public class EntityReferenceError extends Error
	{
		public function EntityReferenceError(message:String="", id:int=0) {
			super(message, id);
		}
		
	}
}