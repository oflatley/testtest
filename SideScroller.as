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
	import sim.WorldObject;
	
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
	
		private static const levelData0 : Array = [

//			{type:"PlatformMedium_0", 		x:0,	y:500},
//			{type:"Column",					x:75,  y:450},

			
			
		//	{type:"PlatformShort_0", 		x:0, 	y:0},
			{type:"PlatformLong_0", 		x:200, 	y:300},
	
			{type:"PlatformMedium_15",		x:0, 	y:510},
			{type:"PlatformMedium_345",		x:400, 	y:300},
		
			{type:"PlatformMedium_0", 		x:0,	y:500},
		
			{type:"Column",					 x:65,  y:450},
			{type:"PlatformShort_elev",		x:100, y:450},
			{type:"Brain",					x:220, y:250},

			{type:"PlatformShort_0", 		x:260, 	y:555},
			{type:"PlatformShort_0",		x:350,	y:505},
			{type:"Enemy_0",				x:910,  y:555-17.5, props:{homeX:960,range:200}},
			{type:"PlatformMedium_0", 		x:500,  y:450},
			{type:"PlatformMedium_0", 		x:550,  y:400},
			{type:"SpringBoard",			x:650,	y:392},

			{type:"PlatformLong_0", 		x:710, 	y:555},
			{type:"PlatformLong_0", 		x:1160, y:555},			
			{type:"PlatformLong_0", 		x:1610, y:555},
			
			{type:"PlatformShort_elev",		x:1800, y:350},

			{type:"Enemy_0",				x:2360,  y:555-17.5, props:{homeX:2360,range:200}},			
			{type:"PlatformLong_0", 		x:2060, y:555},
			
			{type:"PlatformLong_0", 		x:2260, y:455},
			{type:"Brain",					x:2300, y:420},
			{type:"Brain",					x:2330, y:420},
			{type:"Brain",					x:2360, y:420},
			{type:"Brain",					x:2390, y:420},
			{type:"Brain",					x:2420, y:420},
			{type:"Brain",					x:2450, y:420},
			{type:"Brain",					x:2480, y:420},
			{type:"SpeedBoostCoin",			x:2510, y:420},
			
			{type:"PlatformLong_0", 		x:2360, y:555},			
			{type:"PlatformLong_0", 		x:2860, y:455},
			{type:"PlatformLong_0", 		x:3160, y:555},
			{type:"PlatformLong_0", 		x:3460, y:455},
			{type:"PlatformLong_0", 		x:3860, y:555},
			{type:"PlatformLong_0", 		x:4060, y:455},
			{type:"PlatformLong_0", 		x:4460, y:555},
			{type:"PlatformLong_0", 		x:4660, y:455},
			{type:"PlatformLong_0", 		x:5060, y:555},
			{type:"PlatformLong_0", 		x:5260, y:455},
			{type:"PlatformLong_0", 		x:5560, y:555},
			{type:"PlatformLong_0", 		x:6060, y:455},
			{type:"PlatformLong_0", 		x:6460, y:555},
			{type:"PlatformLong_0", 		x:6860, y:455},
	//		{type:"PlatformMedium_15",		x:300, 	y:200},
	//		{type:"PlatformMedium_345",		x:400, 	y:300},
			{type: "Column",				x:900,  y:505},

			];
		
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

			// todo refactor into input module
			currentLevel = new Level(levelData0,collisionManager);

			var playerView : PlayerView = new PlayerView(  );
			playerView.AddToScene( screenContainer.container );
				
			playerSim = new PlayerSim(new Controller(stage), velocityX, gravity, playerView, collisionManager );
	//		playerSim.worldPosition( new Point(10,500) );
			playerSim.SetPosition( new Point( 10,500 ) );
			

			onResize( null );
			addEventListener(Event.RESIZE, onResize );
 			addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		
		
		
		private function onEnterFrame( e:Event ) : void {
		
			playerSim.Update();
			currentLevel.update(playerSim.worldPosition);
			collisionManager.update(playerSim,currentLevel.activeObjects);		// dispatches CollisionEvents
			
			screenContainer.update( playerSim.getBounds().left );

			//trace( playerSim.moveState == PlayerSim.MOVESTATE_WALKING ? "walk" : "jump" );
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

