package sim
{
	import events.CollisionEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import util.CollisionResult;

	public class WorldObject extends EventDispatcher
	{
		private var debugBounds:Sprite;
		private var mc:MovieClip;
		private var objData : IWorldObjectData;
		private var type : String;
		
		
		public function WorldObject( _type:String  )
		{
			type = _type;
			mc = createMC(type);
			objData = createWorldObjData( type, mc );		
			debugBounds = new Sprite();
			debugBounds.graphics.lineStyle(2, 0x0000FF);
			var r : Rectangle = GetBounds();
			debugBounds.graphics.drawRect(r.x, r.y, r.width, r.height );
		}

		public function get isConsumable() : Boolean {
			return objData.isConsumable;
		}
		
		public function onCollision( player : PlayerSim ) : void {
			objData.onCollision( player );
		}
		
		public function getType() : String {
			return type;
		}
		
		public function SetPosition( p:Point ) : void {
			mc.x = p.x
			mc.y = p.y;	
			debugBounds.x = p.x;
			debugBounds.y = p.y;
		}
		
		public function get width():Number
		{
			return mc.width;
		}		
		
		public function activate() : void {
			mc.visible = true;
		}
		
		public function deactivate() : void {
			mc.visible = false;
				
		}
		
		public function update() : void {
				
			
			var pImpulse : Point = objData.update();
			if ( pImpulse ) {
				mc.x += pImpulse.x;
				mc.y += pImpulse.y;		
				debugBounds.x += pImpulse.x;
				debugBounds.y += pImpulse.y;
			}
		}
		
		public function setProps( props:Object ) : void  {
			objData.setProps( props );
		}
		
		
		public function GetBounds() : Rectangle {			
			return new Rectangle( mc.x,mc.y,mc.width,mc.height );
		}
		
		public function AddToScene( scene:Sprite ) : void {
			scene.addChild( mc );
			scene.addChild(debugBounds);
		}

		public function getYat( xWorld:Number ) : Number {			
			return objData.getYat( xWorld );
		}
		
		public function testCollision( r : Rectangle ) : CollisionResult {

			var cr : CollisionResult = objData.testCollision(r);
			if( cr ) {
				cr.collidedObj = this;	// TODO, pass iface objData
				//dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
				//return true;
			}
			return cr;
			//return false;
			//return objData.testCollision( r );
		}
		
		private function createMC(type:String):MovieClip
		{	
			var mc:MovieClip;
			
			switch(type) {		
				case "SpringBoard": return new SpringBoard(); break;
				case "Brain":	return new Brain(); break;
				case "SpeedBoostCoin": return new SpeedBoostCoin(); break;
				case "Enemy_0": return new Enemy_0(); break;
				case "Column": return new Column(); break; 
				case "PlatformShort_elev": return new PlatformShort_0; break;
				case "PlatformShort_0": return new PlatformShort_0(); break;
				case "PlatformMedium_0": return new PlatformMedium_0(); break;
				case "PlatformLong_0": return new PlatformLong_0(); break;							
				case "PlatformMedium_15": return new PlatformMedium_15(); break;	
				case "PlatformMedium_345": return new PlatformMedium_345(); break;
				default:
					trace("unknown type encountered in createWorldObject");					
					return new MovieClip();
			}
			
		}	
		
		private function createWorldObjData( type:String, mc:MovieClip ) : IWorldObjectData {

			switch(type) {	
				case "SpringBoard": return new SpringBoardSim(mc);
				case "SpeedBoostCoin":
					return new SpeedBoostCoinSim( mc ); 
				case "Brain":
					return new BrainCoin(mc);
				case "Enemy_0":
					return new EnemyBlob(mc);
				case "PlatformShort_elev":
					return new ElevatorPlatform( mc );
				case "Column":  
				case "PlatformShort_0":
				case "PlatformMedium_0":
				case "PlatformLong_0": 			
					return new LevelPlatformData( mc );
					break;
				case "PlatformMedium_15": 	
				case "PlatformMedium_345": 
					return new SlopedPlatformData(type,mc);
					break;
				default:
					trace("unknown type encountered in createWorldObjData");					
			}
			return null;	
		}
	}
}

import events.CollisionEvent;

import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import flashx.textLayout.operations.MoveChildrenOperation;

import sim.PlayerSim;

import util.CollisionManager;
import util.CollisionResult;
import util.PolygonCollisionResult;
import util.ScreenContainer;
import util.Vector2;


interface IWorldObjectData {
	function setProps( props:Object ) : void ;
	function getYat( x:Number ) : Number;
	//function testCollision( r : Rectangle ) : Boolean;
	function testCollision( r: Rectangle ) : CollisionResult;
	function update() : Point;
	function onCollision( player : PlayerSim ) : void;
	function get isConsumable() : Boolean;	
}


class WorldObjSimBase extends EventDispatcher implements IWorldObjectData {
	
	protected var _mc : MovieClip;
	protected var _collisionImpulse : Point;
	protected var _collisionResult : CollisionResult;
	
	public function WorldObjSimBase( mc : MovieClip ) {
		_mc = mc;
		_collisionImpulse = new Point();
		_collisionResult = new CollisionResult();
	}
	
	protected function getBounds() : Rectangle {
		return new Rectangle( _mc.x, _mc.y, _mc.width, _mc.height );
	}
	
	public function get isConsumable():Boolean
	{
		return false;
	}
	
	public function onCollision(player:PlayerSim):void
	{
	}
	
	public function setProps(props:Object):void
	{
	}
	
	public function update():Point
	{
		return null;
	}
	
	
	public function getYat( x: Number ) : Number {
		return _mc.y;
	}
	
	public function testCollision( r: Rectangle ) : CollisionResult {

		var b : Boolean = getBounds().intersects(r)	;		
		var msv : Vector2 = CollisionManager.SAT( r, getBounds() );
				
		if( msv ) {
			
			var code :int  = 0;
			return new CollisionResult( code, msv) ;
			// dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, new CollisionResult( code, _collisionImpulse, null) ) );
			//return true;
		}
		return null;
		//return false;	
	}
}

class SpringBoardSim extends WorldObjSimBase {
	
	private static const IMPULSE_Y : int = -40;

	public function SpringBoardSim( mc : MovieClip ) {		
		super(mc)
	}
	
	override public function onCollision( player:PlayerSim ) : void {
	
		player.applyImpulse( new Point( 0, IMPULSE_Y ) );
	}			
}

class SpeedBoostCoinSim extends WorldObjSimBase implements IWorldObjectData {
	
	private static const DURATION_MS : int = 3000;
	private static const SPEED_MULTIPLIER : Number = 2;
	
	
	public function SpeedBoostCoinSim(mc:MovieClip) {
		super(mc);
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

class BrainCoin extends WorldObjSimBase implements IWorldObjectData {
	
	private static const BRAIN_COIN_VALUE : int = 1;
	
	public function BrainCoin( mc : MovieClip ) {
		super(mc);	
	}
	
	override public function get isConsumable() : Boolean {
		return true;
	}
	
	override public function onCollision( player:PlayerSim ) : void {
		player.addCoins( BRAIN_COIN_VALUE );
	}
	
}


class ElevatorPlatform extends WorldObjSimBase implements IWorldObjectData {

	private var theta : Number;
	private var lastY : Number;
	
	public function ElevatorPlatform( mc : MovieClip ) {
		super(mc)
		theta = 0;
		lastY = 0;
	}
			
	override public function update():Point
	{
		// TODO Auto Generated method stub
		theta += Math.PI / 80;
		var thisY : Number= 150 * Math.sin( theta ); 
		
		var delta : Number= thisY - lastY;
		lastY = thisY;
		return new Point( 0, delta );
	}

}

class EnemyBlob extends WorldObjSimBase implements IWorldObjectData {

	private static const VELOCITY_X : Number = 1;
	
	private var pImpulse : Point;
	private var range : Number; 
	private var homeX:Number;
	private var dir:int;

	public function EnemyBlob( mc : MovieClip ) {
		super(mc);
		pImpulse = new Point();
		dir = -1;		// start walking left
	}
	
	override public function update():Point
	{
		pImpulse.x = computeImpulseX();
		return pImpulse;
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
		
		var newX : Number = getBounds().left + dir * VELOCITY_X;
		
		if( newX <= homeX - range ) {
			dir = 1;
			newX = homeX - range;
		} 
		else if ( newX >= homeX ) {
			dir = -1;
			newX = homeX;
		}
		return newX - getBounds().left;			
		
	}
	
	private function isOnscreen() : Boolean {
  		return ScreenContainer.Instance().isOnscreen( getBounds().left );
	}
	

}

class LevelPlatformData extends WorldObjSimBase implements IWorldObjectData {
	
	public function LevelPlatformData( mc : MovieClip ) {		
		super(mc);
	}		
}

class SlopedPlatformData extends WorldObjSimBase implements IWorldObjectData {

	private static const VERT_INDEX_UL : int = 0;
	private static const VERT_INDEX_UR : int = 1;
	private static const VERT_INDEX_LR : int = 2;
	private static const VERT_INDEX_LL : int = 3;
	
	private static const PlatformHeight : int = 25;
	private var sliceHeight : Number;
	private var slope : Number;
	private var rotationAngle : Number;
	private var _verts : Array;
	private var buildVerts : Function;
	
	public function SlopedPlatformData( type : String , mc : MovieClip ) {

		super(mc);
		
		_verts = new Array(4);
		for( var i : int = 0; i < 4; ++i ) {
			_verts[i] = new Point();
		}
		
		var re : RegExp = /_\d+/;
		var rotation : Array = type.match( re );
		
		if( rotation && rotation.length > 0 ) {
		//	trace( rotation[0] );			
			var sR:String = rotation[0].substr(1);
			rotationAngle = int(sR);

			if( rotationAngle > 180 ) {  // upslope
				sliceHeight = mc.height - PlatformHeight * Math.sin( rotationAngle );
				buildVerts = buildVerts_ascendingPlatform;
			} else {
				sliceHeight = PlatformHeight * Math.sin( rotationAngle );
				buildVerts = buildVerts_descendingPlatform;
			}
			
		} else {
			trace ("wtf: SlopedPlatformData ctr");
			rotationAngle = 0;
			sliceHeight = mc.height;
		}
		
		buildVerts();
		slope = computeSlope();		// must call buildVerts at least once before computeSlop is valid				
	}
	
	
		
	override public function getYat( x : Number ) : Number {
		
		return (x - _verts[VERT_INDEX_UL].x) * slope + _verts[VERT_INDEX_UL].y; 
	}
	
	//override public function testCollision( r : Rectangle ) : Boolean { 
	override public function testCollision( r : Rectangle ) : CollisionResult {
		
		var code : int = 0;
		
		buildVerts();
		if( getBounds().intersects(r) ) {
			if( r.containsPoint( _verts[VERT_INDEX_UL] ) || r.containsPoint(_verts[VERT_INDEX_UR]) || r.containsPoint(_verts[VERT_INDEX_LR]) || r.containsPoint(_verts[VERT_INDEX_LL]) ) {
				trace('collide 0');
				return _collisionResult;
			}
			
			var yatx_top : Number = getYat( r.left );
			var yatx_bot : Number = yatx_top + sliceHeight;
		
			if( r.top > yatx_top && r.top < yatx_bot ) {
				trace('collide 1');

				return _collisionResult;
			}
				
			if( r.bottom > yatx_top && r.bottom < yatx_bot ) {
				trace('collide 2');

				return _collisionResult;
			}
			
			yatx_top = getYat( r.right );
			yatx_bot = yatx_top + sliceHeight;			
			
			if( r.top > yatx_top && r.top < yatx_bot ) {
				trace('collide 3');

				return _collisionResult;
			}
			
			if( r.bottom > yatx_top && r.bottom < yatx_bot ) {
				trace('collide 4');

				return _collisionResult;
			}
		}
trace('nope');
		return null;	
	}	
	
	private function computeSlope( ) : Number {
		return (_verts[VERT_INDEX_UR].y - _verts[VERT_INDEX_UL].y) / (_verts[VERT_INDEX_UR].x - _verts[VERT_INDEX_UL].x);
	} 
	
	private function buildVerts_descendingPlatform() : void {
		_verts[VERT_INDEX_UL].x = _mc.x;
		_verts[VERT_INDEX_UL].y = _mc.y;
		_verts[VERT_INDEX_UR].x = _mc.x + _mc.width;
		_verts[VERT_INDEX_UR].y = _mc.y + _mc.height - sliceHeight;
		_verts[VERT_INDEX_LR].x = _mc.x + _mc.width;
		_verts[VERT_INDEX_LR].y = _mc.y + _mc.height;
		_verts[VERT_INDEX_LL].x = _mc.x;
		_verts[VERT_INDEX_LL].y = _mc.y + sliceHeight;
	}
	
	private function buildVerts_ascendingPlatform() : void {
		_verts[VERT_INDEX_UL].x = _mc.x;
		_verts[VERT_INDEX_UL].y = _mc.y + _mc.height - sliceHeight;
		_verts[VERT_INDEX_UR].x = _mc.x + _mc.width;
		_verts[VERT_INDEX_UR].y = _mc.y;
		_verts[VERT_INDEX_LR].x = _mc.x + _mc.width;
		_verts[VERT_INDEX_LR].y = _mc.y + sliceHeight;
		_verts[VERT_INDEX_LL].x = _mc.x;
		_verts[VERT_INDEX_LL].y = _mc.y + _mc.height;		
	}
	
	
}

