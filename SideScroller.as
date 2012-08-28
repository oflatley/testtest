package
{
	
	import collision.CollisionDataProvider;
	
	import events.ControllerEvent;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.flash_proxy;
	
	import interfaces.ICollisionData;
	
	import sim.Level;
	import sim.PlayerSim;
	
	import util.CollisionManager;
	import util.Controller;
	import util.ObjectPool;
	import util.ScreenContainer;
	
	import views.PlayerView;

	[SWF(width='960', height='640')]
	public class SideScroller extends Sprite
	{
		private var collisionManager : CollisionManager;
		private var playerMC : MovieClip;
		private static const velocityX:Number = 2.5;
		private static const gravity :Number = 1.75;	
		private static const DESIGN_SIZE:Rectangle = new Rectangle(0,0,960,640);
		private var worldStaticObjects : Array = new Array();
		private var playerSim:PlayerSim;
		private var currentLevel:Level;
		private var screenContainer : ScreenContainer;
		private var collisionDataProvider : CollisionDataProvider;		

		private static const objPoolAllocs : Array = [
			
			{type:"Platform_Arc_0" , 	count:5 },		
			{type:"PlatformShort_0" , 	count:12 },			
			{type:"PlatformMedium_0", 	count:10 },
			{type:"PlatformMedium_15", 	count:10 },
			{type:"PlatformMedium_345", count:10 },
			{type:"PlatformLong_0", 	count:10 },
			{type:"Enemy_0",			count:10 },
			{type:"Column",				count:10 },
			{type:"PlatformShort_elev",	count:10 },
			{type:"Brain",				count:10 },
			{type:"SpeedBoostCoin",		count:10 },
			{type:"SpringBoard",		count:5 },
			{type:"Token_MakePlayerBigger",	count:3 },
			{type:"Token_MakePlayerSmaller",count:3 },
			{type:"Trampoline", count:3 },
			{type:"Launcher",count:5 },
			{type:"Catapult",count:3 },
			
			];

		
		public function SideScroller()
		{
			super();

			collisionManager = new CollisionManager();
			screenContainer = ScreenContainer.Instance();
			addChild( screenContainer.container );			
			
			ObjectPool.Instance().buildMovieClipClasses( 'assets/assets.swf', init); // if using swf
			
			// swc: loadData()  ;
		}
		
		private function init(): void {
			CollisionDataProvider.instance.buildCollisionData("data/collisionObj/collisionData.dat", startGame );
		}
		
		private function startGame():void{

			stage.color = 0x444444;
			stage.frameRate = 60;
			
			ObjectPool.Instance().initialize( objPoolAllocs, screenContainer );
			var playerView : PlayerView = new PlayerView(  );
			playerView.AddToScene( screenContainer.container );
			playerSim = new PlayerSim(new Controller(stage), velocityX, gravity, playerView.getBounds(), collisionManager );
			playerSim.SetPosition( new Point( 10,405 ) );
			playerView.initEventListeners( playerSim );
	
  			currentLevel = new Level("Level0",collisionManager,playerSim);
			onResize( null );
			addEventListener(Event.RESIZE, onResize );
 			addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame( e:Event ) : void {
			playerSim.Update();
			currentLevel.update(playerSim.worldPosition);
			collisionManager.update(playerSim,currentLevel.activeObjects);		// dispatches CollisionEvents
			screenContainer.update( playerSim.worldPosition );
		}
		
		private function onResize( e:Event ) : void {
			trace( stage.stageWidth );
			trace( stage.stageHeight );
			var scale:Number = Math.min( stage.stageWidth/DESIGN_SIZE.width, stage.stageHeight/DESIGN_SIZE.height );
			scaleX = scaleY = scale;
			this.x = (stage.stageWidth - scale*DESIGN_SIZE.width)/2;
			this.y = (stage.stageHeight - scale*DESIGN_SIZE.height)/2;			
		}
	}
}


