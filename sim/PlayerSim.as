package sim
{
	import events.CollisionEvent;
	import events.ControllerEvent;
	
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
		
		public static const MOVESTATE_WALKING : int = 1;
		public static const MOVESTATE_JUMPING : int = 2; 
		
		

		private var playerController : Controller;

		private var _worldPosition:Point = new Point();
		private var velocityX:Number = 0;
		private static const terminalVelocity:Number = 6;		// TODO percentage
		private var velocity:Point = new Point();
		private var gravity:Number;
		private var view:PlayerView;
		private var _moveState : int;
		private var blHadGroundCollisionThisFrame : Boolean = false;
		private var _nCoins : int;
		private var _speedMultiplier : Number = 1.0;
		
		public function PlayerSim( controller:Controller, velX:Number, _gravity:Number, _playerView:PlayerView, _collisionMgr : CollisionManager )
		{
			super(null);
			reset();
				
			_moveState = MOVESTATE_WALKING;
			velocityX = velX;
			gravity = _gravity;
			
			view = _playerView;
			
			playerController = controller;
			playerController.addEventListener(ControllerEvent.JUMP, onJump );
		
			_collisionMgr.addEventListener(CollisionEvent.PLAYERxWORLD, onCollision_playerVsWorld );
		}
		

		private function reset(): void {
			_nCoins = 0;
		}
		
		public function addCoins( n : int ) : void {
			_nCoins += n;
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
		
		public function get moveState():int
		{
			return _moveState;
		}
		
		public function getBounds() : Rectangle {
			return view.getBounds();
		}
		
		public function Update() : void {
 			_moveState = MOVESTATE_JUMPING;  // set to walking in onCollision_playerxWorld is collision with ground, otherwise assume jumping each frame
			blHadGroundCollisionThisFrame = false;			
			var pos:Vector2 = new Vector2();
			
			pos.x += velocityX * _speedMultiplier;
			
			velocity.y += gravity;
			if( velocity.y > terminalVelocity ) {
				velocity.y = terminalVelocity;
			}
						
			pos.y += velocity.y;
			
			move( pos ); 		
		}
		

		private function move( v:Vector2 ) : void {
			
			worldPosition = new Point( v.x + worldPosition.x, v.y + worldPosition.y);
		}
		
		private function onJump( e:Event ) : void {
			velocity.y -= 25;
			_moveState = MOVESTATE_JUMPING;
		}

		private function onCollision_playerVsWorld( collisionEvent : CollisionEvent ) : void {
			
			var cr : CollisionResult = collisionEvent.collisionResult;
			var wo : WorldObject = cr.collidedObj;
			var v : Vector2 = cr.msv;
			
			
/*			
			if( collisionEvent.collisionResult.code && CollisionResult.BOTTOMCODE ) {
				blHadGroundCollisionThisFrame = true;
				_moveState = MOVESTATE_WALKING;
			}
					
			move( collisionEvent.collisionResult.impulse );
			collisionEvent.collisionResult.collidedObj.onCollision( this );
*/	
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