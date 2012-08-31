package data.level {
	import interfaces.ILevelData;
	public class Level1 implements ILevelData {
		public function get data() : Array { return _data; }
		public function get localLengthX() : Number { return 1572 + 200; }
		private static const _data : Array = [
			{ type: "Platform_Arc_0",					x: 371,				y: 482},
			{ type: "Platform_Arc_0",					x: 100,				y: 493},
	  		{ type: "Platform_Arc_0",					x: 643,				y: 473},

			{ type: "PlatformShort_0",					x: 0,				y: 551},
			{ type: "PlatformShort_0",					x: 1572,				y: 463},
			{ type: "PlatformShort_0",					x: 379,				y: 551},
			{ type: "PlatformShort_0",					x: 571,				y: 551},
			{ type: "PlatformShort_0",					x: 767,				y: 531},
			{ type: "PlatformShort_0",					x: 184,				y: 547},
			{ type: "PlatformShort_0",					x: 892,				y: 483},
			{ type: "PlatformShort_0",					x: 1253,				y: 571},
			{ type: "PlatformShort_0",					x: 1416,				y: 511},
			{ type: "PlatformShort_0",					x: 1032,				y: 432},
			{ type: "PlatformShort_0",					x: 1143,				y: 511},

			];
	}
}