package collision {

	import flash.geom.Point;
	
	import interfaces.ICollisionData;
	
	import util.Vector2;
	
	public class CollisionData implements ICollisionData {

	//	private var vResult : Vector2 = new Vector2();
		
		//public function get data() :  { return _data; }
//		public function testPoint(p:Point) : Boolean { return testxy( p.x, p.y ); }
//		public function testxy( x : int, y:int ) : Boolean  {
//			if( x < _width && y < _height ) 
//				return _data[y*_width + x];
//			return false;
//		}

		public function testPoint( p : Point ) : Vector2 {
			return testxy( p.x, p.y );
		}
		public function testxy( x : int, y:int ) : Vector2  {
		
			var vResult : Vector2 = new Vector2(0,0);
			
			if( x < _width && x >= 0 && y < _height && y >= 0 && _data[y*_width + x] ) {
					
				// check up
				for( var yy : int = y - 1; yy >= 0 ; --yy  ) {
					if( 0 == _data[yy*_width + x] ) {
						break;
					}
				}
				
				// check left
				for( var xx : int = x - 1; xx >= 0 ; --xx  ) {
					if( 0 == _data[y*_width + xx] ) {
						break;
					}
				}
				vResult.setxy( xx-x, yy-y);
			}
			return vResult;
		}
		
		public function CollisionData( w : int, h : int, v :Vector.<int> ) {
			_width = w;
			_height = h;
			_data = v;
		}
		
		
		protected var _height:int;
		protected var _width:int;
		protected var _data:Vector.<int>;
	}
}