

import com.skooairs.utils.Utils;

import com.skooairs.constants.Session;
import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Translations;

import com.skooairs.core.Pager;
import com.skooairs.core.SquareMover;
import com.skooairs.core.SquareExploder;
import com.skooairs.core.PointsCounter;
import com.skooairs.core.MusicPlayer;

import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;        
import spark.effects.animation.Keyframe;

import mx.rpc.events.ResultEvent;
import mx.controls.Label;

	//-----------------------------------------------------------------------------------//

	public function reset():void {
		Session.GAME_OVER = false;
		Session.NB_BOOMS = 3;
    	
		SquareExploder.getInstance().reset();
		PointsCounter.getInstance().reset();
    	SquareMover.getInstance().reset();
		
		playGameTimer();
		
		if(Session.player.playerUID == "NOT_CONNECTED")
			Session.game.message(Translations.LOG_IN_TO_SEE_RECORDS.getItemAt(Session.LANGUAGE) as String, 4);
		else
			playerWrapper.getRecord(Session.player.playerUID, Session.TIME, Session.COLORS);
    }
    
    private function onGetRecord(event:ResultEvent):void{
    	Session.CURRENT_RECORD = event.result as int;
    }

    public function moveHandler(e:MouseEvent):void{
    	if(!Session.GAME_OVER)
	    	SquareMover.getInstance().moveHandler(e, true);
    } 

    public function clickHandler(e:MouseEvent):void{
    	if(!Session.GAME_OVER)
	    	SquareMover.getInstance().clickHandler(e);
    } 

	public function explodeSquare(image:Image):void{
		
		var x_effect:SimpleMotionPath = new SimpleMotionPath();
		x_effect.valueTo = image.x + 150 - Utils.random(300);
		x_effect.property = "x";
		

		var y_effect:SimpleMotionPath = new SimpleMotionPath();		
		y_effect.keyframes = new Vector.<Keyframe>();
        y_effect.keyframes.push( new Keyframe( 0, image.y) );
        y_effect.keyframes.push( new Keyframe( 40, image.y - 12) );
        y_effect.keyframes.push( new Keyframe( 80, image.y) );
        y_effect.keyframes.push( new Keyframe( 1200, image.y + 350) );
		y_effect.property = "y";

		var alpha_effect:SimpleMotionPath = new SimpleMotionPath();		
		alpha_effect.valueTo = 0;
		alpha_effect.property = "alpha";
 				
 				
		var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
		vector.push( x_effect );
		vector.push( y_effect );
		vector.push( alpha_effect );
 				
		var explosionAnimator:Animate = new Animate();
		explosionAnimator.motionPaths = vector;
		explosionAnimator.duration = 1200;
		explosionAnimator.targets.push(image);
		explosionAnimator.play();
	}
	
	//-----------------------------------------------------------------------------------//
	// Game Timer
	
    private var gameTimer:Timer;
    private var gameTimerDone:Boolean = false;
    public var secondsSpent:int = 0;
    public var seconds:int;

    private function playGameTimer():void {
    	resetGameTimer();
    	// 1000 ms - 15ms for the operations
        gameTimer = new Timer(985, seconds);
 	    gameTimer.addEventListener(TimerEvent.TIMER, onTickGame);
 	    gameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteGame);
 	    gameTimer.start();
    }

    private function onTickGame(evt:TimerEvent):void {
    	var totalSecondsRemaining:int = seconds - ++secondsSpent;
    	var nbMinutesRemaining:int = totalSecondsRemaining/60;
    	var nbSecsRemaining:int = totalSecondsRemaining - nbMinutesRemaining*60;
    	
        gameTimerLabel.text = nbMinutesRemaining + "'" + (nbSecsRemaining < 10 ? "0" : "") + nbSecsRemaining;
    }
    
    private function onCompleteGame(evt:Event):void {
        stopGameTimer();
    }
	
    private function stopGameTimer():void {
        gameTimer.stop();
        gameTimerDone = true;
        gameOver();
    }

    private function resetGameTimer():void {
    	secondsSpent = 0;
    	
    	switch(Session.TIME){
    		case Numbers.TIME_2_MIN:
    			seconds = 120;
    			break;
    		case Numbers.TIME_3_MIN:
    			seconds = 180;
    			break;
    		case Numbers.TIME_5_MIN:
    			seconds = 300;
    			break;
    		case Numbers.TIME_7_MIN:
    			seconds = 420;
    			break;
    		case Numbers.TIME_10_MIN:
    			seconds = 600;
    			break;
    		default :
    			seconds = -1;
    	}
    	
    	gameTimerLabel.text = seconds/60 + ":00";
    }

	
	//-----------------------------------------------------------------------------------//

	private function endGame():void{
		
		if(Session.player.playerUID != "NOT_CONNECTED"
		&& Session.CURRENT_RECORD < Session.POINTS){
			playerWrapper.storeRecord(Session.player.playerUID, surnameInput.text, Session.TIME, Session.COLORS, Session.POINTS);
		}
		
		Pager.getInstance().goToView(Numbers.VIEW_HOME);
	}

    public function boomButtonPushed():void {
    	if(SquareMover.getInstance().boomButtonPushed()){
			Session.NB_BOOMS--;
    	}
    }

    public function addBoomer():void {
    	Session.NB_BOOMS++;
    }

	
	private var labels:Array = [];
	
    public function pointsMessage(base:int, bonus:int):void {
		var baseLabel:Label = new Label();
		baseLabel.text = "+" + base;
		baseLabel.styleName = "normalWhiteStyle";
		baseLabel.x = 200;
		board.addElement(baseLabel);
		appearBaseLabelEffect.target = baseLabel;
		appearBaseLabelEffect.play();
		labels.push(baseLabel);
		
		if(bonus > 1){
			
			var bonusLabel:Label = new Label();
			bonusLabel.styleName = "bigRedStyle";
			bonusLabel.text = "X" + bonus;
			bonusLabel.x = 250;
			labels.push(bonusLabel);
			board.addElement(bonusLabel);
			appearBonusLabelEffect.target = bonusLabel;
			appearBonusLabelEffect.play();
		}
    }

	private function removeLabel():void{
		board.removeElement(labels.shift());	
	}

	public function gameOver():void{
		Session.GAME_OVER = true;
		gameTimer.stop();
		MusicPlayer.getInstance().playYeahSound();
	}































