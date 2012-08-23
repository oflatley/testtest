package
{
	import events.ControllerEvent;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;

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
		private static const gravity :Number = 2;	
		private static const DESIGN_SIZE:Rectangle = new Rectangle(0,0,960,640);
		private var worldStaticObjects : Array = new Array();
		private var playerSim:PlayerSim;
		private var currentLevel:Level;
		private var screenContainer : ScreenContainer;

		

		private static const objPoolAllocs : Array = [
			
			{type:"PlatformShort_0" , 	count:10 },
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
			stage.color = 0x444444;
			stage.frameRate = 60;
			
			collisionManager = new CollisionManager();
			screenContainer = ScreenContainer.Instance();
			ObjectPool.Instance().Initialize( objPoolAllocs, screenContainer );
			addChild( screenContainer.container );			
			startGame();
		}
		
		private function startGame():void{
			var playerView : PlayerView = new PlayerView(  );
			playerView.AddToScene( screenContainer.container );
			playerSim = new PlayerSim(new Controller(stage), velocityX, gravity, playerView, collisionManager );
			playerSim.SetPosition( new Point( 10,500 ) );
	
  			currentLevel = new Level("Level0",collisionManager,playerSim);
			onResize( null );
			addEventListener(Event.RESIZE, onResize );
 			addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame( e:Event ) : void {
			playerSim.Update();
			currentLevel.update(playerSim.worldPosition);
			collisionManager.update(playerSim,currentLevel.activeObjects);		// dispatches CollisionEvents
			screenContainer.update( playerSim.getBounds().topLeft );
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

