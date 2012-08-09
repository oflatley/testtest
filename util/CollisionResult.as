package util
{
	import flash.geom.Point;
	
	import sim.WorldObject;

	public class CollisionResult
	{
		public static const LEFTCODE:int = 1;
		public static const RIGHTCODE:int = 2;
		public static const TOPCODE:int = 4;
		public static const BOTTOMCODE:int = 8;
		

		
		public var code:Number;
		public var impulse:Point;
		public var collidedObj:WorldObject
		
		public function CollisionResult( _code:Number, _impulse:Point, _obj:WorldObject )
		{
			code = _code;
			impulse = _impulse;
			collidedObj = _obj;
		}
	}
}