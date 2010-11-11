

import com.skooairs.core.Pager;
import com.skooairs.core.MusicPlayer;

import com.skooairs.constants.Session;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Translations;

	//-----------------------------------------------------------------------------------//

	[Bindable] private var initDone:Boolean = false;

	[Bindable] private var selectedTime:String = "2 min";
	[Bindable] private var selectedColors:String = "3";
	[Bindable] private var selectedSpeed:String = "1";
	
	//-----------------------------------------------------------------------------------//

	private function init():void {
		initDone = true;
	}

	private function go():void {
		Session.SPEED = parseInt(selectedSpeed);
		Session.COLORS = parseInt(selectedColors);

		switch(selectedTime){
			case "2 min":
				Session.TIME = Numbers.TIME_2_MIN;
				break;
			case "3 min":
				Session.TIME = Numbers.TIME_3_MIN;
				break;
			case "5 min":
				Session.TIME = Numbers.TIME_5_MIN;
				break;
			case "7 min":
				Session.TIME = Numbers.TIME_7_MIN;
				break;
			case "10 min":
				Session.TIME = Numbers.TIME_10_MIN;
				break;
			default:
				//no limit
				Session.TIME = Numbers.TIME_NO_LIMIT;
		}

		if(!Session.player.premium 
		&& (Session.TIME != Numbers.TIME_2_MIN
			|| Session.COLORS != 3	
			|| Session.SPEED != 1)){
				
				timeBorderMover.xTo=92;
				timeBorderResizer.widthTo=75;
				timeParallel.play();
				selectedTime='2 min';
				
				colorsMover.xTo=167;
				colorsMover.play();
				selectedColors='3';
				
				//speedBorderMover.xTo=48;
				//speedBorderMover.yTo=374;
				//speedParallel.play();
				//selectedSpeed='1';
				
				Session.game.showbuycredits.play();
				
				return;
		}
		else
			newGame();
			
	}

	private function newGame():void {
		Pager.getInstance().goToView(Numbers.VIEW_PLAY);
	}

			




