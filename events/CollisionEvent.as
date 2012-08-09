package events
{
	import flash.events.Event;
	
	import util.CollisionResult;
	
	public class CollisionEvent extends Event
	{
		public static const PLAYERxWORLD : String = "playerxWorld";
		public static const PLAYERxCOIN : String =  "playerxCoin";
		
		public var collisionResult : CollisionResult;
		
		public function CollisionEvent(type:String, cr:CollisionResult = null)
		{
			super(type);
			collisionResult = cr;
		}
		
	}
}