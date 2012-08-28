package sim
{
	import events.CollisionEvent;
	import events.ControllerEvent;
	import events.RemoveFromWorldEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	
	import interfaces.ICollider;
	import interfaces.IWorldObject;
	
	import util.CollisionManager;
	import util.CollisionResult;
	import util.Controller;
	import util.Vector2;
	
	import views.PlayerView;
	
	
	public class PlayerSim extends EventDispatcher implements ICollider
	{
		private var playerController : Controller;
		private var velocityX:Number = 0;
		private static const terminalVelocity:Number = 6;		// TODO percentage
		private var _velocity:Vector2 = new Vector2();
		private var gravity:Number;
		private var view:PlayerView;			// TODO, kill this, decouple view from sim 
		private var _nCoins : int;
		private var _speedMultiplier : Number = 1.0;
		private var _isCollideable : Boolean = true;
		private var _dragX:Number = 2;
		private var _objectUnderfootThisFrame:IWorldObject = null;
		private var _objectUnderfootPreviousFrame:IWorldObject = null;
		private var _bounds : Rectangle = new Rectangle();	
		private var _originalSpan : Point = new Point(); // support for scaling
		private var _scaleOffsetY : Number = 0;  // support for scaling

		private var _localCollisionTestPoints : Vector.<Point> = new Vector.<Point>(4);
		private var _collisionTestPointsWalking : Vector.<Point> = new Vector.<Point>(1);
		private var _collisionTestPointsJumping : Vector.<Point> = new Vector.<Point>(4);
		private var _collisionTestPointsJumpingUp : Vector.<Point> = new Vector.<Point>(5);
		private var _registrationPointOffset:Point;
		
		public function PlayerSim( controller:Controller, velX:Number, _gravity:Number, _playerView:PlayerView, _collisionMgr : CollisionManager )
		{
			super(null);
			reset();
				
			velocityX = velX;
			gravity = _gravity ;			
			view = _playerView;			
			playerController = controller;
			
			playerController.addEventListener(ControllerEvent.JUMP, onJump );		
			_collisionMgr.addEventListener(CollisionEvent.PLAYERxWORLD, onCollision_playerVsWorld );
		
			_bounds = _playerView.getBounds().clone();	
			_originalSpan.offset( _bounds.width, _bounds.height );

			initLocalCollisionTestPoints(1);	
			initCollisionTestPoints( _collisionTestPointsWalking );
			initCollisionTestPoints( _collisionTestPointsJumping );
			initCollisionTestPoints( _collisionTestPointsJumpingUp );			
		}
		
		private function initLocalCollisionTestPoints( scale : Number ) : void {
			
			var right : Number = scale * _originalSpan.x;
			var bottom : Number = scale * _originalSpan.y;
			var halfW : Number = _originalSpan.x / 2;
			var halfH : Number = _originalSpan.y / 2;
			
			_localCollisionTestPoints[0] = new Point( halfW, 		bottom );		// bottom mid
			_localCollisionTestPoints[1] = new Point( right,  		.75 * bottom ); 	// right, bottom .25
			_localCollisionTestPoints[2] = new Point( right, 		.5 * bottom  ); 	// right, mid
			_localCollisionTestPoints[3] = new Point( right, 		.25	 * _bounds.height); 	// right, top.75
			_localCollisionTestPoints[4] = new Point( right, 			0  ); 							// right, mid
			_localCollisionTestPoints[5] = new Point( right - halfW,	0); 								// right, top.75			
		}
		
		private function initCollisionTestPoints( v : Vector.<Point> ) : void {
			for( var i : int = 0; i < v.length; ++i ) {
				v[i] = new Point();
			}
		}
		
		private function get canJump() : Boolean {
			return _objectUnderfootThisFrame && _isCollideable;
		}

		private function reset(): void {
			_nCoins = 0;
		}
		
		public function addCoins( n : int ) : void {
			_nCoins += n;
		}
		
		public function scale( n : Number, duration : Number ) : void {
		
			var h : Number = _originalSpan.y * n;
			_scaleOffsetY = _bounds.height - h;
			
			_bounds.y = _bounds.bottom - h;			
 			_bounds.width = _originalSpan.x * n;
			_bounds.height = h;
			initLocalCollisionTestPoints(n);
			
			view.SetPosition( _bounds.topLeft );
 			view.scale( n );
			setInterval( restoreNormalScale, duration/5 );
		} 
		
		private function restoreNormalScale() : void  {
			_bounds.width = _originalSpan.x;
			_bounds.height = _originalSpan.y;
			_bounds.y -= _scaleOffsetY;
		
			initLocalCollisionTestPoints(1);
			view.SetPosition( _bounds.topLeft );
			view.scale( 1 );
		}
		
		public function addSpeedBoost( duration_ms : int, speedMultiplier : Number ) : void {
			_speedMultiplier = speedMultiplier;
			setInterval( endSpeedBoost, duration_ms );
		}
			
		public function applyImpulse( p : Point ) : void {
			_velocity.x += p.x;
			_velocity.y += p.y;
		}
		
		private function endSpeedBoost() : void {
			_speedMultiplier = 1;
		}
		
		public function Update() : void {
			trace( (_objectUnderfootPreviousFrame != null) + ' ' + (_objectUnderfootThisFrame != null) ); 

  			var pos:Vector2 = new Vector2();
			pos.x += _velocity.x * _speedMultiplier;

			_velocity.x -= _dragX;
			if( _velocity.x < velocityX ) {
				_velocity.x = velocityX;
			}
			
			_velocity.y += gravity;
			if( _velocity.y > terminalVelocity ) {
				_velocity.y = terminalVelocity;
			}
						
			pos.y += _velocity.y;			
			move( pos ); 		
			
			_objectUnderfootPreviousFrame = _objectUnderfootThisFrame;
			_objectUnderfootThisFrame = null; 			
		}

		
		private function move( v:Vector2 ) : void {			
			
			worldPosition = new Point( v.x + worldPosition.x, v.y + worldPosition.y);
			buildCollisionTestPoints();			
		}
		
		private function onJump( e:Event ) : void {
			if( canJump ) {
				_velocity.y -= 25;
			}
			else {
				trace('jump denied');
			}
		}

		private function applyCollision( cr : CollisionResult ) : void {
 			var wo : IWorldObject = cr.collidedObj;
			var v : Vector2 = cr.msv;
			
			if( v.y < 0 ) {
				_objectUnderfootThisFrame = wo;
			}
			
			if( wo.isMonster ) {
				
				if( v.y < 0 && -v.y > Math.abs(v.x) ) {
					// player hit monster from above --> Kill the monster
					dispatchEvent( new RemoveFromWorldEvent( RemoveFromWorldEvent.REMOVE_FROM_WORLD, wo ) );
					_velocity.y -= 20;
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
					if( _objectUnderfootThisFrame ) {
						v.x = 0;		// walking, dont apply x, only want to match surface height
					}
					else {
						// in jumping/falling, apply collisions as follows:
						v.y = 0;
					}
						
					
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
			return _bounds.topLeft; 
		}

		public function set worldPosition(value:Point):void
		{
			_bounds.x = value.x;
			_bounds.y = value.y;
			view.SetPosition( value );
			buildCollisionTestPoints();
		}
		
		public function SetPosition( value:Point) : void {
 			worldPosition = value;
			buildCollisionTestPoints();
		}
		
		public function get bounds():Rectangle
		{
			return _bounds; 
		}
		
		public function get collisionTestPoints():Vector.<Point>
		{
			if( _objectUnderfootThisFrame ) {
				return _collisionTestPointsWalking;
			}
			
			if( _velocity.y < 0 ) { // we are ascending and jumping 
				return _collisionTestPointsJumpingUp;
			}
			return _collisionTestPointsJumping;
		}
		
		private function buildCollisionTestPoints() : void {
			
			_collisionTestPointsWalking[0].x = _localCollisionTestPoints[0].x + _bounds.x;
			_collisionTestPointsWalking[0].y = _localCollisionTestPoints[0].y + _bounds.y;

			for( var i : int = 0; i < _collisionTestPointsJumping.length; ++i ) {
				_collisionTestPointsJumping[i].x = _localCollisionTestPoints[i].x + _bounds.x;
				_collisionTestPointsJumping[i].y = _localCollisionTestPoints[i].y + _bounds.y;				
			}
			
			_collisionTestPointsJumpingUp[0].x = _localCollisionTestPoints[5].x + _bounds.x;
			_collisionTestPointsJumpingUp[0].y = _localCollisionTestPoints[5].y + _bounds.y;
			_collisionTestPointsJumpingUp[1].x = _localCollisionTestPoints[4].x + _bounds.x;
			_collisionTestPointsJumpingUp[1].y = _localCollisionTestPoints[4].y + _bounds.y;
			_collisionTestPointsJumpingUp[2].x = _localCollisionTestPoints[3].x + _bounds.x;
			_collisionTestPointsJumpingUp[2].y = _localCollisionTestPoints[3].y + _bounds.y;
			_collisionTestPointsJumpingUp[3].x = _localCollisionTestPoints[2].x + _bounds.x;
			_collisionTestPointsJumpingUp[3].y = _localCollisionTestPoints[2].y + _bounds.y;
			_collisionTestPointsJumpingUp[4].x = _localCollisionTestPoints[1].x + _bounds.x;
			_collisionTestPointsJumpingUp[4].y = _localCollisionTestPoints[1].y + _bounds.y;
			
			view.drawTestPoints( collisionTestPoints );
		}
		
		public function get velocity():Vector2
		{
			return _velocity;
		}		
	}
}