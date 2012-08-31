package levels
{
	import data.level.*;
	
	import interfaces.ILevelData;
	
	import sim.Level;
	import sim.PlayerSim;
	
	import util.CollisionManager;
	
	public class LevelFactory
	{
		private static var _theThe : LevelFactory = null;
		private var _levels:Array = new Array();
				
		public static function get instance() : LevelFactory {
			if( !_theThe ) {
				_theThe = new LevelFactory( new SingletonEnforcer() );
			}
			return _theThe;
		}
		
		public function LevelFactory( se : SingletonEnforcer ) {
			_levels['Level0'] = LevelInstance_0;
			_levels['Level1'] = LevelInstance_1;			
		}
			
		public function registerLevel( tag : String, levelInstanceClass : Class ) : void {
			_levels[tag] = levelInstanceClass;
		}
		
		public function generateLevel( s:String, cm : CollisionManager, ps : PlayerSim ) : Level {
			var li : LevelInstanceBase = new _levels[s]();
			var a : Array = li.generate();
			return new Level( a, cm, ps );
		}
	}
}

class SingletonEnforcer {}

import data.level.*;

import levels.LevelFactory;
import levels.LevelInstanceBase;

class LevelRegistrationAgent {
	
	
	static public function register( name : String, klass : Class ) : void {
	//	LevelFactory.instance.registerLevel(name,klass);		
	}
}

class LevelInstance_0 extends LevelInstanceBase {
	LevelRegistrationAgent.register( "Level0", LevelInstance_0 );	
	public function LevelInstance_0() {
		super.sections = [Level0];//,Level1]; 	
	}	
}

class LevelInstance_1 extends LevelInstanceBase {
	LevelRegistrationAgent.register( "Level1", LevelInstance_1 );
	public function LevelInstance_1( ) {		
		super.sections = [Level0,Level1];
	}
}	





