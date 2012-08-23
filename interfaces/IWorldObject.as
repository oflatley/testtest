package interfaces {
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sim.PlayerSim;
	
	import util.CollisionResult;
	
	public interface IWorldObject {
		
		function get id() : String;
		
		function get bounds() : Rectangle;
		function set bounds( r:Rectangle ) : void ;
		function get position() : Point;
		function set position( p:Point ) : void ;
		function offset( p : Point ) : void ;
		
		function setProps( props:Object ) : void ;
		function getYat( x:Number ) : Number;
		function testCollision( r: Rectangle ) : CollisionResult;
		function update() : void;
		function onCollision( player : PlayerSim ) : void;
		
		function get isConsumable() : Boolean;
		function get isMonster() : Boolean;
		function get isCollideableFromBelow() : Boolean;
		function querry( s : String ) : Boolean; 
	
		function get eventDispatcher() : IEventDispatcher;
		function get width() : Number; 				// TODO -- kill this 
		
	}
}