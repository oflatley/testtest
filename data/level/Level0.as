package data.level {
	
	import interfaces.ILevelData;
	
	public class Level0 implements ILevelData {
		public function get data() : Array { return _data; }
		public function get localLengthX() : Number { return 2901 + 400; }

		private static const _data : Array = [
			{ type: "Platform_Arc_0",					x: 0,				y: 432},
/*		
			{ type: "PlatformLong_0",					x: 0,				y: 500},
			{ type: "Column",							x: 150,				y: 450},
		
			{ type: "PlatformMedium_15",					x: 28,				y: 531},	
			{ type: "Brain",					x:100,				y: 490},			
		
			{ type: "PlatformShort_0",					x: 897,				y: 474},
			{ type: "SpringBoard",					x: 907,				y: 465},
			{ type: "PlatformShort_0",					x: 751,				y: 188},
			{ type: "PlatformShort_0",					x: 352,				y: 483},
			{ type: "PlatformShort_0",					x: 1353,				y: 377},
			{ type: "PlatformShort_0",					x: 1101,				y: 377},
			{ type: "PlatformShort_0",					x: 1378,				y: 237},
			{ type: "PlatformShort_0",					x: 959,				y: 377},
			{ type: "PlatformLong_0",					x: 467,				y: 428},
			{ type: "PlatformLong_0",					x: 1262,				y: 493},
		//	{ type: "Catapult",					x: 580,				y: 397},
			{ type: "PlatformMedium_0",					x: 1719,				y: 355},
			{ type: "PlatformMedium_0",					x: 2031,				y: 355},
			{ type: "Trampoline",					x: 1740,				y: 336},
			{ type: "Brain",					x: 767,				y: 160},
			{ type: "Brain",					x: 999,				y: 319},
			{ type: "Brain",					x: 1091,				y: 338},
			{ type: "Token_MakePlayerBigger",					x: 414,				y: 455},
			{ type: "Token_MakePlayerSmaller",					x: 570,				y: 611},
			{ type: "SpeedBoostCoin",					x: 1026,				y: 303},
			{ type: "SpeedBoostCoin",					x: 1068,				y: 310},
			{ type: "Brain",					x: 801,				y: 160},
			{ type: "Brain",					x: 982,				y: 349},
			{ type: "Brain",					x: 663,				y: 405},
			{ type: "SpeedBoostCoin",					x: 690,				y: 405},
			{ type: "PlatformShort_0",					x: 477,				y: 520},
			{ type: "PlatformShort_0",					x: 602,				y: 567},
			{ type: "PlatformShort_0",					x: 767,				y: 531},
			{ type: "Column",					x: 776,				y: 378},
			{ type: "Enemy_0",					x: 660,				y: 531},
			{ type: "PlatformLong_0",					x: 1039,				y: 158},
			{ type: "PlatformMedium_15",					x: 28,				y: 531},	
			{ type: "Brain",					x:100,				y: 490},			
			{ type: "PlatformMedium_345",					x: 409,				y: 265},
			{ type: "PlatformShort_0",					x: 261,				y: 551},
			{ type: "Platform_Arc_0",					x: 2367,				y: 452},
			{ type: "Platform_Arc_0",					x: 2633,				y: 443},
			{ type: "Platform_Arc_0",					x: 2901,				y: 432},
*/
			];
	}
}