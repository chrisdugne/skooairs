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
		
		public function addPoints(nbGroup:int, nbInside:int):void{
			var base:int = (1+nbGroup)*nbGroup/2;
			var bonus:int = nbInside  > 0 ? (nbInside + Session.COLORS - 1) : 1;
			
			Session.POINTS += base * bonus;
			Session.play.pointsMessage(base, bonus);
		}

}
}