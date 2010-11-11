

import com.skooairs.core.Pager;
import com.skooairs.core.MusicPlayer;
import com.skooairs.utils.Utils;

import com.skooairs.constants.Session;
import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Translations;



	[Bindable]
	public var initDone:Boolean = false;

	//-----------------------------------------------------------------------------------//

	private function newGame():void {
		Pager.getInstance().goToView(Numbers.VIEW_SELECTIONS);
	}
			    
	private function scores():void {
		Pager.getInstance().goToView(Numbers.VIEW_BOARDS);
	}
			    
	//-----------------------------------------------------------------------------------//





