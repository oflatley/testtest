package util
{
	
	import events.CollisionEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import sim.PlayerSim;
	import sim.WorldObject;

	public class ObjectPool
	{
		private static var theObjectPool : ObjectPool = null;		
		private var poolMap : Array;
				
		public static function Instance() : ObjectPool {
			if( null == theObjectPool ) {
				theObjectPool = new ObjectPool(new SingletonEnforcer());
			}
			return theObjectPool;
		}
				
		public function Initialize(spec:Array, screenContainer : ScreenContainer ) : void {		
			
			
			for each( var elem : Object in spec ) {
				
				var a : Array = new Array();
				poolMap[elem.type] = a;
				
				for( var i : int = 0; i < elem.count; ++i ) {
					var wo : WorldObject = new WorldObject( elem.type );
					wo.deactivate();
					a.push( wo );
					screenContainer.addChild(wo);
				}
			}
		}
		
		
		public function Clean() : void {
			poolMap.slice( 0, poolMap.length );
		}
		
		public function GetObj( type:String ) : WorldObject {

			var a : Array = poolMap[type];
			
			if( a.length ) {
				return a.pop(); 
			}

			trace( "@@@@@ COULD NOT ALLOC TYPE:" + type + "FROM OBJECT POOL @@@@@" );
			return null;
		}
		
		public function RecycleObj( wo : WorldObject ) : void {
			wo.deactivate();
			var a : Array = poolMap[ wo.getType() ];
			a.push( wo );
		}
	
		public function ObjectPool(_:SingletonEnforcer) {
			poolMap = new Array();
		}
		
		public function getProp( type:String, name:String ) : Object {
			var wo : WorldObject = poolMap[type][0];
			return wo[name];
		}

		public function debug( ) : void {
			var s : String = new String();
			
			for( var it : String in poolMap ) {
				var a : Array = poolMap[it];
				s += it + ':' + a.length + ', ';	
			}
			trace(s);
		}
	}
}

class SingletonEnforcer {}