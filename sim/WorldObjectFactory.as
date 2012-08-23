package sim
{
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




import events.CollisionEvent;
import events.WorldObjectEvent;

import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import interfaces.IWorldObject;

import sim.PlayerSim;

import util.CollisionManager;
import util.CollisionResult;
import util.ScreenContainer;
import util.Vector2;





class WorldObjSimBase extends EventDispatcher implements IWorldObject {
	
	//protected var _mc : MovieClip;
	protected var _collisionImpulse : Point;
	protected var _collisionResult : CollisionResult;
	protected var _bounds : Rectangle;
	protected var _querryMap : Array;
	private var _id : String;
	

	
	public function WorldObjSimBase( id : String, bounds : Rectangle ) {

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
	
	public function testCollision( r: Rectangle ) : CollisionResult {
	
		var v : Vector2  = CollisionManager.SAT_rectXrect( r, _bounds );		
		return v ? new CollisionResult(0,v,this) : null;
/*		
		var cr : CollisionResult = CollisionManager.SAT_rxr( r, _bounds, new Vector2(0,0) );
		
		if( cr.Intersect ) {
			cr.collidedObj = this;
			return cr;
		}
		return null;
*/		
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
	
	public function get eventDispatcher():IEventDispatcher
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
	
	override public function testCollision( r : Rectangle ) : CollisionResult {
				
		computeCenter();
		buildVerts();

		var msv : Vector2 = CollisionManager.SAT_vertsXrect( _center, _verts, r );
		
		if( msv ) {
			var dummycode :int  = 0;
			return new CollisionResult( dummycode, msv, this) ;
		}
		return null;		
	}	
	
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
/*

public class WorldObject extends EventDispatcher
{
private var debugBounds:Sprite;
//private var mc:MovieClip;
private var objData : IWorldObjectData;
private var _type : String;
//private var _bounds : Rectangle;


public function WorldObject( type:String, r:Rectangle  )
{
_bounds = r;
_type = type;
//mc = createMC(type);

objData = createWorldObjData( _type, r );	

if( null == objData ) {
trace("ERROR, could not create objData for: " + _type );
}

debugBounds = new Sprite();
debugBounds.graphics.lineStyle(2, 0x0000FF);
debugBounds.graphics.drawRect( r.x, r.y, r.width, r.height );
}

public function get isMonster() : Boolean {
return objData.isMonster;
}

public function get isConsumable() : Boolean {
return objData.isConsumable;
}

public function get isCollideableFromBelow() : Boolean {
return objData.isCollideableFromBelow;
}

public function onCollision( player : PlayerSim ) : void {
objData.onCollision( player );
}

public function getType() : String {
return _type;
}

public function offset( p:Point ) : void {
//_bounds.x += p.x;
//_bounds.y += p.y;
objData.offset(p);
dispatchEvent( WorldObjectEvent.WORLDOBJECT_MOVE );
}

public function set position( p : Point ) : void {
//_bounds.x = p.x;
//_bounds.y = p.y;
objData.position(p);
dispatchEvent( WorldObjectEvent.WORLDOBJECT_MOVE );
}

public function get position() : Point {
return objData.position; //_bounds.topLeft;			
}
/*
public function SetPosition( p:Point ) : void {
mc.x = p.x
mc.y = p.y;	
debugBounds.x = p.x;
debugBounds.y = p.y;
}
*/	
/*
public function get width():Number
{
	return _bounds.width;
}		

/*		
public function activate() : void {
mc.visible = true;
}

public function deactivate() : void {
mc.visible = false;

}
*/	
/*
public function update() : void {
	
	
	var pImpulse : Point = objData.update();
	if ( pImpulse ) {
		offset( pImpulse );
		
		//	mc.x += pImpulse.x;
		//	mc.y += pImpulse.y;		
		//	debugBounds.x += pImpulse.x;
		//	debugBounds.y += pImpulse.y;
	}
}

public function setProps( props:Object ) : void  {
	objData.setProps( props );
}


//		public function GetBounds() : Rectangle {			
//			return new Rectangle( mc.x,mc.y,mc.width,mc.height );
//		}

//		public function AddToScene( scene:Sprite ) : void {
//			scene.addChild( mc );
//			scene.addChild(debugBounds);
//		}

public function getYat( xWorld:Number ) : Number {			
	return objData.getYat( xWorld );
}

public function testCollision( r : Rectangle ) : CollisionResult {
	
	var cr : CollisionResult = objData.testCollision(r);
	if( cr ) {
		cr.collidedObj = this;	// TODO, pass iface objData
	}
	return cr;
}
	
	
}
}


*/
