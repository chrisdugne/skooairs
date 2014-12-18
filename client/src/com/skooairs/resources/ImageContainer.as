package com.skooairs.resources
{
	import mx.collections.ArrayCollection;
	      	 
	public class ImageContainer
	{
		//   ======================================================================//
		
		[Embed(source="resources/embed/loading.skooairs.swf")]
		[Bindable] public static var LOADING:Class;
	
		//   ======================================================================//
	
		[Embed(source="resources/embed/images/background_preloading.jpg")]
		[Bindable] public static var PRELOADER_IMAGE:Class;
	
		[Embed(source="resources/embed/images/background.jpg")] 
		[Bindable] public static var BACKGROUND:Class;
	
		[Embed(source="resources/embed/images/skooairs.png")]
		[Bindable] public static var SKOOAIRS_TITLE:Class;
	
		[Embed(source="resources/embed/images/gameOver.png")]
		[Bindable] public static var GAME_OVER:Class;
	
		[Embed(source="resources/embed/images/loadingpoint.png")]
		[Bindable] public static var LOADINGPOINT:Class;
	
		//   ======================================================================//
	
		[Embed(source="resources/embed/images/play/panneau.png")]
		[Bindable] public static var PANNEAU:Class;
	
		[Embed(source="resources/embed/images/play/plateau.png")]
		[Bindable] public static var PLATEAU:Class;
	
		[Embed(source="resources/embed/images/play/boom.png")]
		[Bindable] public static var BOOM:Class;
	
		//   ======================================================================//
	
		[Embed(source="resources/embed/images/tutoarrows/up.png")]
		[Bindable] public static var TUTO_ARROW_UP:Class;
	
		[Embed(source="resources/embed/images/tutoarrows/down.png")]
		[Bindable] public static var TUTO_ARROW_DOWN:Class;
	
		[Embed(source="resources/embed/images/tutoarrows/left.png")]
		[Bindable] public static var TUTO_ARROW_LEFT:Class;
	
		[Embed(source="resources/embed/images/tutoarrows/right.png")]
		[Bindable] public static var TUTO_ARROW_RIGHT:Class;
	
		
		//   ======================================================================//
	
		[Embed(source="resources/embed/images/play/carre_1.png")]
		[Bindable] private static var SQUARE_1:Class;
	
		[Embed(source="resources/embed/images/play/carre_2.png")]
		[Bindable] private static var SQUARE_2:Class;
	
		[Embed(source="resources/embed/images/play/carre_3.png")]
		[Bindable] private static var SQUARE_3:Class;
	
		[Embed(source="resources/embed/images/play/carre_4.png")]
		[Bindable] private static var SQUARE_4:Class;
	
		[Embed(source="resources/embed/images/play/carre_5.png")]
		[Bindable] private static var SQUARE_5:Class;
	
		[Embed(source="resources/embed/images/play/carre_6.png")]
		[Bindable] private static var SQUARE_6:Class;
		
		//   ======================================================================//
	
		[Embed(source="resources/embed/images/play/carre_boom_1.png")]
		[Bindable] private static var SQUARE_BOOM_1:Class;
	
		[Embed(source="resources/embed/images/play/carre_boom_2.png")]
		[Bindable] private static var SQUARE_BOOM_2:Class;
	
		[Embed(source="resources/embed/images/play/carre_boom_3.png")]
		[Bindable] private static var SQUARE_BOOM_3:Class;
	
		[Embed(source="resources/embed/images/play/carre_boom_4.png")]
		[Bindable] private static var SQUARE_BOOM_4:Class;
	
		[Embed(source="resources/embed/images/play/carre_boom_5.png")]
		[Bindable] private static var SQUARE_BOOM_5:Class;
	
		[Embed(source="resources/embed/images/play/carre_boom_6.png")]
		[Bindable] private static var SQUARE_BOOM_6:Class;
		
		//   ======================================================================//
		
		public static function getSquare(color:int):Class{
			switch(color){
				case 1: return SQUARE_1;
				case 2: return SQUARE_2;
				case 3: return SQUARE_3;
				case 4: return SQUARE_4;
				case 5: return SQUARE_5;
				case 6: return SQUARE_6;
			}
			
			//never
			return null;
		}
	
		public static function getSquareBoom(color:int):Class{
			switch(color){
				case 1: return SQUARE_BOOM_1;
				case 2: return SQUARE_BOOM_2;
				case 3: return SQUARE_BOOM_3;
				case 4: return SQUARE_BOOM_4;
				case 5: return SQUARE_BOOM_5;
				case 6: return SQUARE_BOOM_6;
			}
	
			//never
			return null;
		}
	}
}