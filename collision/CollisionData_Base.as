package collision {

	import flash.geom.Point;
	import interfaces.ICollisionData;
	
	public class CollisionData_Base implements ICollisionData {
		public function get data() : Array { return _data; }
		public function testPoint(p:Point) : Boolean { return testxy( p.x, p.y ); }
		public function testxy( x : int, y:int ) : Boolean  {
			if( x < _width && y < _height ) 
				return _data[y*_width + x];
			return false;
		}
		protected var _height:int;
		protected var _width:int;
		protected var _data:Array;
	}
}