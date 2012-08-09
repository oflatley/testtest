package events
{
	import flash.events.Event;
	
	import util.CollisionResult;
	
	public final class ControllerEvent extends Event
	{
		public static const JUMP:String = "jump";
		
		public function ControllerEvent(type:String)
		{
			super(type);
		}
	}
}