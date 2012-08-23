package levels
{
	public class LevelFactory
	{
		private var _levels:Array;
		
		public function LevelFactory()
		{
			_levels = new Array;
			_levels["Level0"] = new Level0();
		}
		
		public function GetLevel( s:String ) : ILevelData {
			var I : ILevelData = _levels[s];
			if( !I ) {
				trace('Level Not Found ' + s );				
			}
			return I;
		}
	}
}