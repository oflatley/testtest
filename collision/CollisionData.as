package collision {

	import flash.geom.Point;
	
	import interfaces.ICollisionData;
	
	import util.BitArray2D;
	import util.Vector2;
	
	public class CollisionData implements ICollisionData {


		public function testPoint( p : Point ) : Vector2 {
			return testxy( p.x, p.y );
		}
		public function testxy( _x : Number, _y:Number ) : Vector2  {
		
			var x : int = Math.floor( _x + .5 );
			var y : int = Math.floor( _y + .5 );
			var vResult : Vector2 = new Vector2(0,0);


			if( x < _bits.width && x >= 0 && y < _bits.height && y >= 0 && _bits.testxy(x,y) ) {
				
				// check up
				for( var yy : int = y - 1; yy >= 0 ; --yy  ) {
					if( ! _bits.testxy(x,yy) ) {
						break;
					}
				}
				
				// check left
				for( var xx : int = x - 1; xx >= 0 ; --xx  ) {
					if( ! _bits.testxy(xx,y) ) {
						break;
					}
				}
				vResult.setxy( xx-x, yy-y);
			}
			
			//var vResultCheck : Vector2 = testxy_old(_x,_y); 
			
			return vResult;
		}
/*		
		public function testxy_old( _x : Number, _y:Number ) : Vector2  {
			
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
*/			
		public function CollisionData( w : uint, h : uint, v :Vector.<uint> ) {
		//	_width = w;
		//	_height = h;
		//	_data = v;
			_bits = new BitArray2D( w,h,v );
		}
		
		
	//	protected var _height:int;
	//	protected var _width:int;
	//	protected var _data:Vector.<uint>;
		protected var _bits : BitArray2D;
	}
}