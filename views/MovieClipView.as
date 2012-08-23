package views
{
	import events.WorldObjectEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import interfaces.IWorldObject;
	
	import util.ScreenContainer;

	public class MovieClipView  {
		
		private var _mc : MovieClip;
		
		public function MovieClipView ( displayContainer: ScreenContainer, iWorldObj : IWorldObject, mc : MovieClip ) {
			_mc = mc;
			displayContainer.container.addChild( mc );
			iWorldObj.eventDispatcher.addEventListener( WorldObjectEvent.WORLDOBJECT_MOVE, onWorldObjMove );
		}

		public function set active( b : Boolean ) : void {
			_mc.visible = b;
		}
		
		private function onWorldObjMove( event : WorldObjectEvent ) : void {
			var iwo : IWorldObject = event.target as IWorldObject;
			var r : Rectangle = iwo.bounds;	
			_mc.x = r.x;
			_mc.y = r.y;
		}	
		
		
	}

}