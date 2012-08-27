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
		private var _debugBoundMC : MovieClip;

		public function PlayerView()
		{
			mc = ObjectPool.Instance().playerMC; // for swc: new Player();
			
			_debugBoundMC = ObjectPool.Instance().getDebugBoundingBox();
			_debugBoundMC.x = mc.x;
			_debugBoundMC.y = mc.y;
			_debugBoundMC.width = mc.width;
			_debugBoundMC.height = mc.height;
			
			
		}
		
		public function SetPosition( p:Point ) : void {
			mc.x = p.x;
			mc.y = p.y;
	
			_debugBoundMC.x = p.x;
			_debugBoundMC.y = p.y;
			
		}
		
		public function AddToScene( scene:Sprite ) : void {
			scene.addChild(mc);
			scene.addChild(_debugBoundMC);
	
		}
		
		public function getBounds() : Rectangle {
			return new Rectangle( mc.x, mc.y, mc.width, mc.height );

			
			//player mc has registration point in mid-bottom -- we fix it up so that the bounds is as if registration is upperleft (like our world objects)			
		//	return new Rectangle( mc.x - mc.width/2, mc.y - mc.height, mc.width, mc.height );	
			
			
		}
		
		public function scale( n : Number ) : void {
			mc.scaleX = n;
			mc.scaleY = n; 
			
			_debugBoundMC.scaleX = n;
			_debugBoundMC.scaleY = n;
		}
	}
}