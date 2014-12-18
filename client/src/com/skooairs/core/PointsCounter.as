package com.skooairs.core
{

import com.skooairs.constants.Session;

/**
The PointsCounter
*/
public class PointsCounter
{		
		//=====================================================================================//

		private static var instance : PointsCounter = new PointsCounter(); 
	
		public static function getInstance():PointsCounter{
			return instance;
		}

		public function PointsCounter(){}

		//=====================================================================================//
		
		public function reset():void{
			Session.POINTS = 0;
		}
		
		public function addPoints(nbCasesOfGroupToExplode:int, nbInsiders:int):void{
			var base:int = (1+nbCasesOfGroupToExplode)*nbCasesOfGroupToExplode/2;
			var bonus:int = nbInsiders  > 0 ? (nbInsiders + Session.COLORS - 1) : 1;

//			trace("nbCasesOfGroupToExplode " + nbCasesOfGroupToExplode);
//			trace("nbInsiders " + nbInsiders);
//			trace("base " + base);
//			trace("bonus " + bonus);
//			trace(base * bonus);
			
			Session.POINTS += base * bonus;
			Session.play.pointsMessage(base, bonus);
		}

}
}