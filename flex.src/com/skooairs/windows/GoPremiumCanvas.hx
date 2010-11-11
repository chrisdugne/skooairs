
import com.skooairs.constants.Session;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Names;
import com.skooairs.constants.Translations;

import com.skooairs.core.MusicPlayer;

	/*
        go premium - 1.99 button="6J5VDASS5TRJN"
        go premium SANDBOX - 1.99 button="VQC33N3ATP4HG"
	*/
	public function buy():void{
		buyButton.visible=false;
		loadingProgressBar.start();
		
		var dateMillis:Number = new Date().getTime();
		playerWrapper.setTransactionMillis(Session.player.playerUID, dateMillis);
		
		var url:String = "https://www.paypal.com/cgi-bin/webscr";
		var request:URLRequest = new URLRequest(url);
		var variables:URLVariables = new URLVariables();
		variables.cmd = "_s-xclick";
		variables.hosted_button_id = "6J5VDASS5TRJN";
		variables.custom = Session.player.playerUID + "___" + dateMillis;
		
		request.data = variables;
		request.method = URLRequestMethod.POST;
		navigateToURL(request,"_parent");
	}
	
	