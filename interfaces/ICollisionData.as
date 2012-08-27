package interfaces
{
	import flash.geom.Point;
	
	import util.Vector2;

	public interface ICollisionData
	{
		//function get data() : Array;
		function testPoint( p : Point ) : Vector2 ;
		function testxy( x : int, y : int ) : Vector2;
		
		
	}
}