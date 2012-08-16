package sim
{
	import events.CollisionEvent;
	import events.ControllerEvent;
	import events.RemoveFromWorldEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	
	import util.CollisionManager;
	import util.CollisionResult;
	import util.Controller;
	import util.Vector2;
	
	import views.PlayerView;
	
	
	public class PlayerSim extends EventDispatcher
	{
		private var playerController : Controller;
		private var _worldPosition:Point = new Point();
		private var velocityX:Number = 0;
		private static const terminalVelocity:Number = 6;		// TODO percentage
		private var velocity:Point = new Point();
		private var gravity:Number;
		private var view:PlayerView;
		private var _nCoins : int;
		private var _speedMultiplier : Number = 1.0;
		private var _isCollideable : Boolean = true;
		private var _dragX:Number = 2;
		private var _objectCurrentlyUnderfoot:WorldObject = null;
		
		public function PlayerSim( controller:Controller, velX:Number, _gravity:Number, _playerView:PlayerView, _collisionMgr : CollisionManager )
		{
			super(null);
			reset();
				
			velocityX = velX;
			gravity = _gravity;			
			view = _playerView;			
			playerController = controller;
			
			playerController.addEventListener(ControllerEvent.JUMP, onJump );		
			_collisionMgr.addEventListener(CollisionEvent.PLAYERxWORLD, onCollision_playerVsWorld );
		}
		
		private function get canJump() : Boolean {
			return _objectCurrentlyUnderfoot && _isCollideable;
		}

		private function reset(): void {
			_nCoins = 0;
		}
		
		public function addCoins( n : int ) : void {
			_nCoins += n;
		}
		
		public function scale( n : Number, duration : Number ) : void {
 			view.scale( n );
			setInterval( restoreNormalScale, duration );
		}
		
		private function restoreNormalScale() : void  {
			view.scale( 1 );
		}
		
		
		public function addSpeedBoost( duration_ms : int, speedMultiplier : Number ) : void {
			_speedMultiplier = speedMultiplier;
			setInterval( endSpeedBoost, duration_ms );
		}
			
		public function applyImpulse( p : Point ) : void {
			velocity.x += p.x;
			velocity.y += p.y;
		}
		
		private function endSpeedBoost() : void {
			_speedMultiplier = 1;
		}
		
		public function getBounds() : Rectangle {
			return view.getBounds();
		}
		
		public function Update() : void {
			var pos:Vector2 = new Vector2();
			pos.x += velocity.x * _speedMultiplier;

			velocity.x -= _dragX;
			if( velocity.x < velocityX ) {
				velocity.x = velocityX;
			}
			
			velocity.y += gravity;
			if( velocity.y > terminalVelocity ) {
				velocity.y = terminalVelocity;
			}
						
			pos.y += velocity.y;			
			move( pos ); 		
		
			_objectCurrentlyUnderfoot = null; // clear for next time through. note that collision detection will occur before next call to PlayerSim.update
		}

		private function move( v:Vector2 ) : void {			
			worldPosition = new Point( v.x + worldPosition.x, v.y + worldPosition.y);
		}
		
		private function onJump( e:Event ) : void {
			if( canJump ) {
				velocity.y -= 25;
			}
			else {
				trace('jump denied');
			}
		}

		private function applyCollision( cr : CollisionResult ) : void {
 			var wo : WorldObject = cr.collidedObj;
			var v : Vector2 = cr.msv;
			
			if( v.y < 0 ) {
				_objectCurrentlyUnderfoot = wo;
			}
			
			if( wo.isMonster ) {
				
				if( v.y < 0 && -v.y > Math.abs(v.x) ) {
					// player hit monster from above --> Kill the monster
					dispatchEvent( new RemoveFromWorldEvent( RemoveFromWorldEvent.REMOVE_FROM_WORLD, wo ) );
					velocity.y -= 20;
				}
				else {
					// player hit monster from the side or from below --> penalize player
					//trace('from side or below');
					_isCollideable = false;
					setInterval( restoreCollisionEnabled, 1000 );
				}
			}
			else
			{
				var bCollisionFromBelow : Boolean = v.y > 0;
				
				if( bCollisionFromBelow && !wo.isCollideableFromBelow ) {
					
				}
				else {
					move( v );
					cr.collidedObj.onCollision( this );			
				}
			}
		}
		
		private function onCollision_playerVsWorld( collisionEvent : CollisionEvent ) : void {		
			applyCollision( collisionEvent.collisionResult );		
		}
		
		private function restoreCollisionEnabled():void
		{
			_isCollideable = true; 
		}
		
		public function get worldPosition():Point
		{
			return _worldPosition;
		}

		public function set worldPosition(value:Point):void
		{
			_worldPosition = value;
			view.SetPosition( value );
		}
		
		public function SetPosition( value:Point) : void {
			worldPosition = value;
		}
	}
}