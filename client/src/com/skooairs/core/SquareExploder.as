package com.skooairs.core
{

import com.skooairs.constants.Session;

import com.skooairs.entities.Case;
import com.skooairs.entities.CaseGroup;
import com.skooairs.entities.CaseGroupInside;
import com.skooairs.entities.Line;

import com.skooairs.utils.Map;

import mx.collections.ArrayCollection;


/**
The SquareExploder
debug : replaceAll '//trace' with '//trace'
*/
public class SquareExploder
{		
		//=====================================================================================//

		private static var instance : SquareExploder = new SquareExploder(); 
	
		public static function getInstance():SquareExploder{
			return instance;
		}

		public function SquareExploder(){}

		//=====================================================================================//
		
		// one Array of CaseGroup for each color (6 max)
		private var groups:Array;
		private var groupToExplode:CaseGroup;
		
		//=====================================================================================//
		
		public function reset():void {
			groups = [[],[],[],[],[],[]];
		}
		
		public function register(_case:Case):void{
			
			//trace("----------------------");
			//trace("registering case["+_case.x+"]["+_case.y+"]");
			var groupTouched:CaseGroup = new CaseGroup();
			var newColorGroups:Array = [];
			
			for each(var group:CaseGroup in groups[_case.color-1]){
				
				if(_case.y > 0 && group.contains(Session.cases[_case.x][_case.y - 1])
				|| _case.x < 8 && group.contains(Session.cases[_case.x + 1][_case.y])
				|| _case.y < 8 && group.contains(Session.cases[_case.x][_case.y + 1])
				|| _case.x > 0 && group.contains(Session.cases[_case.x - 1][_case.y])){
					//trace("found a group of the same color, touching the new square");
					groupTouched.merge(group);
				}
				else{
					//trace("found a group of the same color but not touching the new square");
					newColorGroups.push(group);
				}
			}
			
			groupTouched.add(_case);
			newColorGroups.push(groupTouched);
			groupToExplode = groupTouched;
			groups[_case.color-1] = newColorGroups;
			
			//trace("----------------------");
			//trace("color : " + _case.color)
			//trace("this colorgroup.nb : " + groups[_case.color-1].length);
			//trace("----------------------");
			
		}
		
		// explose le groupe qui vient detre groupTouched dans le register juste realise
		// return the number of frontiers removed
		public function explode():int{

			var nbCasesOfGroupToExplode:int = groupToExplode.cases.length; // groupToExplode.cases will be added insiders of the same color in the following 'getInsiders()'. Not counting for points, so storing here the real groupToExplode.cases.length
			var insiders:Array = getInsiders();
			//trace("found " + insiders.length + " insiders");

			var nbFrontiersExploded:int = 0;	
			
			for each(var _case:Case in groupToExplode.cases){
				
				Session.play.explodeSquare(_case.image);
				Session.cases[_case.x][_case.y] = new Case(_case.x, _case.y);
				
				if(_case.x == 0
				|| _case.x == 8
		    	|| _case.y == 0
		    	|| _case.y == 8)
		    		nbFrontiersExploded++;
			
			}
			
			var nbInsiders:int = 0;
			for each(_case in insiders){
				if(_case.status == Case.FULL){
					Session.play.explodeSquare(_case.image);
					Session.cases[_case.x][_case.y] = new Case(_case.x, _case.y);
					nbInsiders ++;
				}
			}
			
			MusicPlayer.getInstance().playExplosionSound();
			if(nbInsiders > 0)
				MusicPlayer.getInstance().playYeahSound();
				
			PointsCounter.getInstance().addPoints(nbCasesOfGroupToExplode, nbInsiders);
			
			// pop() : Removes the last element from an array (and returns the value of that element).
			// this last element is groupToExplode :
			//		 ...
			//       newColorGroups.push(groupTouched);
			//       groupToExplode = groupTouched;
			//		 groups[_case.color-1] = newColorGroups;
			//		 ...
			var groupRemoved:CaseGroup = groups[groupToExplode.cases[0].color-1].pop();
			
			//trace("------------------");
			//trace("explosion");
			//trace("removed the groupToExplode");
			//trace("for color : " + groupToExplode.cases[0].color);
			//trace("there remains " + groups[groupToExplode.cases[0].color-1].length + " groups in groups[colors]");
			//trace("------------------");
			
			return nbFrontiersExploded;
		}
		
		
		private function getInsiders():Array{

			var COLOR_OF_GROUP_TO_EXPLODE:int = groupToExplode.cases[0].color;
			
			//-----------------------------------------------------------------------------------//
		
			if(groupToExplode.cases.length < 8){
				//trace("not enough cases in that group to make a frame");	
				return [];
			}
			
			//-----------------------------------------------------------------------------------//
		
			var extremities:Array = groupToExplode.getExtremities();
			var top:int = extremities[0];
			var right:int = extremities[1];
			var bottom:int = extremities[2];
			var left:int = extremities[3];
			
			if(top < 0){
				//trace("this group has no top");
				return [];	
			}
			
			if(right < 0){
				//trace("this group has no right");
				return [];	
			}
			
			if(bottom < 0){
				//trace("this group has no down");
				return [];	
			}
			
			if(left < 0){
				//trace("this group has no left");
				return [];	
			}

			if(right - left < 2){
				//trace("this group has no right-left place");
				return [];	
			}

			if(bottom - top < 2){
				//trace("this group has no bottom-top place");
				return [];	
			}
				
				
			//-----------------------------------------------------------------------------------//
			
			// caseInside : everything inside the extremities : same color as groupToExplode, or empty case or another color. 
			var casesInside:ArrayCollection = new ArrayCollection();
			for(var i:int = left+1; i < right; i++){
				for(var j:int = top+1; j < bottom; j++){
					
					if(Session.cases[i][j].color != COLOR_OF_GROUP_TO_EXPLODE
					|| !groupToExplode.contains(Session.cases[i][j]))
						casesInside.addItem(Session.cases[i][j]);
						
				}
			}
			
			//-----------------------------------------------------------------------------------//
			// deal with these insiders
			
			//trace("create insideGroups");
			var insideGroups:ArrayCollection = new ArrayCollection();
			var casesAndInsideGroupsMapping:Map = new Map();
			
			for(j = top+1; j < bottom; j++){
				for(i = left+1; i < right; i++){
					if(casesInside.contains(Session.cases[i][j])){
						//trace("insider ["+i+"]["+j+"]");
						var _groupOfTheCaseOnTop:CaseGroupInside = casesAndInsideGroupsMapping.get(Session.cases[i][j-1]) as CaseGroupInside;
						if(_groupOfTheCaseOnTop == null){
							// the case on the top does not have a group : looking on the left
							
							var _groupOfTheCaseOnLeft:CaseGroupInside = casesAndInsideGroupsMapping.get(Session.cases[i-1][j]) as CaseGroupInside;
							if(_groupOfTheCaseOnLeft == null){
								// the case on the left does not have a group : creating a new group
								//trace("added in a new group");
								var caseGroupInside:CaseGroupInside = new CaseGroupInside();
								caseGroupInside.add(Session.cases[i][j]);
								
								insideGroups.addItem(caseGroupInside);
								casesAndInsideGroupsMapping.put(Session.cases[i][j], caseGroupInside);
							}
							else{
								// the case on the top got a group : adding this one to this group	
								//trace("added in a the group of the left neighbourg");
								_groupOfTheCaseOnLeft.add(Session.cases[i][j]);
								casesAndInsideGroupsMapping.put(Session.cases[i][j], _groupOfTheCaseOnLeft);
							}
						}
						else{
							// the case on the top got a group : adding this one to this group	
							//trace("added in a the group of the top neighbourg");
							_groupOfTheCaseOnTop.add(Session.cases[i][j]);
							casesAndInsideGroupsMapping.put(Session.cases[i][j], _groupOfTheCaseOnTop);
							
							// looking on the left if the neighbourg was added in another group : 
							// if so, merge the 2 groups.
							_groupOfTheCaseOnLeft = casesAndInsideGroupsMapping.get(Session.cases[i-1][j]) as CaseGroupInside;
							if(_groupOfTheCaseOnLeft != null && _groupOfTheCaseOnLeft != _groupOfTheCaseOnTop){
								
								// the case on the left got another group : merge this one with the group of the top neighbourg	
								//trace("group of the left merged with the group of the top neighbourgs");
								_groupOfTheCaseOnTop.merge(_groupOfTheCaseOnLeft);
								
								for each(var _case:Case in _groupOfTheCaseOnLeft.cases){
									casesAndInsideGroupsMapping.remove(_case);
									casesAndInsideGroupsMapping.put(_case, _groupOfTheCaseOnTop);
								}

								insideGroups.removeItemAt(insideGroups.getItemIndex(_groupOfTheCaseOnLeft));
							}
						}
					}
				}
			}
			
			// here all the insideGroups are ready, and all insiders are mapped with each as well.
			// this is time to look around every insiders and see if all 8 neighbourgs are
			// either of the color of groupToExplode
			// or on the same insideGroup.
			// IF NOT : the insideGroup is FREE and not TO_EXPLODE anymore.

			//trace("verifying the insiders");
			//trace("there are " + insideGroups.length + " insideGroups");		
			for each(var insideGroup:CaseGroupInside in insideGroups){
				//trace("--------------");
				//trace(insideGroup.toString());
				//trace("--------------");
				for each(var insider:Case in insideGroup.cases){
					validateInsiders(insider, insideGroups, casesAndInsideGroupsMapping.get(Session.cases[insider.x][insider.y]) as CaseGroupInside);
				}	
			}

			var result:Array = [];
			for each(insideGroup in insideGroups){
				if(insideGroup.status == CaseGroupInside.TO_EXPLODE){
					
					//trace("FOUND " + insideGroup.cases.length + " insiders");
					for each(var _c:Case in insideGroup.cases){
						result.push(_c);

						//------------------------------------------------------//
						// forcement le group contenant cette case est a l'INTERIEUR du groupToExplode
						// donc il va exploser avec 
						// donc : removing this group from groups[Session.cases[i][j].color]
						// car à la fin de explode() on fait juste un pop() pour virer groupToExplode
						
						removeTheGroupContainingThisCaseFromColorGroupsIfNotDoneYet(_c);
						
						//------------------------------------------------------//	
					}
					
				}
			}
				
			return result;
		}
		
		private function validateInsiders(insider:Case, insideGroups:ArrayCollection, currentInsideGroup:CaseGroupInside):void{
			//trace("looking for insider ["+insider.x+"]["+insider.y+"]");			
			
			if(currentInsideGroup.status == CaseGroupInside.FREE)
				return;
							
			var foundNeighbourg1:Boolean = false;
			var foundNeighbourg2:Boolean = false;
			var foundNeighbourg3:Boolean = false;
			var foundNeighbourg4:Boolean = false;
			var foundNeighbourg5:Boolean = false;
			var foundNeighbourg6:Boolean = false;
			var foundNeighbourg7:Boolean = false;
			var foundNeighbourg8:Boolean = false;
			
			if(groupToExplode.contains(Session.cases[insider.x - 1][insider.y - 1])){
				foundNeighbourg1 = true;
				//trace("["+(insider.x - 1)+"]["+(insider.y - 1)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x][insider.y - 1])){
				foundNeighbourg2 = true;
				//trace("["+(insider.x)+"]["+(insider.y - 1)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x + 1][insider.y - 1])){
				foundNeighbourg3 = true;
				//trace("["+(insider.x + 1)+"]["+(insider.y - 1)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x - 1][insider.y])){
				foundNeighbourg4 = true;
				//trace("["+(insider.x - 1)+"]["+(insider.y)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x + 1][insider.y])){
				foundNeighbourg5 = true;
				//trace("["+(insider.x + 1)+"]["+(insider.y)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x - 1][insider.y + 1])){
				foundNeighbourg6 = true;
				//trace("["+(insider.x - 1)+"]["+(insider.y + 1)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x][insider.y + 1])){
				foundNeighbourg7 = true;
				//trace("["+(insider.x)+"]["+(insider.y + 1)+"] is in groupToExplode");
			}
			if(groupToExplode.contains(Session.cases[insider.x + 1][insider.y + 1])){
				foundNeighbourg8 = true;
				//trace("["+(insider.x + 1)+"]["+(insider.y + 1)+"] is in groupToExplode");
			}
			
			for each(var _insideGroup:CaseGroupInside in insideGroups){
				if(!foundNeighbourg1)
					if(_insideGroup.contains(Session.cases[insider.x - 1][insider.y - 1])){
						foundNeighbourg1 = true;
						//trace("["+(insider.x - 1)+"]["+(insider.y - 1)+"] is in an insideGroup");
					}
				if(!foundNeighbourg2)
					if(_insideGroup.contains(Session.cases[insider.x][insider.y - 1])){
						foundNeighbourg2 = true;
						//trace("["+(insider.x)+"]["+(insider.y - 1)+"] is in an insideGroup");
					}
				if(!foundNeighbourg3)
					if(_insideGroup.contains(Session.cases[insider.x + 1][insider.y - 1])){
						foundNeighbourg3 = true;
						//trace("["+(insider.x + 1)+"]["+(insider.y - 1)+"] is in an insideGroup");
					}
				if(!foundNeighbourg4)
					if(_insideGroup.contains(Session.cases[insider.x - 1][insider.y])){
						foundNeighbourg4 = true;
						//trace("["+(insider.x - 1)+"]["+(insider.y)+"] is in an insideGroup");
					}
				if(!foundNeighbourg5)
					if(_insideGroup.contains(Session.cases[insider.x + 1][insider.y])){
						foundNeighbourg5 = true;
						//trace("["+(insider.x + 1)+"]["+(insider.y)+"] is in an insideGroup");
					}
				if(!foundNeighbourg6)
					if(_insideGroup.contains(Session.cases[insider.x - 1][insider.y + 1])){
						foundNeighbourg6 = true;
						//trace("["+(insider.x - 1)+"]["+(insider.y + 1)+"] is in an insideGroup");
					}
				if(!foundNeighbourg7)
					if(_insideGroup.contains(Session.cases[insider.x][insider.y + 1])){
						foundNeighbourg7 = true;
						//trace("["+(insider.x)+"]["+(insider.y + 1)+"] is in an insideGroup");
					}
				if(!foundNeighbourg8)
					if(_insideGroup.contains(Session.cases[insider.x + 1][insider.y + 1])){
						foundNeighbourg8 = true;
						//trace("["+(insider.x + 1)+"]["+(insider.y + 1)+"] is in an insideGroup");
					}
			}
			
			
			if(!(foundNeighbourg1 
			  && foundNeighbourg2
		  	  && foundNeighbourg3
		 	  && foundNeighbourg4
			  && foundNeighbourg5
			  && foundNeighbourg6
			  && foundNeighbourg7
			  && foundNeighbourg8)){
				//trace("this insideGroup is free.");
				currentInsideGroup.status = CaseGroupInside.FREE;
			}
		}
		
		private function removeTheGroupContainingThisCaseFromColorGroupsIfNotDoneYet(_case:Case):void{
			
			//an empty insider
			if(_case.color == 0)
				return;
			
			//trace("removeTheGroupContainingThisCaseFromColorGroupsIfNotDoneYet ["+_case.x+"]["+_case.y+"]");
			var newColorGroups:Array = [];
			for each(var group:CaseGroup in groups[_case.color-1]){
				
				if(!group.contains(_case) && group != groupToExplode)
					newColorGroups.push(group);

			}
			
			if(_case.color == groupToExplode.cases[0].color){
				groupToExplode.add(_case);
				newColorGroups.push(groupToExplode);
			}
				
			groups[_case.color-1] = newColorGroups;
							
		}
}


}