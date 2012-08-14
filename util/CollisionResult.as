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
		
		private var _code:Number;
		private var _minSeperatingVector:Vector2;
		private var _collidedObj:WorldObject;
		
		public function CollisionResult( code:Number = 0 , impulse:Vector2 = null, obj:WorldObject = null )
		{
			init( code, impulse, obj );
		}
		
		public function init( code:Number = 0 , impulse:Vector2 = null, obj:WorldObject = null ) : void{
			_code = code;
			_minSeperatingVector = impulse;
			_collidedObj = obj;			
		}

		public function get code():Number {
			return _code;
		}

		public function set code(value:Number):void {
			_code = value;
		}

		public function get msv():Vector2 {
			return _minSeperatingVector;
		}

		public function set msv(value:Vector2):void {
			_minSeperatingVector = value;
		}

		public function get collidedObj():WorldObject {
			return _collidedObj;
		}

		public function set collidedObj(value:WorldObject):void {
			_collidedObj = value;
		}
	}
}