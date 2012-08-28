package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sim.Level;
	
	import util.ObjectPool;


	public class PlayerView
	{
		private var mc:MovieClip;;
		private var _debugTP : Array = new Array(10);

		public function PlayerView()
		{
			mc = ObjectPool.Instance().playerMC; // for swc: new Player();
			
			
			for( var i : int = 0; i < _debugTP.length; ++i ) {
				_debugTP[i] = ObjectPool.Instance().getDebugBoundingBox();
				_debugTP[i].width = 3;
				_debugTP[i].height = 3;
			}
		}
		
		public function drawTestPoints( v : Vector.<Point> ) : void {
			for( var i : int = 0; i < _debugTP.length; ++i ) {
					
				var mc : MovieClip = _debugTP[i];
					
				if( i < v.length ) {					
					mc.x = v[i].x - 1;
					mc.y = v[i].y - 1;
					mc.visible = true;
				} else {
					mc.visible = false;
				}
			}
		}
		
		public function SetPosition( p:Point ) : void {
			mc.x = p.x;
			mc.y = p.y;
		}
		
		public function AddToScene( scene:Sprite ) : void {
			scene.addChild(mc);
			
			for( var i : int = 0; i < _debugTP.length; ++i ) {
				scene.addChild( _debugTP[i] );
			}
	
		}
		
		public function getBounds() : Rectangle {
			return new Rectangle( mc.x, mc.y, mc.width, mc.height );
		}
		
		public function scale( n : Number ) : void {
			mc.scaleX = n;
			mc.scaleY = n; 
		}
	}
}