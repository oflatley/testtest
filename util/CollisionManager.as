package util
{
	
	import events.CollisionEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sim.PlayerSim;
	import sim.WorldObject;
	
	public class CollisionManager  extends EventDispatcher
	{
		
		
		public function CollisionManager() {
		}

		public function update( player:PlayerSim, activeWorldObjects:Array ) : void  {

			// TODO broad culling of objects based on screen/world slice
			
			var playerBounds : Rectangle = player.getBounds();
			var results:Array = new Array();	
			
			for each( var wo : WorldObject in activeWorldObjects ) {
				
				var cr : CollisionResult = wo.testCollision( playerBounds ); 
				if( cr ) {
					results.push(cr);
				}
			}

			for each( cr in results ) {
				this.dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
			}
			
//			switch ( player.moveState ) {
//				case PlayerSim.MOVESTATE_JUMPING: doCollisionsWalking( player, worldObjects ); break;
//				case PlayerSim.MOVESTATE_WALKING: doCollisionsWalking( player, worldObjects ) ; break;
//				default: trace("unknown fasdjkhgnsadl;ingbsadlik");					
//			}
		}
		
		private function doCollisionsJumping( player:PlayerSim, worldObjects:Array ) : void  {
			
 		}

		private function doCollisionsWalking( player:PlayerSim, activeObjects:Array ) : void  {
		
			var playerBounds : Rectangle = player.getBounds();
			var results:Array = new Array();
			
			for each( var wo : WorldObject in activeObjects ) {
				
				var cr : CollisionResult = wo.testCollision( playerBounds ); 
				if( cr ) {
					results.push(cr);
				}
				
				/*				
				
				
				// TODO, send event instead of returning array of results
				var woBounds : Rectangle = wo.GetBounds();
				
				if( wo.testCollision( playerBounds ) ) {
						

  					var collisionCode:int = getCollisionCodeWalking( playerBounds, woBounds ); 
					
					var impulse:Vector2 = new Vector2(0,0);
					if( collisionCode & CollisionResult.RIGHTCODE ) {
						impulse.x = woBounds.left - playerBounds.right;
					}
					
					if( collisionCode & CollisionResult.BOTTOMCODE ) {
						impulse.y = wo.getYat(playerBounds.left) - playerBounds.bottom ;
					}
					
					results.push( new CollisionResult( collisionCode, impulse, wo ) );

				}
				*/
			}			
			for each( cr  in results ) {
				this.dispatchEvent( new CollisionEvent( CollisionEvent.PLAYERxWORLD, cr ) );
			}
		}

		// return value only valid if an a and b overlap
		private function getIntersectionCode( a:Rectangle, b:Rectangle ) : int {
			if( a.left < b.left ) {
				if( a.top < b.top )	return 1;
				if( a.bottom > b.bottom ) return 2;
				return 3;
			}

			if( a.right > b.right ) {
				if( a.top < b.top )	return 4;
				if( a.bottom > b.bottom ) return 5;
				return 6;
			}
			
			if( a.top < b.top ) return 7;
			if( a.bottom > b.bottom ) return 8;
			return 9;
			
		}

		
		private function getCollisionCodeWalking( a:Rectangle, b:Rectangle ) : int {
			
			
			var code :int = 0;
			
			switch( getIntersectionCode( a, b ) ) {
				case 1:
				case 7:
				case 4: 
					code = CollisionResult.BOTTOMCODE;
					break;
				case 2:
					code = CollisionResult.RIGHTCODE;
					break;
				default: trace("============ WTF getCollisionCodeWalking ===============");
			}
			
			return code;
			
			
			// for now, assuming running vs world static obj. check player bottom (against obj top) and player right (against obj left)
			// this is tricky, we test for walking into a wall before testing if we are below the surface ...

			
			// if running
			// -- against world static objects, we need only check against ground and left face
			// -- against dyn obj, we need to check only to the right
			
			// if jumping
			// -- against world static objects, we need check ground, the left face and above
			// -- against dyn obj, same as jumping vs world static objects

		}
		///////////////////////////////////////
		
		
	
		// Calculate the projection of a polygon on an axis
		// and returns it as a [min, max] interval
/*
		public static function ProjectPolygon( axis : Vector2, polygon : Rectangle, min : Number, max : Number) : void  {
				// To project a point on an axis use the dot product
			
			var vert: Array = new Array(4);
			for( var i :int = 0; i < 4; ++i ) {
				vert[i] = new Vector2();
			}
			
			vert[0].setValueFromPoint( polygon.topLeft ) ;
			vert[1].setValue( polygon.right, polygon.top );
			vert[2].setValueFromPoint( polygon.bottomRight );
			vert[3].setValue( polygon.left, polygon.bottom );
		
			var dotProduct : Number = axis.dot(vert[0]);
			min = dotProduct;
			max = dotProduct;
			for (i = 0; i < 4; i++) {
				dotProduct = vert[i].dot(axis);
				if (dotProduct < min) {
					min = dotProduct;
				} else {
					if (dotProduct> max) {
						max = dotProduct;
					}
				}
			}
		}
*/
		private static function center( r:Rectangle ) : Point {
			
			var x : Number = r.left + r.right;
			var y : Number = r.top + r.bottom;
			
			x /= 2;
			y /= 2;
			
			return new Point( x, y ) ;
		}

			private static function buildVertArray( r : Rectangle ) : Vector.<Vector2> {
				var verts:Vector.<Vector2> = new Vector.<Vector2>();
				
				var c:Point = center(r);
				
				verts.push( new Vector2( r.left - c.x, r.top - c.y ) );
				verts.push( new Vector2( r.right - c.x, r.top - c.y ) ) ;
				verts.push( new Vector2( r. right -c.x, r.bottom - c.y) );
				verts.push( new Vector2( r.left - c.x, r.bottom -c.y ) );
				return verts;
			}
			
			public static function SAT_vertsXverts( center1 :Point, verts1:Vector.<Vector2>, center2:Point, verts2 :Vector.<Vector2> ) : Vector2 {
				var test1:Number;// numbers to use to test for overlap
				var test2:Number;
				var testNum:Number; // number to test if its the new max/min
				var min1:Number; //current smallest(shape 1)
				var max1:Number;//current largest(shape 1)
				var min2:Number;//current smallest(shape 2)
				var max2:Number;//current largest(shape 2)
				var axis:Vector2;//the normal axis for projection
				var offset:Number;
				var vectorOffset:Vector2;
				var vectors1:Vector.<Vector2>;//the points
				var vectors2:Vector.<Vector2>;//the points
				vectors1 = verts1; //buildVertArray( polygon1 ); //.vertices.concat();//these functions are in my polygon class, all they do is return a Vector.<Vector2D> of the vertices of the polygon
				vectors2 = verts2; // buildVertArray (polygon2) ; //.vertices.concat();
				
				var msv : Vector2;
				var msvMagnitudeSquared : Number = Infinity;
				
				// find vertical offset				
				//var center1 : Point = center(polygon1);
				//var center2 : Point = center(polygon2) ;
				vectorOffset= new Vector2(center1.x - center2.x, center1.y - center2.y);
				
				// loop to begin projection
				for (var i:int = 0; i < vectors1.length; i++) {
					// get the normal axis, and begin projection
					axis = findNormalAxis(vectors1, i);
					
					// project polygon1
					min1 = axis.dot(vectors1[0]);
					max1 = min1;//set max and min equal
					
					for (var j:int = 1; j < vectors1.length; j++) {
						testNum = axis.dot(vectors1[j]);//project each point
						if (testNum < min1) min1 = testNum;//test for new smallest
						if (testNum > max1) max1 = testNum;//test for new largest
					}
					
					// project polygon2
					min2 = axis.dot(vectors2[0]);
					max2 = min2;//set 2's max and min
					
					for (j = 1; j < vectors2.length; j++) {
						testNum = axis.dot(vectors2[j]);//project the point
						if (testNum < min2) min2 = testNum;//test for new min
						if (testNum > max2) max2 = testNum;//test for new max
					}
					
					// apply the offset to each max/min(no need for each point, max and min are all that matter)
					offset = axis.dot(vectorOffset);//calculate offset
					min1 += offset;//apply offset
					max1 += offset;//apply offset
					
					// and test if they are touching
					test1 = min1 - max2;//test min1 and max2
					test2 = min2 - max1;//test min2 and max1
					if(test1 > 0 || test2 > 0){//if they are greater than 0, there is a gap
						return null;//just quit
					}
					
					var vThisSV : Vector2 = new Vector2(axis.x*((max2-min1)*-1) , axis.y*((max2-min1)*-1) );
					var vThisSVMagnitudeSquared : Number = vThisSV.magnitudeSquared();
					
					if( vThisSVMagnitudeSquared < msvMagnitudeSquared ){
						msvMagnitudeSquared = vThisSVMagnitudeSquared;
						msv = vThisSV;
					}					
				}
				
				//if you're here, there is a collision
				msv.negate();
				return msv;				
			}
			
			public static function SAT_rectXverts( rA : Rectangle, centerB : Point, vertsB : Array ) : Vector2 {

				var vertsA:Vector.<Vector2> = buildVertArray( rA ); 
				var centerA : Point = center(rA);
				
				
				// TODO: fix, should not do this copy to vector from array. fix callers to pass in vectors
				var _vertsB : Vector.<Vector2> = new Vector.<Vector2>();
				for each (var p:Vector2 in vertsB) 
				{
					_vertsB.push(p);	
				}
				
				
				return SAT_vertsXverts( centerA, vertsA, centerB, _vertsB );

			}
			
			
			public static function SAT_rectXrect( polygon1 : Rectangle, polygon2 : Rectangle ) : Vector2 {
			
				var verts1:Vector.<Vector2> = buildVertArray( polygon1 ); //.vertices.concat();//these functions are in my polygon class, all they do is return a Vector.<Vector2D> of the vertices of the polygon
				var verts2:Vector.<Vector2> = buildVertArray (polygon2) ; //.vertices.concat();
				
				var center1 : Point = center(polygon1);
				var center2 : Point = center(polygon2) ;

				return SAT_vertsXverts( center1, verts1, center2, verts2 ); 
				
/*				
				var test1:Number;// numbers to use to test for overlap
				var test2:Number;
				var testNum:Number; // number to test if its the new max/min
				var min1:Number; //current smallest(shape 1)
				var max1:Number;//current largest(shape 1)
				var min2:Number;//current smallest(shape 2)
				var max2:Number;//current largest(shape 2)
				var axis:Vector2;//the normal axis for projection
				var offset:Number;
				var vectorOffset:Vector2;
				var vectors1:Vector.<Vector2>;//the points
				var vectors2:Vector.<Vector2>;//the points
				vectors1 = buildVertArray( polygon1 ); //.vertices.concat();//these functions are in my polygon class, all they do is return a Vector.<Vector2D> of the vertices of the polygon
				vectors2 = buildVertArray (polygon2) ; //.vertices.concat();
				
				var msv : Vector2;
				var msvMagnitudeSquared : Number = Infinity;
								
				// find vertical offset				
				var center1 : Point = center(polygon1);
				var center2 : Point = center(polygon2) ;
				vectorOffset= new Vector2(center1.x - center2.x, center1.y - center2.y);
				
				// loop to begin projection
				for (var i:int = 0; i < vectors1.length; i++) {
					// get the normal axis, and begin projection
					axis = findNormalAxis(vectors1, i);
					
					// project polygon1
					min1 = axis.dot(vectors1[0]);
					max1 = min1;//set max and min equal
					
					for (var j:int = 1; j < vectors1.length; j++) {
						testNum = axis.dot(vectors1[j]);//project each point
						if (testNum < min1) min1 = testNum;//test for new smallest
						if (testNum > max1) max1 = testNum;//test for new largest
					}
					
					// project polygon2
					min2 = axis.dot(vectors2[0]);
					max2 = min2;//set 2's max and min
					
					for (j = 1; j < vectors2.length; j++) {
						testNum = axis.dot(vectors2[j]);//project the point
						if (testNum < min2) min2 = testNum;//test for new min
						if (testNum > max2) max2 = testNum;//test for new max
					}
					
					// apply the offset to each max/min(no need for each point, max and min are all that matter)
					offset = axis.dot(vectorOffset);//calculate offset
					min1 += offset;//apply offset
					max1 += offset;//apply offset
					
					// and test if they are touching
					test1 = min1 - max2;//test min1 and max2
					test2 = min2 - max1;//test min2 and max1
					if(test1 > 0 || test2 > 0){//if they are greater than 0, there is a gap
						return null;//just quit
					}
				
					var vThisSV : Vector2 = new Vector2(axis.x*((max2-min1)*-1) , axis.y*((max2-min1)*-1) );
					var vThisSVMagnitudeSquared : Number = vThisSV.magnitudeSquared();
					
					if( vThisSVMagnitudeSquared < msvMagnitudeSquared ){
						msvMagnitudeSquared = vThisSVMagnitudeSquared;
						msv = vThisSV;
					}					
				}
				
				//if you're here, there is a collision
				msv.negate();
				return msv;
*/				
			}	
			
			
			private static function findNormalAxis(vertices:Vector.<Vector2>, index:int):Vector2 {
				var vector1:Vector2 = vertices[index];
				var vector2:Vector2 = (index >= vertices.length - 1) ? vertices[0] : vertices[index + 1]; //make sure you get a real vertex, not one that is outside the length of the vector.

				var normalAxis:Vector2 = new Vector2( -(vector1.y - vector2.y), (vector1.x - vector2.x));//take the two vertices, make a line out of them, and find the normal of the line				
				normalAxis.normalize();//normalize the line(set its length to 1)
				return normalAxis;
			}
	
	}

}


