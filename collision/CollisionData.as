package collision {

	import flash.geom.Point;
	
	import interfaces.ICollisionData;
	
	import util.Vector2;
	
	public class CollisionData implements ICollisionData {


		public function testPoint( p : Point ) : Vector2 {
			return testxy( p.x, p.y );
		}
		public function testxy( _x : Number, _y:Number ) : Vector2  {
		
			var x : int = Math.floor( _x + .5 );
			var y : int = Math.floor( _y + .5 );
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