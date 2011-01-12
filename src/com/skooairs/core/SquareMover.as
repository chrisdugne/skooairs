package com.skooairs.core
{

import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Session;
import com.skooairs.constants.Translations;
import com.skooairs.entities.Case;
import com.skooairs.entities.Square;
import com.skooairs.forms.Play;
import com.skooairs.utils.Utils;

import flash.events.MouseEvent;
import flash.utils.setInterval;

import flashx.textLayout.formats.WhiteSpaceCollapse;

import mx.controls.Image;

import spark.components.Group;
import spark.components.Label;
import spark.effects.Move;

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
		// nextSquare, waitingSquare
		private var squares:Array = [];		
		
		// currentSquare (le square cache qui sera le depart du placement, et qui sert au calcul de shadowImage)
		private	var currentSquareImage:Image;
		
		//-----------------------------------------------------------------------------------//

		public function reset():void {
			
			
			Session.play.tutorialContinueLabel.visible = false;
			Session.play.tutorialMiddleLabel.visible = false;
			Session.play.tutorialFinalLabel.visible = false;
			
			if(Session.TUTORIAL){
				specialReset();
				return;
			}
			
			moveToDo = 0;
			moveDone = 1;
			squares = [];
			
			var nextSquareImage:Image = new Image();
			var nextSquareColor:int = Utils.random(Session.COLORS);
			nextSquareImage.source = ImageContainer.getSquare(nextSquareColor);
			nextSquareImage.x = Session.NEXT_SQUARE_X;
			nextSquareImage.y = Session.NEXT_SQUARE_Y;
			
			nextSquareImage.data = new Square(nextSquareColor, Numbers.CONSTRUCTOR);

			var waitingSquareImage:Image = new Image();
			var waitingSquareColor:int = Utils.random(Session.COLORS);
			waitingSquareImage.source = ImageContainer.getSquare(waitingSquareColor)
			waitingSquareImage.x = Session.WAITING_SQUARE_X;
			waitingSquareImage.y = Session.WAITING_SQUARE_Y;
			
			waitingSquareImage.data = new Square(waitingSquareColor, Numbers.CONSTRUCTOR);

			
			currentSquareImage = new Image();
			currentSquareImage.x = currentSquareImage.x;
			currentSquareImage.y = currentSquareImage.y;
			

			// click ON the image : elle est par dessus le squarecontainer donc le click doit etre ecoute en plus pour ce carre
			currentSquareImage.addEventListener(MouseEvent.CLICK, clickHandler); 
			currentSquareImage.visible = false;

			//-----------------------------------------------------------------------------------//

			squares = [nextSquareImage, waitingSquareImage];									Session.play.board.removeAllElements();	
			Session.play.board.addElement(nextSquareImage);
			Session.play.board.addElement(waitingSquareImage);
			Session.play.board.addElement(currentSquareImage);
			
			//-----------------------------------------------------------------------------------//

			if(squares[1].data.status == Numbers.DESTRUCTOR){
				Session.play.shadowImage.source = ImageContainer.getSquareBoom(squares[1].data.color);
			}
			else{
				Session.play.shadowImage.source = ImageContainer.getSquare(squares[1].data.color);
			}
			
			Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(4) as int;
			Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(3) as int;
				
			//-----------------------------------------------------------------------------------//

			last_x = -1;
			last_y = -1;
			nbFrontiers = 0;
			
			createBoard();
			
			var firstSquareColor:int = Utils.random(Session.COLORS);
			var firstSquare:Image = new Image();
			
			firstSquare.x = Numbers.X.getItemAt(4) as int;
			firstSquare.y = Numbers.Y.getItemAt(4) as int;
			firstSquare.source = ImageContainer.getSquare(firstSquareColor);
			
			firstSquare.data = new Square(firstSquareColor, Numbers.CONSTRUCTOR);
			
			Session.play.squareContainer.addElement(firstSquare);
			Session.cases[4][4].fill(firstSquare);
			SquareExploder.getInstance().register(Session.cases[4][4]);
			
			Session.DISP_LAUNCH_TIME = true;
		}
		
		private var tutorialStep:int;
		public function specialReset():void {
			
			moveToDo = 0;
			moveDone = 1;
			squares = [];
			tutorialStep = -1;
			
			var nextSquareImage:Image = new Image();
			nextSquareImage.source = ImageContainer.getSquare(1);
			nextSquareImage.x = Session.NEXT_SQUARE_X;
			nextSquareImage.y = Session.NEXT_SQUARE_Y;
			
			nextSquareImage.data = new Square(1, Numbers.CONSTRUCTOR);
			
			var waitingSquareImage:Image = new Image();
			waitingSquareImage.source = ImageContainer.getSquare(1)
			waitingSquareImage.x = Session.WAITING_SQUARE_X;
			waitingSquareImage.y = Session.WAITING_SQUARE_Y;
			
			waitingSquareImage.data = new Square(1, Numbers.CONSTRUCTOR);
			
			
			currentSquareImage = new Image();
			currentSquareImage.x = currentSquareImage.x;
			currentSquareImage.y = currentSquareImage.y;
			
			
			// click ON the image : elle est par dessus le squarecontainer donc le click doit etre ecoute en plus pour ce carre
			currentSquareImage.addEventListener(MouseEvent.CLICK, clickHandler); 
			currentSquareImage.visible = false;
			
			//-----------------------------------------------------------------------------------//
			
			squares = [nextSquareImage, waitingSquareImage];
			
			Session.play.board.removeAllElements();	
			Session.play.board.addElement(nextSquareImage);
			Session.play.board.addElement(waitingSquareImage);
			Session.play.board.addElement(currentSquareImage);
			
			//-----------------------------------------------------------------------------------//
			
			if(squares[1].data.status == Numbers.DESTRUCTOR){
				Session.play.shadowImage.source = ImageContainer.getSquareBoom(squares[1].data.color);
			}
			else{
				Session.play.shadowImage.source = ImageContainer.getSquare(squares[1].data.color);
			}
			
			Session.CURRENT_SHADOW_X = Numbers.X.getItemAt(4) as int;
			Session.CURRENT_SHADOW_Y = Numbers.Y.getItemAt(3) as int;
			
			//-----------------------------------------------------------------------------------//
			
			last_x = -1;
			last_y = -1;
			nbFrontiers = 0;
			
			createBoard();
			
			//-----------------------------------------------------------------------------------//

			placeSquare(2,2,1);
			placeSquare(3,2,1);
			placeSquare(4,2,1);

			placeSquare(2,3,1);
			placeSquare(3,3,1);
			placeSquare(4,3,1);

			placeSquare(2,4,1);
			placeSquare(3,4,1);
			placeSquare(4,4,1);
			
			//-----------------------------------------------------------------------------------//

			Session.play.message(Translations.FOLLOW_ARROWS.getItemAt(Session.LANGUAGE) as String, -300);
			
			//-----------------------------------------------------------------------------------//
			
			Session.TIME = Numbers.TIME_TUTO;
			Session.DISP_LAUNCH_TIME = true;

			//-----------------------------------------------------------------------------------//
			
			nextTutorialStep();
		}
		
		//-----------------------------------------------------------------------------------------------------//
		
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
				 _x = getX(currentSquareImage.x+10, 1);
				 _y = getY(currentSquareImage.y+10, 1);
				 
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

			//----------------------------------------//
			
			if(Session.TUTORIAL){
				
				if(tutorialStep == 3
				|| tutorialStep == 10){
					//boombutton required
					return;
				}

				if(tutorialStep == 5
				|| tutorialStep == 12){
					// continue
					nextTutorialStep();
					return;
				}
					
				if(Session.CURRENT_SHADOW_BOARD_X != stepX[tutorialStep]
				|| Session.CURRENT_SHADOW_BOARD_Y != stepY[tutorialStep]){
					Session.play.message("Oops !");
					return;
				}
				else{
					switch(tutorialStep){
						case 0:
						case 1:
						case 6:
						case 7:
						case 8:
							Session.play.message(Translations.GOOD.getItemAt(Session.LANGUAGE) as String);
							break;
					}
					nextTutorialStep();
				}
			}
	    	
			//----------------------------------------//
			
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

			// teleportation
			squares[1].x = currentSquareImage.x;
			squares[1].y = currentSquareImage.y;
			
	    	Session.play.currentSquareMover.target = squares[1];
			Session.play.currentSquareMover.xFrom = currentSquareImage.x;
			Session.play.currentSquareMover.yFrom = currentSquareImage.y;
			Session.play.currentSquareMover.xTo = Session.CURRENT_SHADOW_X;
			Session.play.currentSquareMover.yTo = Session.CURRENT_SHADOW_Y;
	    	Session.play.currentSquareMover.play();
			
	    }
	
		public function boomButtonPushed():Boolean{

			if(Session.TUTORIAL){
				if(tutorialStep == 3
				|| tutorialStep == 10){
					Session.play.message(Translations.READY_TO_EXPLODE.getItemAt(Session.LANGUAGE) as String, -160);
					nextTutorialStep();
				}
				else{
					Session.play.message("Oops");
					return false;
				}
			}
				
			//boom already set for this next square
			if(squares[1].data.status == Numbers.DESTRUCTOR)
				return false;
			
			if(Session.NB_BOOMS == 0){
				if(!Session.BOOM_SCALE_LOCK)
					Session.play.boomsScale.play();
				return false; 
			}

			squares[1].data.status = Numbers.DESTRUCTOR;
			squares[1].source = ImageContainer.getSquareBoom(squares[1].data.color); 
			
			Session.play.shadowImage.source = squares[1].source;
			
			return true;
		}
	
		// appel à la fin de Play.currentSquareMover (effectEnd)
		public function placeNewSquare():void{
			
			var newSquare:Image = new Image();
			var newSquareColor:int = Utils.random(Session.COLORS);
			if(Session.TUTORIAL)newSquareColor = tutorialcolors[tutorialStep];
			
			newSquare.source = ImageContainer.getSquare(newSquareColor);
			newSquare.x = Session.NEXT_SQUARE_X;
			newSquare.y = Session.NEXT_SQUARE_Y;
			
			newSquare.data = new Square(newSquareColor, Numbers.CONSTRUCTOR);
			
			Session.play.board.addElement(newSquare);
			Session.cases[Session.CURRENT_SHADOW_BOARD_X][Session.CURRENT_SHADOW_BOARD_Y].fill(squares[1]);
			SquareExploder.getInstance().register(Session.cases[Session.CURRENT_SHADOW_BOARD_X][Session.CURRENT_SHADOW_BOARD_Y]);
				
	    	var explosion:Boolean = false;
			if(squares[1].data.status == Numbers.DESTRUCTOR)
				explosion = true;
				
			squares[1].visible = true;
			Session.play.board.removeElement(squares[1]);
			Session.play.squareContainer.addElement(squares[1]);
			
			squares[1] = squares[0];
			squares[0] = newSquare;
			
			Session.play.shadowImage.source = squares[1].source;
			
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
	    		//Session.play.waitingSquareMover.target = squares[2];
				//squares[2].x = currentSquareImage.x;
				//squares[2].y = currentSquareImage.y;
				//squares[2].visible = false;
				waitingMoveDone();
				//Session.play.waitingSquareMover.play(); // call waitingMoveDone() in effectEnd
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
						
						currentSquareImage.x = Numbers.X.getItemAt(from_x) as int;
						currentSquareImage.y = Numbers.BOARD_BOTTOM;
						
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
						
						currentSquareImage.x = Numbers.X.getItemAt(from_x) as int;
						currentSquareImage.y = Numbers.BOARD_BOTTOM;
						
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
						
						currentSquareImage.x = Numbers.X.getItemAt(from_x) as int;
						currentSquareImage.y = Numbers.BOARD_TOP;
						
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
						
						currentSquareImage.x = Numbers.X.getItemAt(from_x) as int;
						currentSquareImage.y = Numbers.BOARD_TOP
						
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
						
						currentSquareImage.x = Numbers.BOARD_RIGHT;
						currentSquareImage.y = Numbers.Y.getItemAt(from_y) as int;
						
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
						
						currentSquareImage.x = Numbers.BOARD_RIGHT;
						currentSquareImage.y = Numbers.Y.getItemAt(from_y) as int;
						
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
						
						currentSquareImage.x = Numbers.BOARD_LEFT;
						currentSquareImage.y = Numbers.Y.getItemAt(from_y) as int;
						
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
						
						currentSquareImage.x = Numbers.BOARD_LEFT;
						currentSquareImage.y = Numbers.Y.getItemAt(from_y) as int;
						
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
				//trace("4 limits reached ! no place for this square from here !");
				if(statusToLookFor == Case.FULL){
					//trace("was looking for a full case : try to move like moving on the current_square");
					//in this case, the mouse in on an empty case but no way to get here : act like a full case !
					//begin the search again, with the other statusToLookFor
								
					limitOnTheTopReached = false;
					limitOnTheRightReached = false;
					limitOnTheBottomReached = false;
					limitOnTheLeftReached = false;
					
					lookForNextCase(Case.EMPTY, wayToLookFor, from_x, from_y, 1);	
				}
				else{
					//trace("was looking for an empty case : NOTHING");
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
					currentSquareImage.x = Numbers.X.getItemAt(x) as int;
					currentSquareImage.y = Numbers.BOARD_TOP;
					break;
				case BOTTOM:
					currentSquareImage.x = Numbers.X.getItemAt(x) as int;
					currentSquareImage.y = Numbers.BOARD_BOTTOM;
					break;
				case LEFT:
					currentSquareImage.x = Numbers.BOARD_LEFT;
					currentSquareImage.y = Numbers.Y.getItemAt(y) as int;
					break;
				case RIGHT:
					currentSquareImage.x = Numbers.BOARD_RIGHT;
					currentSquareImage.y = Numbers.Y.getItemAt(y) as int;
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

		//-----------------------------------------------------------------------------------//
		// TUTORIAL MANAGEMENT
		
		private var stepX:Array = [4, 5, 5, 0, 3, 0, 3, 4, 4, 3, 0, 3];
		private var stepY:Array = [5, 4, 5, 0, 5, 0, 4, 3, 2, 3, 0, 2];
		private var tutorialcolors:Array = [0, 1, 1, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1];
		private var arrows:Array = [ImageContainer.TUTO_ARROW_UP,
									ImageContainer.TUTO_ARROW_LEFT,
									ImageContainer.TUTO_ARROW_UP,
									ImageContainer.TUTO_ARROW_LEFT,
									ImageContainer.TUTO_ARROW_UP,
									null,
									ImageContainer.TUTO_ARROW_DOWN,
									ImageContainer.TUTO_ARROW_DOWN,
									ImageContainer.TUTO_ARROW_RIGHT,
									ImageContainer.TUTO_ARROW_DOWN,
									ImageContainer.TUTO_ARROW_LEFT,
									ImageContainer.TUTO_ARROW_RIGHT,
									];
		
		
		private function nextTutorialStep():void {
			
			tutorialStep++;
			
			Session.play.tutorialArrowImage.source = arrows[tutorialStep];
			Session.play.tutorialArrowImage.x = (Numbers.X.getItemAt(stepX[tutorialStep]) as int) + getXOffset();
			Session.play.tutorialArrowImage.y = (Numbers.Y.getItemAt(stepY[tutorialStep]) as int) + getYOffset();
			
			
			if(tutorialStep == 3
			|| tutorialStep == 10){
				Session.play.tutorialArrowImage.x = 95;
				Session.play.tutorialArrowImage.y = 325;
				Session.play.message(Translations.PRESS_SPACE.getItemAt(Session.LANGUAGE) as String, -250);
				Session.game.message(Translations.TIP_SPACE_BAR.getItemAt(Session.LANGUAGE) as String, 10);
			}
			
			if(tutorialStep == 5){
				Session.play.tutorialContinueLabel.visible = true;
				Session.play.tutorialMiddleLabel.visible = true;
			}

			if(tutorialStep == 6){
				Session.play.tutorialContinueLabel.visible = false;
				Session.play.tutorialMiddleLabel.visible = false;
				
				placeSquare(1,3,2);
				placeSquare(1,4,2);
				placeSquare(1,5,2);

				placeSquare(5,2,2);
				placeSquare(5,3,2);
				placeSquare(5,4,2);
				placeSquare(5,5,2);
				
				placeSquare(2,5,2);
				placeSquare(3,5,2);
				placeSquare(4,5,2);

				placeSquare(2,3,2);

				placeSquare(2,4,1);
				placeSquare(4,4,1);
			}
			
			if(tutorialStep == 12){
				Session.play.tutorialContinueLabel.visible = true;
				Session.play.tutorialFinalLabel.visible = true;
			}
			
			if(tutorialStep > 12){
				Session.play.leaveTutorial();
			}
		}

		private function getXOffset():int {
			switch(arrows[tutorialStep]){
				case ImageContainer.TUTO_ARROW_UP : 
					return 160;
				case ImageContainer.TUTO_ARROW_LEFT : 
					return 205;
				case ImageContainer.TUTO_ARROW_DOWN : 
					return 155;
				case ImageContainer.TUTO_ARROW_RIGHT : 
					return 100;
			}
			return 0;
		}
		
		private function getYOffset():int {
			switch(arrows[tutorialStep]){
				case ImageContainer.TUTO_ARROW_UP : 
					return 15;
				case ImageContainer.TUTO_ARROW_LEFT : 
					return -42;
				case ImageContainer.TUTO_ARROW_DOWN : 
					return -100;
				case ImageContainer.TUTO_ARROW_RIGHT : 
					return -42;
			}
			return 0;
		}
		
		private function placeSquare(_x:int, _y:int, color:int):void {
			var square:Image = new Image();
			square.x = Numbers.X.getItemAt(_x) as int;
			square.y = Numbers.Y.getItemAt(_y) as int;
			square.source = ImageContainer.getSquare(color);
			
			square.data = new Square(color, Numbers.CONSTRUCTOR);
			
			Session.play.squareContainer.addElement(square);
			Session.cases[_x][_y].fill(square);
			SquareExploder.getInstance().register(Session.cases[_x][_y]);
		}
		
}
		

}