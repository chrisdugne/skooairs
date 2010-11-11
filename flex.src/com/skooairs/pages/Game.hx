
import com.skooairs.core.Pager;
import com.skooairs.core.MusicPlayer;

import com.skooairs.constants.Translations;
import com.skooairs.constants.Session;
import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;

import com.skooairs.entities.Player;

import mx.events.FlexEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.events.FaultEvent;

import mx.collections.ArrayCollection;

import flash.external.ExternalInterface;

import com.facebook.graph.Facebook;

	//==================================================================================================//

	private var isLocal:Boolean = false;
	private var initProcess:Boolean = true;
	[Bindable] private var initDone:Boolean = false;
	
	//==================================================================================================//    
	private function init(event:FlexEvent):void {
			 
		Facebook.init("121585177900212", loginHandler);
		loadingProgressBar.start();

		ExternalInterface.addCallback("responseIsLocal", responseIsLocal);
		ExternalInterface.call("isLocal");
				Pager.getInstance().viewstack = viewstack;
		Pager.getInstance().goToView(0);
		
		Session.game = this;
		Session.play = play;
		
		if(Session.newPlayer)
			showTuto(0);
		
	}
	
    private function responseIsLocal(isLocal:Boolean):void {
        this.isLocal = isLocal; 
    	trace("isLocal : " + isLocal);
    	
    	if(isLocal){
    		
			loadingProgressBar.stop();
			initDone = true;
		
    		// simulate the loginHandler with success == false for Facebook.init
			Session.player = new Player();
			Session.player.playerUID = "NOT_CONNECTED";
			Session.player.facebookUID = "NO";
			Session.player.musicOn = false;

			MusicPlayer.getInstance().initMusic();
			
			Session.FACEBOOK_UID = "debugPlayer1";
    	}
    }
    
	
	//-----------------------------------------------------------------------------------//	// facebook

	public function login():void{

		loadingProgressBar.start();
		initDone = false;
		
		if(isLocal){
			playerWrapper.existFacebookPlayer(Session.FACEBOOK_UID); // "debugPlayer1"
			currentState="loggedin";
		}
		else		
			Facebook.login(loginHandler,{perms:"user_birthday,read_stream,publish_stream"});
	}

	protected function loginHandler(success:Object,fail:Object):void{
		Session.player = new Player();
		Session.player.playerUID = "NOT_CONNECTED";
		Session.player.facebookUID = "NO";
		Session.player.musicOn = true;
		
		if(success){
			Session.FACEBOOK_UID = success.uid;
			currentState="loggedin"; 
			//userImg.source = Facebook.getImageUrl(Session.FACEBOOK_UID, "small");
			
			playerWrapper.existFacebookPlayer(Session.FACEBOOK_UID);
			
			Facebook.api("/me/friends", getFriendsHandler); 
		}
		else if(initProcess){
			// first arrival on the page and not logged in Facebook
			// music on !
			
			initProcess = false;
			MusicPlayer.getInstance().initMusic();
			
			// Session.player is ready to play
			initDone = true;
			loadingProgressBar.stop();
		}
	}
	

	protected function getFriendsHandler(friends:Object,fail:Object):void{
		Session.friendUIDs = [];
		
		for each(var friend:Object in friends){
			Session.friendUIDs.push(friend.id);	
		}
		
		initProcess = false;
	}
	
	
	protected function logout():void{
		Facebook.logout(logoutHandler);
		currentState="loggedout";
		
		var oldSoundChoice:Boolean = Session.player.musicOn;
		Session.player = new Player();
		Session.player.musicOn = oldSoundChoice;
		Session.player.playerUID = "NOT_CONNECTED";
		Session.player.facebookUID = "NO";
		
	}
	
	protected function logoutHandler(response:Object):void{
	}
		
	//-----------------------------------------------------------------------------------//
	
	public function message(message:String, time:int):void {
		displayMessage.message = message;
		displayMessage.time = time;
		displayMessage.showMessage();
    }
		
	public function invite():void {
		ExternalInterface.call("showInvite()");
	}

	//==================================================================================================//
	// existFacebookPlayer : true (and false for Skooairs see the explanations under)
		

	private function yes(event:ResultEvent):void{
		// the getFacebookPlayer for Skooairs does not act like the getUser for Fools
		// here, it returns 'null' when in Fools it throws an exception
		// (it is due a priori to the 'setUnique(true) or the use of gql..')
		// therefore, for Skooairs, the function no(event:FaultEvent) is never called(no Exception raised by datanucleus), 
		// and the false is to be caught here
		if(event.result){
			playerWrapper.getFacebookPlayer(Session.FACEBOOK_UID);
			Session.FIRST_VIEW = Numbers.VIEW_HOME;
		}
		else{
			MusicPlayer.getInstance().initMusic();	
			playerWrapper.createPlayer(Numbers.FACEBOOK_USER, Session.FACEBOOK_UID);
		}
	}
		
	//-----------------------------------------------------------------------------------//
	// existFacebookPlayer : false (never for Skooairs, see the explanation above)
	
	private function no(event:FaultEvent):void{
		playerWrapper.createPlayer(Numbers.FACEBOOK_USER, Session.FACEBOOK_UID);
	}

	private function onPlayerCreationComplete(event:ResultEvent):void{
		Session.newPlayer = true;
					
		playerWrapper.getFacebookPlayer(Session.FACEBOOK_UID);
		Session.FIRST_VIEW = Numbers.VIEW_HOME;
	}		

	//-----------------------------------------------------------------------------------//
	
	private function onFacebookPlayerReady(event:ResultEvent):void{
		Session.player = event.result as Player;
		Session.LANGUAGE = Session.player.language;
		
		// Session.player is ready to play
		initDone = true;
		loadingProgressBar.stop();
		
		// in case of goPremieum window opened
		if(Session.player.premium)
			hidebuycredits.play();
			
		if(Session.friendUIDs.length > 0){
			playerWrapper.getFriendPlayerUIDs(Session.friendUIDs);
		}
		else{
			if(!MusicPlayer.getInstance().testMusic())
				playerWrapper.changeMusicOn(Session.player.playerUID, false);
		}
	}
	
	
	protected function onGetFriendPlayerUIDs(event:ResultEvent):void{
		Session.friendPlayerUIDs = event.result as ArrayCollection;
		
		if(!MusicPlayer.getInstance().testMusic())
			playerWrapper.changeMusicOn(Session.player.playerUID, false);
		
	}
	
	protected function faultGetFriendPlayerUIDs(event:FaultEvent):void{
		trace("faultGetFriendPlayerUIDs");
	}

	//==================================================================================================//

	private function french():void {
		
		if(Session.player.playerUID != "NOT_CONNECTED")
			playerWrapper.changeLanguage(Session.player.playerUID, 0);
		
		Session.LANGUAGE = 0;
	}

	private function english():void {
		
		if(Session.player.playerUID != "NOT_CONNECTED")
			playerWrapper.changeLanguage(Session.player.playerUID, 1);
		
		Session.LANGUAGE = 1;
	}

	private function us():void {
		
		if(Session.player.playerUID != "NOT_CONNECTED")
			playerWrapper.changeLanguage(Session.player.playerUID, 2);
		
		Session.LANGUAGE = 2;
	}

	private function music():void {
		MusicPlayer.getInstance().switchState();
		
		if(Session.player.playerUID != "NOT_CONNECTED")
			playerWrapper.changeMusicOn(Session.player.playerUID, Session.player.musicOn);
	}
		
	//==================================================================================================//
		
	public function showTuto(step:int):void {
		showtuto.play();
	}
	
	public function hideTuto():void {
		hidetuto.play();
	}


	