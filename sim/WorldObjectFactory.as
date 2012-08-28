package sim
{
	import collision.CollisionDataProvider;
	
	import events.CollisionEvent;
	import events.WorldObjectEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import interfaces.IWorldObject;
	
	import util.CollisionResult;
	
	
	public class WorldObjectFactory {
		
			
		private static var theWorldObjectFactory : WorldObjectFactory = null;		
		private var map : Array = new Array();
		
		
		public static function Instance() : WorldObjectFactory {
			if( null == theWorldObjectFactory ) {
				theWorldObjectFactory = new WorldObjectFactory(new SingletonEnforcer());
			}
			return theWorldObjectFactory;
		}
		
		public function WorldObjectFactory( makeThisConstructorUnusable : SingletonEnforcer ) {
			
		}
		
		public function createWorldObject( _type : String, _bounds : Rectangle ) : IWorldObject {
			return createWorldObj( _type, _bounds );
		}
	
		
		private function createWorldObj( _type:String, _bounds : Rectangle  ) : IWorldObject {
			
			switch(_type) {	
				case "Launcher": return new LauncherSim( _type, _bounds );
				case "Catapult": return new CatapultSim( _type, _bounds );
				case "Trampoline": return new TrampolineSim( _type, _bounds );
				case "Token_MakePlayerBigger": return new Token_MakePlayerBiggerSim( _type, _bounds );
				case "Token_MakePlayerSmaller": return new Token_MakePlayerSmallerSim( _type, _bounds );							
				case "SpringBoard": return new SpringBoardSim( _type, _bounds );
				case "SpeedBoostCoin":
					return new SpeedBoostCoinSim( _type, _bounds ); 
				case "Brain":
					return new BrainCoinSim( _type, _bounds );
				case "Enemy_0":
					return new EnemyBlobSim( _type, _bounds );
				case "PlatformShort_elev":
					return new ElevatorPlatformSim( _type, _bounds );
				case "Column":  
				case "Platform_Arc_0":
				case "PlatformShort_0":
				case "PlatformMedium_0":
				case "PlatformLong_0": 			
					return new LevelPlatformDataSim( _type, _bounds );
					break;
				case "PlatformMedium_15": 	
				case "PlatformMedium_345": 
					return new SlopedPlatformDataSim(_type, _bounds );
					break;
				default:
					trace("unknown type encountered in createWorldObjData");					
			}
			return null;	
		}
	}
	
}	
class SingletonEnforcer {}




import collision.CollisionDataProvider;

import events.CollisionEvent;
import events.WorldObjectEvent;

import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import interfaces.ICollider;
import interfaces.ICollisionData;
import interfaces.IWorldObject;

import sim.PlayerSim;
import sim.WorldObjectFactory;

import util.CollisionManager;
import util.CollisionResult;
import util.ScreenContainer;
import util.Vector2;





class WorldObjSimBase extends EventDispatcher implements IWorldObject {
	
	protected var _collisionImpulse : Point;
	protected var _collisionResult : CollisionResult;
	protected var _bounds : Rectangle;
	protected var _querryMap : Array;
	protected var _ICollisionData : ICollisionData;
	private var _id : String;
	
	
	public function WorldObjSimBase( id : String, bounds : Rectangle ) {

		_ICollisionData = CollisionDataProvider.instance.getCollisionData(id);
		_id = id;
		_bounds = bounds;
		_collisionImpulse = new Point();
		_collisionResult = new CollisionResult();
		_querryMap = new Array();
	}
	
	public function get width() : Number { 			// todo die die die
		return _bounds.width;
	}
	
	public function get id() : String {
		return _id;
	}
	
	public function get bounds() : Rectangle {
		return _bounds;
	}

	public function set bounds( r : Rectangle ) : void {
		_bounds = r;
	}
	
	public function querry( s : String ) : Boolean {
		return null != _querryMap[s]; // indexOf ??
	}
	
	
	public function get isConsumable():Boolean
	{
		return false;
	}
	
	public function get isMonster() : Boolean {
		return false;
	}
	
	public function get isCollideableFromBelow() : Boolean {
		return true;
	}
	
	public function onCollision(player:PlayerSim):void
	{
	}
	
	public function setProps(props:Object):void
	{
	}
	
	public function update():void
	{
	}
	
	
	public function getYat( x: Number ) : Number {
		return _bounds.top;
	}
	
	public function testCollision( iCol: ICollider ) : CollisionResult {
	
 		var r : Rectangle = iCol.bounds;
		var v : Vector2  = CollisionManager.SAT_rectXrect( r, _bounds );	
		
		
		if( v ) {
			if( _ICollisionData ) {
				
				var vTestPoints : Vector.<Point> = iCol.collisionTestPoints;
				var count : int = vTestPoints.length
				
				for( var i : int = 0; i < count; ++i ) {
					var testPoint : Point = vTestPoints[i];
					
					var localPoint : Point = testPoint.subtract(_bounds.topLeft );
					var msv : Vector2 = _ICollisionData.testPoint( localPoint );				
					
					if( msv.isNotZero ) {					
						return new CollisionResult( 0,msv,this ); 
					}
				}
				
				
			} else {
				return new CollisionResult(0,v,this) ;			
			}
		} 
		return null;
	}
	
	public function offset(p:Point):void
	{
		_bounds.x += p.x;
		_bounds.y += p.y;
		dispatchEvent( new WorldObjectEvent( WorldObjectEvent.WORLDOBJECT_MOVE) );
	}
	
	public function get position():Point
	{
		return _bounds.topLeft;
	}
	
	public function set position(p:Point):void
	{
		_bounds.x = p.x;
		_bounds.y = p.y;
		dispatchEvent( new WorldObjectEvent( WorldObjectEvent.WORLDOBJECT_MOVE ) );
	}
	
	public function get eventDispatcher():EventDispatcher
	{
		return this;
	}
	
}

class LauncherSim extends WorldObjSimBase {
	private static const IMPULSE_Y : int = -40;
	
	public function LauncherSim( type : String, bounds : Rectangle ) 
	{
		super( type, bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
		
		player.applyImpulse( new Point( 0, IMPULSE_Y ) );
	}				
}

class TrampolineSim extends WorldObjSimBase {
	
	private static const VELOCITY_X : Number = 0;
	private static const VELOCITY_Y : Number = -20;
	
	public function TrampolineSim( type : String, bounds : Rectangle ) 
	{
		super( type, bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
		player.applyImpulse( new Point( VELOCITY_X, VELOCITY_Y ) );
	}	
}

class CatapultSim extends WorldObjSimBase {
	
	private static const VELOCITY_X : Number = 36;  
	private static const VELOCITY_Y : Number = -34;
	
	public function CatapultSim( type : String, bounds : Rectangle ) 
	{
		super( type,bounds );
	}
	
	override public function onCollision( player:PlayerSim ) : void {
		player.applyImpulse( new Point( VELOCITY_X, VELOCITY_Y ) );
	}	
}

class SpringBoardSim extends WorldObjSimBase {
	
	private static const IMPULSE_Y : int = -40;
	
	public function SpringBoardSim( type : String, bounds : Rectangle ) 
	{
		super( type,bounds );
	}

	override public function onCollision( player:PlayerSim ) : void {		
		player.applyImpulse( new Point( 0, IMPULSE_Y ) );
	}			
}

class SpeedBoostCoinSim extends WorldObjSimBase  {
	
	private static const DURATION_MS : int = 3000;
	private static const SPEED_MULTIPLIER : Number = 2;
	
	
	public function SpeedBoostCoinSim( type : String, bounds : Rectangle ) {
		super(type, bounds);
		_querryMap.push('isConsumable');
	}
	
	override public function get isConsumable():Boolean
	{
		return true;
	}
	
	override public function onCollision(player:PlayerSim):void
	{
		player.addSpeedBoost( DURATION_MS, SPEED_MULTIPLIER );		
	}
}

class Token_MakePlayerBiggerSim extends WorldObjSimBase {
	
	private static const DURATION_MS : int = 5000;
	private static const SCALE_TO_APPLY : Number = 1.50;
	
	public function Token_MakePlayerBiggerSim( type : String, bounds : Rectangle ) {
		super(type,bounds);
		_querryMap.push('isConsumable');		
	}
	
	override public function get isConsumable():Boolean
	{
		return true;
	}
	
	override public function onCollision(player:PlayerSim):void
	{
		player.scale( SCALE_TO_APPLY, DURATION_MS  );		
	}
	
}

class Token_MakePlayerSmallerSim extends WorldObjSimBase {
	
	private static const DURATION_MS : int = 5000;
	private static const SCALE_TO_APPLY : Number = 0.5;
	
	public function Token_MakePlayerSmallerSim( type : String, bounds : Rectangle ) {
		super(type,bounds);
		_querryMap.push('isConsumable');
	}
	
	override public function get isConsumable():Boolean
	{
		return true;
	}
	
	override public function onCollision(player:PlayerSim):void
	{
		player.scale( SCALE_TO_APPLY, DURATION_MS );	
	}
	
}


class BrainCoinSim extends WorldObjSimBase  {
	
	private static const BRAIN_COIN_VALUE : int = 1;
	
	public function BrainCoinSim( type : String, bounds : Rectangle ) {
		super(type, bounds);
		_querryMap.push('isConsumable');
	}
	
	override public function testCollision( iCol: ICollider ) : CollisionResult {
		return super.testCollision(iCol);
	}
	
	override public function get isConsumable() : Boolean {
		return true;
	}
	
	override public function onCollision( player:PlayerSim ) : void {
		player.addCoins( BRAIN_COIN_VALUE );
	}
	
}


class ElevatorPlatformSim extends WorldObjSimBase  {
	
	private var theta : Number;
	private var lastY : Number;
	
	public function ElevatorPlatformSim( type : String, bounds : Rectangle ) {
		super(type, bounds);
		theta = 0;
		lastY = 0;
	}
	
	override public function update():void
	{
		theta += Math.PI / 80;
		var thisY : Number= 150 * Math.sin( theta ); 
		
		var delta : Number= thisY - lastY;
		lastY = thisY;
		offset( new Point( 0, delta ) );

	}
	

}

class EnemyBlobSim extends WorldObjSimBase  {
	
	private static const VELOCITY_X : Number = 1;
	
	private var pImpulse : Point;
	private var range : Number; 
	private var homeX:Number;
	private var dir:int;
	
	public function EnemyBlobSim( type : String,  bounds : Rectangle  ) {
		super(type,bounds);
		pImpulse = new Point();
		dir = -1;		// start walking left
		_querryMap.push('isMonster');
	}
	
	override public function get isMonster() : Boolean {
		return true;
	}
	
	override public function update():void
	{
		pImpulse.x = computeImpulseX();
		offset( pImpulse );
	}
	
	override public function setProps(props:Object):void
	{
		range = props.range;
		homeX = props.homeX;
	}
	
	private function computeImpulseX() : Number {
		
		if( ! isOnscreen() ) {
			return 0;
		}
		
		var newX : Number =_bounds.left + dir * VELOCITY_X;
		
		if( newX <= homeX - range ) {
			dir = 1;
			newX = homeX - range;
		} 
		else if ( newX >= homeX ) {
			dir = -1;
			newX = homeX;
		}
		return newX - _bounds.left;			
		
	}
	
	private function isOnscreen() : Boolean {
		return ScreenContainer.Instance().isOnscreen( _bounds.left );
	}
	
	
}

class LevelPlatformDataSim extends WorldObjSimBase  {
	
	public function LevelPlatformDataSim( type : String, bounds : Rectangle ) {		
		super(type,bounds);
	}		
}

class SlopedPlatformDataSim extends WorldObjSimBase {
	
	private static const VERT_INDEX_UL : int = 0;
	private static const VERT_INDEX_UR : int = 1;
	private static const VERT_INDEX_LR : int = 2;
	private static const VERT_INDEX_LL : int = 3;
	
	private static const PlatformHeight : int = 25;
	private var sliceHeight : Number;
	private var slope : Number;
	private var rotationAngle : Number;
	private var _verts : Array;
	private var _center : Point;
	private var buildVerts : Function;
	
	public function SlopedPlatformDataSim( type : String, bounds : Rectangle  ) {
		
		super( type,bounds );

		_verts = new Array(4);
		for( var i : int = 0; i < 4; ++i ) {
			_verts[i] = new Vector2();
		}
		
		var re : RegExp = /_\d+/;
		var rotation : Array = type.match( re );
		
		if( rotation && rotation.length > 0 ) {
			//	trace( rotation[0] );			
			var sR:String = rotation[0].substr(1);
			rotationAngle = int(sR);
			
			if( rotationAngle > 180 ) {  // upslope
				sliceHeight = _bounds.height - PlatformHeight * Math.sin( rotationAngle );
				buildVerts = buildVerts_ascendingPlatform;
			} else {
				sliceHeight = PlatformHeight * Math.sin( rotationAngle );
				buildVerts = buildVerts_descendingPlatform;
			}
			
		} else {
			trace ("wtf: SlopedPlatformData ctr");
			rotationAngle = 0;
			sliceHeight = _bounds.height;
		}
		
		_center = new Point();
		computeCenter();
		buildVerts();
		slope = computeSlope();		// must call buildVerts at least once before computeSlop is valid				
	}
	
	private function computeCenter( ) : void {		
		var r : Rectangle = _bounds;		
		_center.x = (r.left + r.right) / 2;
		_center.y = (r.top  + r.bottom ) / 2;
	}
	
	override public function getYat( x : Number ) : Number {		
		return (x - _verts[VERT_INDEX_UL].x + _center.x) * slope + _verts[VERT_INDEX_UL].y + _center.y; 
	}
	
/*
	override public function testCollision( iCol : ICollider ) : CollisionResult {
		
		var r : Rectangle = iCol.bounds;
		computeCenter();
		buildVerts();
		var I : ICollisionData  = new CollisionDataProvider().getCollisionData( id );

		var msv : Vector2 = CollisionManager.SAT_vertsXrect( _center, _verts, r );
		
		if( msv ) {
			var dummycode :int  = 0;
			return new CollisionResult( dummycode, msv, this) ;
		}
		return null;		
	}	
*/	
	private function computeSlope( ) : Number {
		return (_verts[VERT_INDEX_UR].y - _verts[VERT_INDEX_UL].y) / (_verts[VERT_INDEX_UR].x - _verts[VERT_INDEX_UL].x);
	} 
	
	private function buildVerts_descendingPlatform() : void {
		_verts[VERT_INDEX_UL].x = _bounds.x - _center.x;
		_verts[VERT_INDEX_UL].y = _bounds.y - _center.y;
		_verts[VERT_INDEX_UR].x = _bounds.x + _bounds.width - _center.x;
		_verts[VERT_INDEX_UR].y = _bounds.y + _bounds.height - sliceHeight - _center.y;
		_verts[VERT_INDEX_LR].x = _bounds.x + _bounds.width - _center.x;
		_verts[VERT_INDEX_LR].y = _bounds.y + _bounds.height - _center.y;
		_verts[VERT_INDEX_LL].x = _bounds.x - _center.x;
		_verts[VERT_INDEX_LL].y = _bounds.y + sliceHeight - _center.y;
	}
	
	private function buildVerts_ascendingPlatform() : void {
		_verts[VERT_INDEX_UL].x = _bounds.x - _center.x;
		_verts[VERT_INDEX_UL].y = _bounds.y + _bounds.height - sliceHeight - _center.y;
		_verts[VERT_INDEX_UR].x = _bounds.x + _bounds.width - _center.x;
		_verts[VERT_INDEX_UR].y = _bounds.y - _center.y;
		_verts[VERT_INDEX_LR].x = _bounds.x + _bounds.width - _center.x;
		_verts[VERT_INDEX_LR].y = _bounds.y + sliceHeight - _center.y;
		_verts[VERT_INDEX_LL].x = _bounds.x - _center.x;
		_verts[VERT_INDEX_LL].y = _bounds.y + _bounds.height - _center.y;		
	}
}