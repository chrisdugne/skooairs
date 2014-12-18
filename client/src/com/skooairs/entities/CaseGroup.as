package com.skooairs.entities
{

/*
CaseGroup : contient un groupe de cases de meme couleur et adjacentes
*/
[Bindable]
public class CaseGroup
{

	//-----------------------------------------------------------------------------------//

	protected var _cases:Array;
	protected var placement:Array;
	
	//-----------------------------------------------------------------------------------//

	public function CaseGroup(){
		_cases = [];
		placement = [[],[],[],[],[],[],[],[],[]];
		
		for(var i:int = 0; i <  9; i++){
			for(var j:int = 0; j <  9; j++){
				placement[i][j] = false;
			}
		}
	}

	//-----------------------------------------------------------------------------------//
	
	// on ajoute une case qui vient d'arriver : on est sur qu'elle n'est pas dans le groupe
	// le merge des groupes qu'elle lie a ete fait avant, donc on la rajoute bein dans son unique nouveau groupe
	public function add(_case:Case):void {
		_cases.push(_case);
		
		placement[_case.x][_case.y] = true;
	}

	public function contains(_case:Case):Boolean {
		for each(var _c:Case in _cases){
			if(_c == _case)
				return true;	
		}
		
		return false;
	}

	public function merge(group:CaseGroup):void {
		for each(var _case:Case in group.cases){
			add(_case);	
		}
	}


	//-----------------------------------------------------------------------------------//

	public function getExtremities():Array{
		
		var up:int;
		var down:int;
		var right:int;
		var left:int;

		var nb_up:int = -1;
		var nb_down:int = -1;
		var nb_right:int = -1;
		var nb_left:int = -1;

		//--------------------------------//
		
		var foundRight:Boolean = false;
		for(var r_i:int = 8; r_i >= 0; r_i--){
			nb_right = 0;
			
			for(var r_j:int = 0; r_j <  9; r_j++){
				if(placement[r_i][r_j])
					nb_right++;
				else
					nb_right = 0;
				
				if(nb_right == 3){
					foundRight = true;
					break;
				}
			}
			
			if(foundRight){
				right = r_i;
				break;
			}
		}

		//--------------------------------//
		
		var foundLeft:Boolean = false;
		for(var l_i:int = 0; l_i <  9; l_i++){
			nb_left = 0;
			
			for(var l_j:int = 0; l_j <  9; l_j++){
				
				if(placement[l_i][l_j])
					nb_left++;
				else
					nb_left = 0;
				
				if(nb_left == 3){
					foundLeft = true;
					break;
				}
			}
			
			if(foundLeft){
				left = l_i;
				break;
			}
		}

		//--------------------------------//
		
		var foundUp:Boolean = false;
		for(var u_j:int = 0; u_j <  9; u_j++){
			nb_up = 0;
			
			for(var u_i:int = 0; u_i <  9; u_i++){
				if(placement[u_i][u_j])
					nb_up++;
				else
					nb_up = 0;
				
				if(nb_up == 3){
					foundUp = true;
					break;
				}
			}
			
			if(foundUp){
				up = u_j;
				break;
			}
		}

		//--------------------------------//
		
		var foundDown:Boolean = false;
		for(var d_j:int = 8; d_j >= 0; d_j--){
			nb_down = 0;
			
			for(var d_i:int = 0; d_i <  9; d_i++){
				if(placement[d_i][d_j])
					nb_down++;
				else
					nb_down = 0;
				
				if(nb_down == 3){
					foundDown = true;
					break;
				}
			}
			
			if(foundDown){
				down = d_j;
				break;
			}
		}

		//--------------------------------//
		
		return [up, right, down, left];
	}
	
	//-----------------------------------------------------------------------------------//


	public function get cases():Array {
		return _cases;
	}

	public function set cases(o:Array):void {
		_cases = o;
	}

	public function toString():String{
		var toString:String = "";

		toString += ("cases : " + _cases) + "\n";

		return toString;
	}

	//-----------------------------------------------------------------------------------//



}
}

