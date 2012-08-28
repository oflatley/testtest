package util
{
	public class BitArray
	{
		private var _data : Vector.<uint>; //: new Vector.<uint>();
		
		public function BitArray( data : Vector.<uint> )
		{
			_data = data;			
		}
		
		public function test( _dx : uint ) : Boolean {
			
			var value : uint = _data[_dx>>>5] & (0x80000000 >>> (_dx&31) );
			//return Boolean(value);
			
			var shift : uint = _dx & 31;
			var mask : uint = 0x80000000;
			mask = mask >>> shift;
				
			
			var dx : uint = _dx >>> 5;
			var val : uint = _data[dx];

			
			if( value != uint(val&mask) ) {
				trace('ugly ugly ugly');
			}
			
			var b : Boolean = 0 != (val & mask);
			return b;
			
		}
	}
}