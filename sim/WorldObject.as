package sim
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;	

	public class WorldObject
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
		
		public function testCollision( r : Rectangle ) : Boolean {
			return objData.testCollision( r );
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
import util.ScreenContainer;


interface IWorldObjectData {
	function setProps( props:Object ) : void ;
	function getYat( x:Number ) : Number;
	function testCollision( r : Rectangle ) : Boolean;
	function update() : Point;
	function onCollision( player : PlayerSim ) : void;
	function get isConsumable() : Boolean;	
}


class WorldObjSimBase implements IWorldObjectData {
	
	protected var _mc : MovieClip;
	
	public function WorldObjSimBase( mc : MovieClip ) {
		_mc = mc;
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
	
	public function testCollision( r: Rectangle ) : Boolean {
		return getBounds().intersects(r);
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

	private static const PlatformHeight : int = 25;
	private var ur : Point;
	private var ul : Point;
	private var sliceHeight : Number;
	private var slope : Number;
	private var rotationAngle : Number;
	
	public function SlopedPlatformData( type : String , mc : MovieClip ) {

		super(mc);
		
		var re : RegExp = /_\d+/;
		var rotation : Array = type.match( re );
		
		if( rotation && rotation.length > 0 ) {
		//	trace( rotation[0] );
			
			var sR:String = rotation[0].substr(1);
			rotationAngle = int(sR);
			ul  = new Point();
			ur  = new Point();
			
			if( 0 != rotationAngle ) {
				
				sliceHeight = mc.height - PlatformHeight * Math.sin( rotationAngle );				
				
				if( rotationAngle > 180 ) {	// upslope				
					
					ul.x = mc.x;
					ul.y = mc.y + sliceHeight;
					
					ur.x = mc.x + mc.width;
					ur.y = mc.y - mc.height;
					
					//trace( ul.x + ' ' + ul.y + ' '  + ur.x + ' ' + ur.y );
				}
				else { // ... rotationAngle < 180 --> downslope
					sliceHeight = PlatformHeight * Math.sin( rotationAngle );
					
					ul.x = mc.x;
					ul.y = mc.y;
					
					ur.x = mc.x + mc.width;
					ur.y = mc.y + sliceHeight;
					
					//trace( ul.x + ' ' + ul.y + ' '  + ur.x + ' ' + ur.y );			
				}
				
				slope = (ur.y-ul.y) / (ur.x-ul.x);
			} 
		}
		else {
			trace ("wtf: SlopedPlatformData ctr");
		}
		
	}

	override public function getYat( x : Number ) : Number {
		
		return (x - ul.x) * slope + ul.y; 
	}
	
	override public function testCollision( r : Rectangle ) : Boolean { 
		if( getBounds().intersects(r) ) {
			if( r.containsPoint( ul ) || r.containsPoint(ur) || r.containsPoint( new Point( ul.x, ul.y + sliceHeight ) ) || r.containsPoint( new Point( ur.x, ur.y + sliceHeight ) ) ) {
				return true;
			}
			
			var yatx_top : Number = getYat( r.left );
			var yatx_bot : Number = yatx_top + sliceHeight;
		
			if( r.top > yatx_top && r.top < yatx_bot ) {
				return true;
			}
				
			if( r.bottom > yatx_top && r.bottom < yatx_bot ) {
				return true;
			}
			
			yatx_top = getYat( r.right );
			yatx_bot = yatx_top + sliceHeight;			
			
			if( r.top > yatx_top && r.top < yatx_bot ) {
				return true;
			}
			
			if( r.bottom > yatx_top && r.bottom < yatx_bot ) {
				return true;
			}
		}

		return false;	
	}		
	
}

