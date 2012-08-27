package collision
{

	import interfaces.ICollisionData;

	public class CollisionDataProvider { 
	
		private static var _theInstance : CollisionDataProvider = null;
		private var _map:Array;
		
		public function getCollisionData( s : String ) : ICollisionData 
		{ 
			return _map[s];
		}

		public function CollisionDataProvider( se:SingletonEnforcer ) {
			_map = new Array();
		}
		
		public function buildCollisionData( url : String,  completedCallback : Function ) : void {			
			var dfp : DatFileParser = new DatFileParser();
			dfp.parse( url, completedCallback, _map );
		}
		
		public static function get instance() : CollisionDataProvider {
			if( null == _theInstance ) {
				_theInstance = new CollisionDataProvider( new SingletonEnforcer() );
			}
			return _theInstance;
		}
		
	}
}

class SingletonEnforcer {}

import collision.CollisionData;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;





class DatFileParser {

	private var _map : Array;
	private var _completedCallback : Function;
	
	public function parse( sURL : String, completedCallback : Function, map : Array ) : void {
		_completedCallback = completedCallback;
		_map = map;
		var urlLoader : URLLoader = new URLLoader() ;
		var urlReq : URLRequest = new URLRequest( sURL );
		urlLoader.load(urlReq);
		urlLoader.addEventListener( Event.COMPLETE, onDataLoaded );		
	}

	
	protected function onDataLoaded(event:Event):void
	{	
		var ss : String = event.target.data as String;
		var ssSplits : Array = ss.split( /\s+/ );
		var idxCursor : int = 0;
		var dx : int = 0;

		for each ( var s : String in ssSplits ) {
		
			if( s.length ) {
			
				var sSplits : Array  = s.split( /:/ );
				
				var dfp : DatFileParserWorker = new DatFileParserWorker(sSplits[1]);
				var w : int = dfp.getNext();
				var h : int = dfp.getNext();
				
				var v : Vector.<int> = new Vector.<int>();	
				var i :int;
				while( -1 != ( i = dfp.getNext() ) ){
					v.push(i);
				}
				
				var type : String = sSplits[0];		
				var cd : CollisionData = new CollisionData( w,h,v );
				_map[type] = cd;

			}
		}
		_completedCallback();
	}	


}


class DatFileParserWorker {

	private var _src : String;
	private var _idxCursor : int;
	
	public function DatFileParserWorker( s : String ) {
		_src = s;
		_idxCursor = 0;
	}
	
	public function getNext() : int {
		
		if( _idxCursor >= _src.length ) {
			return -1;
		}
		
		var _idxStart : int = _idxCursor;
		
		for( ; _idxCursor < _src.length; ++_idxCursor ) {
			if( ',' == _src.charAt( _idxCursor )  ) {
				break;
			}
		}
		
		_idxCursor++;
		var sThisValue : String = _src.slice( _idxStart, _idxCursor -1 );
		var ret : int = int( sThisValue );
		return int( sThisValue );
	}


}



