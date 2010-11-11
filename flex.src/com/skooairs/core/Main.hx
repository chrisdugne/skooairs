
import mx.collections.ArrayCollection;

import flash.events.MouseEvent;
import mx.events.FlexEvent;

import mx.managers.CursorManager;
import mx.effects.easing.Elastic;
import mx.controls.Alert;

import com.skooairs.core.MusicPlayer;
import com.skooairs.core.Pager;
import com.skooairs.utils.Utils;

import com.skooairs.constants.Session;
import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Translations;

import pages.Game;

	//-----------------------------------------------------------------------------------//
	    
    [Embed(source="embed/images/cursor.gif")]
    [Bindable]
	public var MainCursor:Class;
	
	private function applicationCompleteHandler(event:FlexEvent):void {
		trace("Welcome to SkooAirs !");
		CursorManager.setCursor(MainCursor);
		
		Pager.getInstance().window = window;
		Pager.getInstance().tutorial = tuto;
		
		Session.FIRST_VIEW = Numbers.VIEW_HOME;
		
        Pager.getInstance().setBackground("resources/images/background.jpg");
		Pager.getInstance().goToPage(Game);
	}

	//-----------------------------------------------------------------------------------//
	
/*
	private function onConnect(event:FacebookEvent):void { 
	    if(event.success){

	        loadingLabel.text = "Loading 40%";
	        		
			var call:FacebookCall = fbook.post(new GetInfo([fbook.uid],[GetInfoFieldValues.ALL_VALUES]));            
			call.addEventListener(FacebookEvent.COMPLETE, onGetInfo);	
	    
	    }
	    else{
		    Alert.show("Error connecting to Facebook","Error");
		}
	}
*/
	
	//-----------------------------------------------------------------------------------//

/*
	private function onGetInfo(event:FacebookEvent):void {
		if(event.success){
			
			loadingLabel.text = "Loading 55%";
			
			Session.user = (event.data as GetInfoData).userCollection.getItemAt(0) as FacebookUser;
		    playerWrapper.existPlayer(fbook.uid);
		}
		else{
			Alert.show("Error getting Facebook user data","Error");
		}
	}
*/
	
	
	//-----------------------------------------------------------------------------------//
	
	/*
		users.getInfo&fields = about_me,
							   activities,
							   affiliations,
							   birthday,
							   books,
							   current_location,
							   education_history,
							   email_hashes,
							   first_name,
							   has_added_app,
							   hometown_location,
							   hs_info,
							   interests,
							   is_app_user,
							   last_name,
							   locale,
							   meeting_for,
							   meeting_sex,
							   movies,
							   music,
							   name,
							   notes_count,
							   pic,
							   pic_with_logo,
							   pic_big,
							   pic_big_with_logo,
							   pic_small,
							   pic_small_with_logo,
							   pic_square,
							   pic_square_with_logo,
							   political,
							   profile_update_time,
							   profile_url,
							   proxied_email,
							   quotes,
							   relationship_status,
							   religion,
							   sex,
							   significant_other_id,
							   status,
							   timezone,
							   tv,
							   wall_count,
							   work_history
	*/

	