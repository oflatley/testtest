package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sim.Level;
	import sim.WorldObject;

	public class PlayerView
	{
		private var mc:MovieClip;;
		private var debugBounds : Sprite;	
				
		public function PlayerView()
		{
			mc = new Player();
			
			debugBounds = new Sprite();
			debugBounds.graphics.lineStyle( 2, 0xFF0000 );
			var r:Rectangle = getBounds();
			debugBounds.graphics.drawRect(r.x,r.y,r.width,mc.height);
		}
		
		public function SetPosition( p:Point ) : void {
			mc.x = p.x;
			mc.y = p.y;
		
			debugBounds.x = p.x;
			debugBounds.y = p.y;		
		}
		
		public function AddToScene( scene:Sprite ) : void {
			scene.addChild(mc);
			scene.addChild(debugBounds);		
		}
		
		public function getBounds() : Rectangle {
			//player mc has registration point in lower right -- we fix it up so that the bounds is as if registration is upperleft (like our world objects)
			return new Rectangle( mc.x, mc.y - mc.height, mc.width, mc.height );	
		}
	}
}