package com.skooairs.core
{

import com.skooairs.constants.Session;
import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;
import com.skooairs.utils.Utils;

import com.skooairs.entities.Case;
import com.skooairs.entities.Square;

import flash.events.MouseEvent;
import spark.effects.Move;
import spark.components.Group;
import mx.controls.Image;

/**
The SquareMover
*/
public class SquareMover
{		
		//=====================================================================================//

		private static var instance : SquareMover = new SquareMover(); 
	
		public static function getInstance():SquareMover{
			return instance;
		}

		public function SquareMover(){}

		//=====================================================================================//

		private var UP:int = 0;
		private var TOP:int = 0;
		private var LEFT:int = 1;
		private var DOWN:int = 2;
		private var BOTTOM:int = 2;
		private var RIGHT:int = 3;
	
		private var last_x:int = -1;
		private var last_y:int = -1;

		private var lastClickMouseEvent:MouseEvent;
		private var lastMoveMouseEvent:MouseEvent;
	
		private var limitOnTheTopReached:Boolean = false;
		private var limitOnTheRightReached:Boolean = false;
		private var limitOnTheBottomReached:Boolean = false;
		private var limitOnTheLeftReached:Boolean = false;
	
		//if true : la derniere brique est en bordure : aucun click autorise avant le changement de cible
		private var CLICK_ENABLED:Boolean = false;

		// pour que les squares aient le temps de bouger avant deux-trois clics intempestifs
		// si moveToDo == moveDone : le travail est en cours, pas de click possible
		private var moveToDo:int; //++ si un clic est attribue
		private var moveDone:int; //++ a la fin des placeSquare
		
		//lorsque nbFrontiers == 9+9+7+7 = 32 le tour est rempli la partie est finie.
		private var nbFrontiers:int = 0;
		
		//-----------------------------------------------------------------------------------//
		
		// 0,1,2
		// nextSquare, waitingSquare, currentSquare
		private var squares:Array = [];		
		
		//-----------------------------------------------------------------------------------//

		public function reset():void {
			
			
			moveToDo = 0;
			moveDone = 1;
			squares = [];
			
			var nextSquareImage:Image = new Image();
			var nextSquareColor:int = Utils.random(Session.COLORS);
			nextSquareImage.source = Names.SQUARES_PATH + nextSquareColor+".png";
			nextSquareImage.x = Session.NEXT_SQUARE_X;
			nextSquareImage.y = Session.NEXT_SQUARE_Y;
			
			nextSquareImage.data = new Square(nextSquareColor, Numbers.CONSTRUCTOR);

			var waitingSquareImage:Image = new Image();
			var waitingSquareColor:int = Utils.random(Session.COLORS);
			waitingSquareImage.source = Names.SQUARES_PATH + waitingSquareColor+".png";
			waitingSquareImage.x = Session.WAITING_SQUARE_X;
			waitingSquareImage.y = Session.WAITING_SQUARE_Y;
			
			waitingSquareImage.data = new Square(waitingSquareColor, Numbers.CONSTRUCTOR);

			var currentSquareImage:Image = new Image();
			var currentSquareColor:int = Utils.random(Session.COLORS);
			currentSquareImage.source = Names.SQUARES_PATH + currentSquareColor+".png";
			currentSquareImage.x = Session.CURRENT_SQUARE_X;
			currentSquareImage.y = Session.CURRENT_SQUARE_Y;
			
			currentSquareImage.data = new Square(currentSquareColor, Numbers.CONSTRUCTOR);

			// click ON the image : elle est par dessus le squarecontainer donc le click doit etre ecoute en plus pour ce carre
			currentSquareImage.addEventListener(MouseEvent.CLICK, clickHandler); 

			//-----------------------------------------------------------------------------------//

			squares = [nextSquareImage, waitingSquareImage, currentSquareImage];									Session.play.board.removeAllElements();	
			Session.play.board.addElement(nextSquareImage);
			Session.play.board.addElement(waitingSquareImage);
			Session.play.board.addElement(currentSquareImage);
			
			//-----------------------------------------------------------------------------------//

			Session.play.shadowImage.source = Names.SQUARES_PATH 
											  +	(squares[2].data.status == Numbers.DESTRUCTOR ? 'boom_': '')
											  + squares[2].data.color
											  + ".png";

			last_x = -1;
			last_y = -1;
			nbFrontiers = 0;
			
			createBoard();
			
			var firstSquareColor:int = Utils.random(Session.COLORS);
			var firstSquare:Image = new Image();
			
			firstSquare.x = Numbers.X.getItemAt(4) as int;
			firstSquare.y = Numbers.Y.getItemAt(4) as int;
			firstSquare.source = Names.SQUARES_PATH + firstSquareColor + ".png";
			
			firstSquare.data = new Square(firstSquareColor, Numbers.CONSTRUCTOR);
			
			Session.play.squareContainer.addElement(firstSquare);
			Session.cases[4][4].fill(firstSquare);
			SquareExploder.getInstance().register(Session.cases[4][4]);
			
			Session.DISP_LAUNCH_TIME = true;
		}
		
		public function moveHandler(e:MouseEvent, fromMouse:Boolean):void {
			lastMoveMouseEvent = e;

	    	if(fromMouse && moveToDo == moveDone)
	    		return;
	    		
	    	var _x:int = getX(e.stageX-210, 1);
	    	var _y:int = getY(e.stageY-85, 1);
	    	
	    	//not changing case, no need to calculate
	    	if(_x == last_x && _y == last_y)
	    		return;
	    	else{
	    		// record last case
	    		last_x = _x;	
	    		last_y = _y;	
	    	}
	    	
	    	var insideBoard:Boolean = true;
	
			// dans les coins : on ne change pas.
			if((_x == -1 && _y == -1)
			|| (_x == -1 && _y == 111)
			|| (_x == 111 && _y == -1)
			|| (_x == 111 && _y == 111))
				return;
	    	
	    	// sur un des bords du plateau
			if(_y == -1 || _y == 111 || _x == -1  || _x == 111)
			   insideBoard = false;
			   
			
			limitOnTheTopReached = false;
			limitOnTheRightReached = false;
			limitOnTheBottomReached = false;
			limitOnTheLeftReached = false;
			
			var lastShadowX:int = Session.CURRENT_SHADOW_BOARD_X;
			var lastShadowY:int = Session.CURRENT_SHADOW_BOARD_Y;
			var lastClickEnabled:Boolean = CLICK_ENABLED;
	
			CLICK_ENABLED = true;
			
			// inside here, if the move is not possible (4 limits reached), the move will be forced via currentSquare
	    	setSquaresCoordinatesForMouseInCase(_x, _y, insideBoard);
	    	
	    	// try to see if the move has been performed 
	    	//(can be not performed on the filled frontiers)(on the border)
	    	//(can be not performed on a 4-way obstrued place)(insideBoard)
	    	if(lastShadowX == Session.CURRENT_SHADOW_BOARD_X
	    	&& lastShadowY == Session.CURRENT_SHADOW_BOARD_Y){
				 // no move was possible : on recupere l'interdiction de click qui reste valable (si elle etait levee) finalement
	    		 
				// no move was possible : on fait un move avec la souris sur l'emplacement du CURRENT_SQUARE (en 10,10 du carre)
				 _x = getX(Session.CURRENT_SQUARE_X+10, 1);
				 _y = getY(Session.CURRENT_SQUARE_Y+10, 1);
				 
				setSquaresCoordinatesForMouseInCase(_x, _y, false);
				 
				if(lastShadowX == Session.CURRENT_SHADOW_BOARD_X
	    		&& lastShadowY == Session.CURRENT_SHADOW_BOARD_Y){
	    			//toujours pas de possibilite pour la shadow : on remet l'interdiction de clic si elle y etait
					CLICK_ENABLED = lastClickEnabled;
	    		} 
	    	}
	    }
	
	    public function forceClick():void {
	    	clickHandler(lastMoveMouseEvent);
	    }

	    public function clickHandler(e:MouseEvent):void {
	    	
	    	if(!CLICK_ENABLED)
	    		return;
	    	
	    	if(moveToDo == moveDone)
	    		return;
	    	else
	    		moveToDo++;
	    		
	    	if(moveToDo%Numbers.NB_CLICK_FOR_A_BOOM == 0)
	    		Session.play.addBoomer();
    		Session.play.boomProgressBar.setProgress(moveToDo%Numbers.NB_CLICK_FOR_A_BOOM, 10);
	    	
	    	MusicPlayer.getInstance().playClickSound();

	    	lastClickMouseEvent = e;
	    	
	    	Session.DISP_LAUNCH_TIME = false; // hide the progessbar (shown after)
	    	Session.play.nextSquareMover.target = squares[0];
	    	Session.play.nextSquareMover.play();

	    	Session.play.waitingSquareMoverPrepare.target = squares[1];
	    	Session.play.waitingSquareMoverPrepare.play();

	    	Session.play.currentSquareMover.target = squares[2];
	    	Session.play.currentSquareMover.play();
			
	    }
	
		public function boomButtonPushed():Boolean{
			if(Session.NB_BOOMS == 0){
				if(!Session.BOOM_SCALE_LOCK)
					Session.play.boomsScale.play();
				return false; 
			}

			squares[1].data.status = Numbers.DESTRUCTOR;
			squares[1].source = Names.SQUARES_PATH 
								  +	'boom_'
								  + squares[1].data.color
								  + ".png";
			return true;
		}
	
		// appel à la fin de Play.currentSquareMover (effectEnd)
		public function placeNewSquare():void{
			
			var newSquare:Image = new Image();
			var newSquareColor:int = Utils.random(Session.COLORS);

			newSquare.source = Names.SQUARES_PATH + newSquareColor+".png";
			newSquare.x = Session.NEXT_SQUARE_X;
			newSquare.y = Session.NEXT_SQUARE_Y;
			
			newSquare.data = new Square(newSquareColor, Numbers.CONSTRUCTOR);
			
			Session.play.board.addElement(newSquare);
			//Session.cases[Session.CURRENT_SHADOW_BOARD_X][Session.CURRENT_SHADOW_BOARD_Y].fill(squares[2], Session.CURRENT_SHADOW_BOARD_X, Session.CURRENT_SHADOW_BOARD_Y);
			Session.cases[Session.CURRENT_SHADOW_BOARD_X][Session.CURRENT_SHADOW_BOARD_Y].fill(squares[2]);
			SquareExploder.getInstance().register(Session.cases[Session.CURRENT_SHADOW_BOARD_X][Session.CURRENT_SHADOW_BOARD_Y]);
				
	    	var explosion:Boolean = false;
			if(squares[2].data.status == Numbers.DESTRUCTOR)
				explosion = true;
				
			Session.play.board.removeElement(squares[2]);
			Session.play.squareContainer.addElement(squares[2]);

			squares[2] = squares[1];
			squares[1] = squares[0];
			squares[0] = newSquare;
			
			squares[1].source = Names.SQUARES_PATH 
								  +	(squares[1].data.status == Numbers.DESTRUCTOR ? 'boom_': '')
								  + squares[1].data.color
								  + ".png";
			squares[2].source = Names.SQUARES_PATH 
								  +	(squares[2].data.status == Numbers.DESTRUCTOR ? 'boom_': '')
								  + squares[2].data.color
								  + ".png";
			squares[2].addEventListener(MouseEvent.CLICK, clickHandler); 
			
			Session.play.shadowImage.source = Names.SQUARES_PATH 
											  +	(squares[2].data.status == Numbers.DESTRUCTOR ? 'boom_': '')
											  + squares[2].data.color
											  + ".png";
			
			// border !
			if(Session.CURRENT_SHADOW_BOARD_X == 0
			|| Session.CURRENT_SHADOW_BOARD_X == 8
	    	|| Session.CURRENT_SHADOW_BOARD_Y == 0
	    	|| Session.CURRENT_SHADOW_BOARD_Y == 8){
				
				if(!explosion)
					CLICK_ENABLED = false;
	
				nbFrontiers++;
			}	
			
			var nbFrontiersExploded:int = 0;	
			if(explosion)
				nbFrontiersExploded = SquareExploder.getInstance().explode();
	
			nbFrontiers -= nbFrontiersExploded;
	
			if(nbFrontiers == 32){
				Session.play.gameOver();
			}
			else{
				// calculate new shadow
				last_x = -111;
				last_y = -111;
				moveHandler(lastClickMouseEvent, false);
				
				
				// deplace l'ancien waiting devenu current au bon endroit calcule
	    		Session.play.waitingSquareMover.target = squares[2];
	    		Session.play.waitingSquareMover.play(); // call waitingMoveDone() in effectEnd
			}

		}
		
		public function waitingMoveDone():void{
			moveDone++;
		}
	
		//-----------------------------------------------------------------------------------//
	
		private function setSquaresCoordinatesForMouseInCase(i:int, j:int, insideBoard:Boolean):void{
			
			if(insideBoard){
					
				var statusToLookFor:int;
				
				if(Session.cases[i][j].status == Case.EMPTY){
					statusToLookFor = Case.FULL;
				}
				else{
					statusToLookFor = Case.EMPTY;
				}
				
				limitOnTheTopReached = false;
				limitOnTheRightReached = false;
				limitOnTheBottomReached = false;
				limitOnTheLeftReached = false;
				
				lookForNextCase(statusToLookFor, UP, i, j, 1);
			}
			else{
				//sur un des bords du plateaus
	
				if(i == -1){
					// on the left hand side : try to launch on the right.
					lookForLaunching(RIGHT, 0, j, 1);
				}	
				else if(i == 111){
					// on the right hand side : try to launch on the left.
					lookForLaunching(LEFT, 8, j, 1);
				}	
				else if(j == -1){
					// on the top side : try to launch on the bottom.
					lookForLaunching(DOWN, i, 0, 1);
				}	
				else if(j == 111){
					// on the bottom side : try to launch on the top.
					lookForLaunching(UP, i, 8, 1);
				}	
			}
			
			
			// udpate the coordinates for the currentSquare (not bind from mxml as it is a 'new Image()')
			squares[2].x = Session.CURRENT_SQUARE_X;
			squares[2].y = Session.CURRENT_SQUARE_Y;
		}
		
		private function lookForLaunching(wayToLookFor:int, from_x:int, from_y:int, step:int):void{
	
			switch(wayToLookFor){
				case UP:
					
					if(from_y == 8 && Session.cases[from_x][8].status == Case.FULL)
						return; // the first case going up is full : no way to launch
					
					if(step == 9){
						// found the limit : the last case is the good one
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(0) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SQUARE_Y = Numbers.BOARD_BOTTOM;
						
						Session.CURRENT_SHADOW_BOARD_X = from_x;
						Session.CURRENT_SHADOW_BOARD_Y = 0;
						Session.CURRENT_WAY_FROM = BOTTOM;
						
						return;					
					}
					
					if(Session.cases[from_x][from_y-step].status == Case.EMPTY)
						lookForLaunching(UP, from_x, from_y, step+1);
					else{
						// found the case
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(from_y-step+1) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SQUARE_Y = Numbers.BOARD_BOTTOM;
						
						Session.CURRENT_SHADOW_BOARD_X = from_x;
						Session.CURRENT_SHADOW_BOARD_Y = from_y-step+1;
						Session.CURRENT_WAY_FROM = BOTTOM;
						
						return;
					}	
					
					break;
				case DOWN:
	
					if(from_y == 0 && Session.cases[from_x][0].status == Case.FULL)
						return; // the first case going down is full : no way to launch
					
					if(step == 9){
						// found the limit : the last case is the good one
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(8) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SQUARE_Y = Numbers.BOARD_TOP;
						
						Session.CURRENT_SHADOW_BOARD_X = from_x;
						Session.CURRENT_SHADOW_BOARD_Y = 8;
						Session.CURRENT_WAY_FROM = TOP;
						
						return;					
					}
					
					if(Session.cases[from_x][from_y+step].status == Case.EMPTY)
						lookForLaunching(DOWN, from_x, from_y, step+1);
					else{
						// found the case
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(from_y+step-1) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.X.getItemAt(from_x) as int;
						Session.CURRENT_SQUARE_Y = Numbers.BOARD_TOP
						
						Session.CURRENT_SHADOW_BOARD_X = from_x;
						Session.CURRENT_SHADOW_BOARD_Y = from_y+step-1;
						Session.CURRENT_WAY_FROM = TOP;
						
						return;
					}	
					
					break;
				case LEFT:
	
					if(from_x == 8 && Session.cases[8][from_y].status == Case.FULL)
						return; // the first case going left is full : no way to launch
					
					if(step == 9){
						// found the limit : the last case is the good one
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(0) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.BOARD_RIGHT;
						Session.CURRENT_SQUARE_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SHADOW_BOARD_X = 0;
						Session.CURRENT_SHADOW_BOARD_Y = from_y;
						Session.CURRENT_WAY_FROM = RIGHT;
						
						return;					
					}
					
					if(Session.cases[from_x-step][from_y].status == Case.EMPTY)
						lookForLaunching(LEFT, from_x, from_y, step+1);
					else{
						// found the case
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(from_x-step+1) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.BOARD_RIGHT;
						Session.CURRENT_SQUARE_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SHADOW_BOARD_X = from_x-step+1;
						Session.CURRENT_SHADOW_BOARD_Y = from_y;
						Session.CURRENT_WAY_FROM = RIGHT;
						
						return;
					}	
					break;
				case RIGHT:
	
					if(from_x == 0 && Session.cases[0][from_y].status == Case.FULL)
						return; // the first case going up is full : no way to launch
					
					if(step == 9){
						// found the limit : the last case is the good one
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(8) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.BOARD_LEFT;
						Session.CURRENT_SQUARE_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SHADOW_BOARD_X = 8;
						Session.CURRENT_SHADOW_BOARD_Y = from_y;
						Session.CURRENT_WAY_FROM = LEFT;
	
						return;					
					}
					
					if(Session.cases[from_x+step][from_y].status == Case.EMPTY)
						lookForLaunching(RIGHT, from_x, from_y, step+1);
					else{
						// found the case
						Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(from_x+step-1) as int;
						Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SQUARE_X = Numbers.BOARD_LEFT;
						Session.CURRENT_SQUARE_Y = Numbers.Y.getItemAt(from_y) as int;
						
						Session.CURRENT_SHADOW_BOARD_X = from_x+step-1;
						Session.CURRENT_SHADOW_BOARD_Y = from_y;
						Session.CURRENT_WAY_FROM = LEFT;
						
						return;
					}	
					break;
			}
		}
		
		private function lookForNextCase(statusToLookFor:int, wayToLookFor:int, from_x:int, from_y:int, step:int):void{
			
			if(limitOnTheTopReached && limitOnTheRightReached && limitOnTheBottomReached && limitOnTheLeftReached){
				trace("4 limits reached ! no place for this square from here !");
				if(statusToLookFor == Case.FULL){
					trace("was looking for a full case : try to move like moving on the current_square");
					//in this case, the mouse in on an empty case but no way to get here : act like a full case !
					//begin the search again, with the other statusToLookFor
								
					limitOnTheTopReached = false;
					limitOnTheRightReached = false;
					limitOnTheBottomReached = false;
					limitOnTheLeftReached = false;
					
					lookForNextCase(Case.EMPTY, wayToLookFor, from_x, from_y, 1);	
				}
				else{
					trace("was looking for an empty case : NOTHING");
					// look for an empty case and no empty case possible !
					
					//if(Session.CURRENT_SHADOW_BOARD_X == from_x || Session.CURRENT_SHADOW_BOARD_Y == from_y)
					//	CLICK_ENABLED = false;
					
					//le move n'est pas possible : CLICK_ENABLED va rester interdit si il l'etait et le move sera force depuis le current_square	
				}
					
				return;
			}
			switch(wayToLookFor){
				case UP:
					// la recherche sort du plateau
					if(from_y-step < 0){
						if(statusToLookFor == Case.FULL && testWayTo(from_x, 0, BOTTOM))
							//on a trouve une case pleine (le bord) et le chemin est ok	
							return;
						else{
							//soit le chemin est obstrue par le bas
							//soit on cherche une case vide et le chemin vers le haut est bouche
							// dans les 2 cas on part chercher sur la droite
							limitOnTheTopReached = true;
						}
					}
					//dans le du plateau
					else{
						if(Session.cases[from_x][from_y-step].status == statusToLookFor){
							if(statusToLookFor == Case.EMPTY){
								if(testWayTo(from_x, from_y-step, TOP))
									return;
							}
							else{
								if(testWayTo(from_x, from_y-step+1, BOTTOM)){
									return;
								}
							}
						}
					}
	
					lookForNextCase(statusToLookFor, RIGHT, from_x, from_y, step);
					break;
				case RIGHT:
					// la recherche sort du plateau
					if(from_x+step > 8){
						if(statusToLookFor == Case.FULL && testWayTo(8, from_y, LEFT))
							//on a trouve une case pleine (le bord) et le chemin est ok	
							return;
						else{
							//soit le chemin est obstrue par la gauche
							//soit on cherche une case vide et le chemin vers la droite est bouche
							// dans les 2 cas on part chercher sur le bas
							limitOnTheRightReached = true;
						}
					}
					//dans le du plateau
					else{
						if(Session.cases[from_x+step][from_y].status == statusToLookFor){
							if(statusToLookFor == Case.EMPTY){
								if(testWayTo(from_x+step, from_y, RIGHT))
									return;
							}
							else if(testWayTo(from_x+step-1, from_y, LEFT)){
								return;
							}
						}
					}
	
					lookForNextCase(statusToLookFor, DOWN, from_x, from_y, step);
					break;
				case DOWN:
					// la recherche sort du plateau
					if(from_y+step > 8){
						if(statusToLookFor == Case.FULL && testWayTo(from_x, 8, TOP))
							//on a trouve une case pleine (le bord) et le chemin est ok	
							return;
						else{
							//soit le chemin est obstrue par le haut
							//soit on cherche une case vide et le chemin vers le bas est bouche
							// dans les 2 cas on part chercher sur la gauche
							limitOnTheBottomReached = true;
						}
					}
					//dans le du plateau
					else{
						if(Session.cases[from_x][from_y+step].status == statusToLookFor){
							if(statusToLookFor == Case.EMPTY){
								if(testWayTo(from_x, from_y+step, BOTTOM))
									return;
							}
							else if(testWayTo(from_x, from_y+step-1, TOP)){
								return;
							}
						}
					}
	
					lookForNextCase(statusToLookFor, LEFT, from_x, from_y, step);
					break;	
				case LEFT:
					// la recherche sort du plateau
					if(from_x-step < 0){
						if(statusToLookFor == Case.FULL && testWayTo(0, from_y, RIGHT))
							//on a trouve une case pleine (le bord) et le chemin est ok	
							return;
						else{
							//soit le chemin est obstrue par la droite
							//soit on cherche une case vide et le chemin vers la gauche est bouche
							// dans les 2 cas on part chercher sur le haut
							limitOnTheLeftReached = true;
						}
					}
					//dans le du plateau
					else{
						if(Session.cases[from_x-step][from_y].status == statusToLookFor){
							if(statusToLookFor == Case.EMPTY){
								if(testWayTo(from_x-step, from_y, LEFT))
									return;
							}
							else if(testWayTo(from_x-step+1, from_y, RIGHT)){
								return;
							}
						}
					}
	
					lookForNextCase(statusToLookFor, UP, from_x, from_y, step+1);
					break;
	
			}
		}
		
		private function testWayTo(x:int, y:int, wayFrom:int):Boolean{
			
			switch(wayFrom){
				case TOP:
					for(var top_j:int = 0; top_j < y; top_j++){
						if(Session.cases[x][top_j].status == Case.FULL){
							return false;
						}
					}
					break;
				case LEFT:
					for(var left_i:int = 0; left_i < x; left_i++){
						if(Session.cases[left_i][y].status == Case.FULL){
							return false;
						}
					}
					break;
				case BOTTOM:
					for(var bottom_j:int = 8; bottom_j > y; bottom_j--){
						if(Session.cases[x][bottom_j].status == Case.FULL){
							return false;
						}
					}
					break;
				case RIGHT:
					for(var right_i:int = 8; right_i > x; right_i--){
						if(Session.cases[right_i][y].status == Case.FULL){
							return false;
						}
					}
					break;
			}
			
			// if arrive here : the way is ok, so the case is possible : set coordinates
			Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(x) as int;
			Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(y) as int;
			Session.CURRENT_SHADOW_BOARD_X = x;
			Session.CURRENT_SHADOW_BOARD_Y = y;
			Session.CURRENT_WAY_FROM = wayFrom;
			
			switch(wayFrom){
				case TOP:
					Session.CURRENT_SQUARE_X = Numbers.X.getItemAt(x) as int;
					Session.CURRENT_SQUARE_Y = Numbers.BOARD_TOP;
					break;
				case BOTTOM:
					Session.CURRENT_SQUARE_X = Numbers.X.getItemAt(x) as int;
					Session.CURRENT_SQUARE_Y = Numbers.BOARD_BOTTOM;
					break;
				case LEFT:
					Session.CURRENT_SQUARE_X = Numbers.BOARD_LEFT;
					Session.CURRENT_SQUARE_Y = Numbers.Y.getItemAt(y) as int;
					break;
				case RIGHT:
					Session.CURRENT_SQUARE_X = Numbers.BOARD_RIGHT;
					Session.CURRENT_SQUARE_Y = Numbers.Y.getItemAt(y) as int;
					break;
			}
	
			return true;
		}
		
		public function getX(x:int, columnToTest:int):int{
				
			if(x < 48)
				return -1;
			if(x > Numbers.X.getItemAt(8)+45)
				return 111;
			
			if(columnToTest == 9)
				return 8;
				
			if(x < Numbers.X.getItemAt(columnToTest))
				return columnToTest-1;
			else
				return getX(x, columnToTest+1);
		}
	
		public function getY(y:int, lineToTest:int):int{
					
			if(y < 48)
				return -1;
			if(y > Numbers.Y.getItemAt(8)+45)
				return 111;
				
			if(lineToTest == 9)
				return 8;
				
			if(y < Numbers.Y.getItemAt(lineToTest))
				return lineToTest-1;
			else
				return getY(y, lineToTest+1);
		}		
		//-----------------------------------------------------------------------------------//
	
		private function createBoard():void {
			Session.play.squareContainer.removeAllElements();
			Session.cases = [[],[],[],[],[],[],[],[],[]];
			
			for(var i:int = 0; i<9; i++){
				for(var j:int = 0; j<9; j++){
					Session.cases[i][j] = new Case(i,j);	
				}
			}	
		}

}
		

}