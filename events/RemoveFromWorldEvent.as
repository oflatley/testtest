package events
{
	import flash.events.Event;
	
	import sim.WorldObject;

	public class RemoveFromWorldEvent extends Event
	{

		public static const REMOVE_FROM_WORLD:String = "removeFromWorld";
		
		private var _wo : WorldObject;
		
		public function RemoveFromWorldEvent(type:String, wo : WorldObject )
		{
			super( type );
			_wo = wo;
		}
		
		public function get objToRemove():WorldObject 
		{			
			return _wo;
		}
	}
}