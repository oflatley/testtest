package util
{
	import events.ScreenContainerEvent;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	public class ScreenContainer extends EventDispatcher
	{

		private static const _xMargin : Number = 200;
		private var _container : Sprite;
		private static var sc :ScreenContainer = null;
		private var _sliceCount : int;
		private var _sliceWidth : int; 		// TODO resize
		private var _ndxCurrentSlice : int;
		
		public static function Instance() : ScreenContainer {
			if( null == sc ) {
				sc = new ScreenContainer(new SingletonEnforcer());
			}
			return sc;
		}
		
		public function SetSliceCount( n : int ) : void {
			_sliceCount = n;
			_sliceWidth = 960 / _sliceCount; 	// TODO onResize
		}
		
		// prevent clients from breaking singleton pattern. ctr requires internal class
		public function ScreenContainer(_:SingletonEnforcer)
		{
			_container = new Sprite();
			_ndxCurrentSlice = 0;
	
		}

		public function get container():Sprite
		{
			return _container;
		}
		
		public function addChild( o : Object ) : void { 
			o.AddToScene( _container );

		}

		
		public function update( xPlayer : Number ) : void {
			
			var overMargin : Number = xPlayer - _xMargin;
			
			if( overMargin > 0 ) {
 				_container.x = -overMargin;
			}			
			
			var x : int = -container.x / _sliceWidth;
			
			if( x != _ndxCurrentSlice ) {
				dispatchEvent( new ScreenContainerEvent( ScreenContainerEvent.SLICE_SCROLL, x ) );
				_ndxCurrentSlice = x;
			}		
		}

		public function isOnscreen( x : Number ) : Boolean {
			var n :Number = x + _container.x ;
			return ( 0 <= n && n <= 960 );
		}

		public function get scrollThresholdx():Number
		{
			return _xMargin;
		}

		public function get scrollX() : Number {
			return -_container.x;
		}
		
	}
}

// this internal class is used to prevent clients from breaking singleton pattern
class SingletonEnforcer {}