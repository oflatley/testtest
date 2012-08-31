package levels {
	
	import data.level.*;	
	import interfaces.ILevelData;	
	import levels.LevelFactory;	
	import sim.Level;
	
	public class LevelInstanceBase {
		
		private var _sections : Array;
		
		public function LevelInstanceBase()  {
			
		}
		
		// TODO protected ??? wtf
		public function set sections(value:Array) : void { 
			_sections = value; 
		}  
		
		private function generateShuffledSections() : Array {
			
			var order : Array = new Array();
			var shuffledSections : Array = new Array();
			for( var i : int = 0; i < _sections.length; ++i ) {
				order.push(i);			
			}
			
			while( order.length ) {
				var n : Number = Math.random();
				var r : int = n * (order.length - 1) + .5;
				var dx : int = order.splice( r, 1 )[0];
				shuffledSections.push( _sections[dx] );
			}
			return shuffledSections;
		}
		
		public function generate() : Array {
			
			var shuffledSections : Array = generateShuffledSections();
			var aGenLevelData : Array = new Array();		
			var xFixup : Number = 0;
			
			for each ( var klass : Class in shuffledSections ) {
				var ILevelInstance : ILevelData = new klass();
				var data : Array = ILevelInstance.data;
				
				for each( var dat : Object in data ) {
					dat.x += xFixup;
					aGenLevelData.push( dat );
				}
				
				xFixup += ILevelInstance.localLengthX;			
			}		
			return aGenLevelData;
		}
	}
}	

