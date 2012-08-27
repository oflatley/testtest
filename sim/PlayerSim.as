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
		private var _objectCurrentlyUnderfoot:IWorldObject = null;
		private var _bounds : Rectangle = new Rectangle();
		

		private static const HIT_POINT_COUNT : int = 4;
		private var _localCollisionTestPoints : Vector.<Point> = new Vector.<Point>(HIT_POINT_COUNT);
		private var _collisionTestPoints : Vector.<Point> = new Vector.<Point>(HIT_POINT_COUNT);
		private var _registrationPointOffset:Point;
		
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
		
			_bounds = _playerView.getBounds();	
			//_registrationPointOffset = new Point( 0, -_bounds.y );
	
			// set bounds upper left 
			//_bounds.x += _registrationPointOffset.x;
			//_bounds.y += _registrationPointOffset.y;
			
			
			var halfW : Number = _bounds.width / 2;
			var halfH : Number = _bounds.height / 2;
			
			_localCollisionTestPoints[0] = new Point( _bounds.left + halfW, 	_bounds.bottom );		// bottom mid
			_localCollisionTestPoints[1] = new Point( _bounds.right,  			_bounds.top + halfH ); 	// mid right
			_localCollisionTestPoints[2] = new Point( _bounds.left + halfW, 	_bounds.top ); 			// mid top
			_localCollisionTestPoints[3] = new Point( _bounds.left, 			_bounds.top + halfH ); 	// mid lef
			
			for( var i : int = 0 ; i < HIT_POINT_COUNT; ++i ) {
				_collisionTestPoints[i] = new Point();
			}
			
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
			_velocity.x += p.x;
			_velocity.y += p.y;
		}
		
		private function endSpeedBoost() : void {
			_speedMultiplier = 1;
		}
		
//		public function getBounds() : Rectangle {
//			return _bounds;
			//return view.getBounds();/
//		}
		
		public function Update() : void {
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
			
			_objectCurrentlyUnderfoot = null; // clear for next time through. note that collision detection will occur before next call to PlayerSim.update
		}

		private function buildCollisionTestPoints() : void {

			for( var i : int = 0; i < HIT_POINT_COUNT; ++i ) {
				var src : Point = _localCollisionTestPoints[i];
				var dst : Point = _collisionTestPoints[i];				
				dst.x = src.x + _bounds.x;
				dst.y = src.y + _bounds.y;				
			}

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
				_objectCurrentlyUnderfoot = wo;
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
					v.x = 0;		// TODO -- this assume walking
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
			return _bounds.topLeft; //_worldPosition;
		}


		
		public function set worldPosition(value:Point):void
		{
			//_worldPosition = value;
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
			//return view.getBounds(); 
		}
		
		public function get collisionTestPoints():Vector.<Point>
		{
			return _collisionTestPoints;
		}
		
		public function get velocity():Vector2
		{
			return _velocity;
		}		
	}
}