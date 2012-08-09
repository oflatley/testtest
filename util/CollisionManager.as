package util
{
	
	import events.CollisionEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sim.PlayerSim;
	import sim.WorldObject;
	
	public class CollisionManager  extends EventDispatcher
	{
		
		
		public function CollisionManager() {
		}

		public function update( player:PlayerSim, worldObjects:Array ) : void  {
			
			switch ( player.moveState ) {
				case PlayerSim.MOVESTATE_JUMPING: doCollisionsWalking( player, worldObjects ); break;
				case PlayerSim.MOVESTATE_WALKING: doCollisionsWalking( player, worldObjects ) ; break;
				default: trace("unknown fasdjkhgnsadl;ingbsadlik");					
			}
		}
		
		private function doCollisionsJumping( player:PlayerSim, worldObjects:Array ) : void  {
			
 		}

		private function doCollisionsWalking( player:PlayerSim, activeObjects:Array ) : void  {
		
			var playerBounds : Rectangle = player.getBounds();
			var results:Array = new Array();
			
			for each( var wo : WorldObject in activeObjects ) {
					
				// TODO, send event instead of returning array of results
				var woBounds : Rectangle = wo.GetBounds();
				
				if( wo.testCollision( playerBounds ) ) {
						

  					var collisionCode:int = getCollisionCodeWalking( playerBounds, woBounds ); 
					
					var impulse:Point = new Point(0,0);
					if( collisionCode & CollisionResult.RIGHTCODE ) {
						impulse.x = woBounds.left - playerBounds.right;
					}
					
					if( collisionCode & CollisionResult.BOTTOMCODE ) {
						impulse.y = wo.getYat(playerBounds.left) - playerBounds.bottom ;
					}
					
					results.push( new CollisionResult( collisionCode, impulse, wo ) );
				}
			}			
			for each( var cr:CollisionResult in results ) {
				this.dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
			}
		}
		
		public static function testRectxRect( a:Rectangle, b: Rectangle ) : Boolean {			
			return a.intersects( b ) ;
		}
		
		public static function testPointInAlignedRect( p : Point, r : Rectangle ) : Boolean {
			return r.containsPoint( p );
		}
		
		private function testIntersection( a:Rectangle, b:Rectangle ) : Boolean {
					
			return ( ((a.left > b.left && a.left < b.right) || ( a.right > b.left && a.right < b.right)) && 
					((a.top > b.top && a.top < b.bottom) || (a.bottom > b.top && a.top < b.bottom)) );
		}
		
		// return value only valid if an a and b overlap
		private function getIntersectionCode( a:Rectangle, b:Rectangle ) : int {
			if( a.left < b.left ) {
				if( a.top < b.top )	return 1;
				if( a.bottom > b.bottom ) return 2;
				return 3;
			}

			if( a.right > b.right ) {
				if( a.top < b.top )	return 4;
				if( a.bottom > b.bottom ) return 5;
				return 6;
			}
			
			if( a.top < b.top ) return 7;
			if( a.bottom > b.bottom ) return 8;
			return 9;
			
		}

		
		private function getCollisionCodeWalking( a:Rectangle, b:Rectangle ) : int {
			
			
			var code :int = 0;
			
			switch( getIntersectionCode( a, b ) ) {
				case 1:
				case 7:
				case 4: 
					code = CollisionResult.BOTTOMCODE;
					break;
				case 2:
					code = CollisionResult.RIGHTCODE;
					break;
				default: trace("============ WTF getCollisionCodeWalking ===============");
			}
			
			return code;
			
			
			// for now, assuming running vs world static obj. check player bottom (against obj top) and player right (against obj left)
			// this is tricky, we test for walking into a wall before testing if we are below the surface ...

			
			// if running
			// -- against world static objects, we need only check against ground and left face
			// -- against dyn obj, we need to check only to the right
			
			// if jumping
			// -- against world static objects, we need check ground, the left face and above
			// -- against dyn obj, same as jumping vs world static objects

		}
		
		
	}
}