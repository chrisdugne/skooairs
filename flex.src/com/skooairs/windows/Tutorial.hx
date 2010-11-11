
import com.skooairs.constants.Translations;
import com.skooairs.constants.Session;
import com.skooairs.constants.Numbers;

import mx.collections.ArrayCollection;

import com.skooairs.core.MusicPlayer;

	//-----------------------------------------------------------------------------------//

	[Bindable] private var step:int = 1;
	
	//-----------------------------------------------------------------------------------//
	
	private function changeStep():void{
		fadeEffect.play();
	}
	
	private function continueTuto():void{
		if(step < 3)
			changeStep();
		else{
			step = 0;
			fadeEffect.play();
			Session.game.hideTuto();			
		}
	}

	private function skip():void{
		step = 0;
		fadeEffect.play();
		Session.game.hideTuto();
	}