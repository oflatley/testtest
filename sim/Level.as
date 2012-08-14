package sim
{
	import events.CollisionEvent;
	import events.ScreenContainerEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import sim.WorldObject;
	
	import util.CollisionManager;
	import util.CollisionResult;
	import util.ObjectPool;
	import util.ScreenContainer;
	
	public class Level
	{
		private static const nBucketsOffscreenOnRight : int = 1;
		private static const bucketSlices : int = 96;
		private static const bucketWidth : int = 960 / bucketSlices ;
		private var buckets_startX:Array;
		private var buckets_endX:Array;
		private var nLeftmostBucketX : int;
		private var _activeObjects:Array;
		private var collisionsToProcess : Array; 
		private var _scrollSignaled : Boolean;
		private var _ndxCurrentScreenSlice : int;
	
		public function Level(_data:Object, _collisionMgr : CollisionManager)
		{
			_scrollSignaled = false;
			
			_collisionMgr.addEventListener( CollisionEvent.PLAYERxWORLD, onPlayerxWorldCollision );
			ScreenContainer.Instance().addEventListener( ScreenContainerEvent.SLICE_SCROLL, onSliceScroll );
			
			ScreenContainer.Instance().SetSliceCount(bucketSlices);	
			collisionsToProcess = new Array();	
			var typeWidths : Array = new Array();
			
			_activeObjects = new Array();
			buckets_startX = new Array();
			buckets_endX = new Array();
			
			// find max x
			var maxX : int = 0;
			var maxX0 : int = 0;
			for each( var elem:Object in _data ) {
				
				if( null == typeWidths[elem.type] ) {
					typeWidths[elem.type] = ObjectPool.Instance().getProp( elem.type, "width" ) as Number;
				}
								
				var width : Number = typeWidths[elem.type];
				var thisMaxX : int = elem.x; 
				maxX = Math.max( maxX, thisMaxX );
				
	 			var thisMaxX0 : int = thisMaxX + width + 0.5; 
				maxX0 = Math.max( maxX0, thisMaxX0 );

				//trace(thisMaxX + ' ' + maxX + ' ---- ' + thisMaxX0 + ' ' + maxX0 );			
			}
			
			var nBuckets : int = maxX / bucketWidth;
			
			for( var n : int = 0; n <= nBuckets; ++n ) {
				buckets_startX.push( new Array() );
			}
			
			var nBucketsEnd : int = maxX0 / bucketWidth;
			
			for( n = 0; n <= nBucketsEnd; ++n ) {
				buckets_endX.push( new Array() );
			}
			
			for each ( var elem2:Object in _data ) {			
				var info : ObjBucketInfo = new ObjBucketInfo( elem2.type, elem2.x, elem2.y, elem2.x + typeWidths[elem2.type], elem2.props );			
				var nWhichBucket : int = elem2.x / bucketWidth;
				buckets_startX[nWhichBucket].push( info );				
			}	
						
			nLeftmostBucketX = 0;			

			for( var n1 : int = 0; n1 < bucketSlices + nBucketsOffscreenOnRight; ++n1  ) {
				addToActiveObjects( buckets_startX[n1] ) ;
			}
		}
		
		private function onSliceScroll( event : ScreenContainerEvent ) : void {

			_scrollSignaled = true;
			_ndxCurrentScreenSlice = event.ndxSlice;
		}
		
		private function onPlayerxWorldCollision( event : CollisionEvent ) : void {
 			collisionsToProcess.push( event.collisionResult );
		}
		
		private function addToActiveObjects( a : Array ) : void {

			for each ( var info : ObjBucketInfo in a ) {
				
				// get world object from object pool and initialize
				var wo : WorldObject = ObjectPool.Instance().GetObj( info.type );
				wo.activate();
				wo.SetPosition( new Point( info.x0, info.y ) );
				
				if( info.props ) {
					wo.setProps( info.props );
				}
				
				// add to the active object list --> e.g. now there will be updates and collision detection for wo
				activeObjects.push( wo );
				
				// store when they should be removed from level
				var x0 : int = Math.floor(wo.GetBounds().right); 
				var a : Array = buckets_endX[Math.floor(x0/bucketWidth)];
				a.push(wo);
			}
		}
		
		private function removeFromActiveObjects( wo : WorldObject ) : Boolean  {
			for( var i : int = 0; i < activeObjects.length; ++i ) {
				if( wo == activeObjects[i] ) {
					break;
				}
			}
			
			if( i < activeObjects.length ) {
				activeObjects.splice(i, 1);
				return true;
			}
			trace("unexpected: object not removed from Level");
			return false;
		}
		
		private function removeObject( woToRemove:WorldObject ) : void {

			removeFromActiveObjects( woToRemove );	
			ObjectPool.Instance().RecycleObj( woToRemove );
			// do not bother removing from buckets_endX --> do that between levels			
		}
		
		
		public function update( playerPosition : Point ) : void {

			var ar : Array;
			
			for each( var cr : CollisionResult in collisionsToProcess ) {
				if( cr.collidedObj.isConsumable) {
					removeObject( cr.collidedObj );
					var ndx : int = cr.collidedObj.GetBounds().right / bucketWidth;
					ar = buckets_endX[ndx];
					for( var i : int = 0 ; i < ar.length; ++i ) {
						if( cr.collidedObj == ar[i] ) {
							break;
						}	
					}
					if( i < ar.length ) {
						ar.splice( i , 1 );
					}
					else {
						trace("could not remove consumble object from buckets_endX");
					}							
				}
			}			
			collisionsToProcess.length = 0;
					
			if( _scrollSignaled ) {
				_scrollSignaled = false;
				//trace( "signaled: " + playerPosition.x + ' ' + _ndxCurrentScreenSlice  );
				
				// remove objects that have now gone offscreen to the left
				ar = buckets_endX[_ndxCurrentScreenSlice-1];
				for each( var wo : WorldObject in ar ) {	
					
					//trace( ' -- Removing:' + wo.GetBounds().left + ' ' + wo.GetBounds().right ); 
					
					removeObject(wo);					
					if( wo.GetBounds().left > playerPosition.x ) {
						trace("asdgasdgasd");
					}
				}		
				
				// add new objects just offscreen to the right
				addToActiveObjects( buckets_startX[_ndxCurrentScreenSlice + bucketSlices] );
				nLeftmostBucketX += bucketWidth;				
				
				//ObjectPool.Instance().debug();  									
			}
			
			// update all active objects
			for each ( var wObj : WorldObject in activeObjects ) {
				wObj.update();
			}				
		}

		public function get activeObjects():Array
		{
			return _activeObjects;
		}
	}
}

class ObjBucketInfo {
	public var type : String;
	public var x0 : Number;
	public var x1 : Number;
	public var y : Number;
	public var props : Object;
	
	public function ObjBucketInfo( _type : String, _x0 : Number, _y : Number, _x1 : Number, _props : Object ) {
		type = _type;
		x0 = _x0;
		x1 = _x1;
		y = _y;
		props = _props;
	}
}