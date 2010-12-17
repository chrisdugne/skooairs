package com.skooairs.managers {
	
	import com.facebook.graph.Facebook;
	import com.skooairs.constants.Names;
	import com.skooairs.constants.Session;
	import com.skooairs.constants.Translations;
	import com.skooairs.core.MusicPlayer;
	import com.skooairs.entities.Player;
	import com.skooairs.entities.UralysProfile;
	import com.skooairs.utils.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.utils.ObjectUtil;
	
	[Bindable]
	public class AccountManager{

		//============================================================================================//

		private static var instance:AccountManager = new AccountManager();
		public static function getInstance():AccountManager{
			return instance;
		}

		//============================================================================================//
		
		private var accountWrapper:RemoteObject;
		private var playerWrapper:RemoteObject;
		
		// -  ================================================================================
		
		public function AccountManager(){
			accountWrapper = new RemoteObject();
			accountWrapper.destination = "UralysAccountWrapper";
			accountWrapper.endpoint = Session.isLocal ? Names.LOCAL_LOGGER_SERVER_AMF_ENDPOINT 
													  : Names.URALYS_LOGGER_SERVER_AMF_ENDPOINT;

			playerWrapper = new RemoteObject();
			playerWrapper.destination = "PlayerWrapper";
			playerWrapper.endpoint = Names.SERVER_AMF_ENDPOINT;
			
			if(Session.isLocal){
				var friends:Array = [];
				friends[0] = new Object();
				friends[0].id = '333';
				
				
				getFriendsHandler(friends, null);
				accountWrapper.loginFromFacebook.addEventListener("result", resultLoginFromFacebook);
				accountWrapper.loginFromFacebook('testus');
			}
		}

		
		//============================================================================================//
		
		public function createDummyProfile():void {
			Session.uralysProfile = new UralysProfile();
			Session.uralysProfile.uralysUID = "NOT_CONNECTED";
			
			Session.player = new Player();
			Session.player.musicOn = !Session.isLocal;
			Session.player.facebookUID = null;
		}		
		
		//============================================================================================//
		// DATA MANAGEMENT
		//============================================================================================//
		//  ASKING SERVER
		
		private var email:String;
		private var password:String;
		public function register(email:String, password:String):void{
			this.email = email; // bckup pour etre parametre dans registered, et pour login automatique
			this.password = password; // bckup pour login automatique

			accountWrapper.createUralysAccount.addEventListener("result", registered);
			accountWrapper.createUralysAccount(email, password);
		}

		public function login(email:String, password:String):void{
			this.email = email; // bckup pour login automatique si on doit creer le profil automatiquement
			this.password = password; // bckup pour login automatique si on doit creer le profil automatiquement
			
			accountWrapper.login.addEventListener("result", resultLogin);
			accountWrapper.login(email, password);
		}
		
		//--------------------------------------------------------------------------------------------//
		
		public function changeLanguage(uralysUID:String, language:int):void{
			accountWrapper.changeLanguage(uralysUID, language);
		}

		public function changeMusicOn(uralysUID:String, musicOn:Boolean):void{
			playerWrapper.changeMusicOn(uralysUID, musicOn);
		}
		

		//============================================================================================//
		//  RESULTS FROM SERVER	
		
		//-------------------------------------------------------------------------//
		// UralysLogger
		
		private function registered(event:ResultEvent):void{
			
			Session.uralysProfile = event.result as UralysProfile;
			trace("registered");
			trace(ObjectUtil.toString(Session.uralysProfile));
			
			if(Session.uralysProfile.uralysUID == "EMAIL_EXISTS"){
				Session.game.message("This email is registered yet", 3);
				Session.WAIT_FOR_SERVER = false;
			}
			else{
				playerWrapper.createPlayer.addEventListener("result", playerCreated);
				playerWrapper.createPlayer(Session.uralysProfile.uralysUID);
			}
		}
		
		
		private function resultLogin(event:ResultEvent):void{
			
			Session.uralysProfile = event.result as UralysProfile;
			trace("resultLogin");
			trace(ObjectUtil.toString(Session.uralysProfile));
			Session.LANGUAGE = Session.uralysProfile.language;
			
			if(Session.uralysProfile.uralysUID == "WRONG_PWD"){
				Session.game.message("Authentication Failed", 3);
				Session.WAIT_FOR_SERVER = false;
			}
			else{
				playerWrapper.getPlayer.addEventListener("result", receivedPlayer);
				playerWrapper.getPlayer(Session.uralysProfile.uralysUID);
			}
		}

		private function resultLoginFromFacebook(event:ResultEvent):void{
			trace("resultLoginFromFacebook");
			trace(ObjectUtil.toString(event.result));
			
			
			var profileReceived:UralysProfile = event.result as UralysProfile;
			if(profileReceived.lastLog == 1)
				registered(event);
			else
				resultLogin(event); 
		}
		
		//==================================================================================================//
		// SkooairsServer

		private function playerCreated(event:ResultEvent):void{
			
			Session.player = event.result as Player;
			trace("playerCreated");
			trace(ObjectUtil.toString(Session.player));
			
			if(!playerCreatedAutomatically)
				Session.game.message("Profil Uralys cree. Bienvenue !", 6);
			
			finalizeLogin();
		}
		
		private var playerCreatedAutomatically:Boolean = false;
		private function receivedPlayer(event:ResultEvent):void{
			
			var player:Player = event.result as Player;
			trace("receivedPlayer");
			trace(ObjectUtil.toString(player));
			
			if(player == null){
				playerCreatedAutomatically = true;
				playerWrapper.createPlayer.addEventListener("result", playerCreated);
				playerWrapper.createPlayer(Session.uralysProfile.uralysUID);
			}
			else{
				Session.player = player;
				finalizeLogin();
			}
		}
		
		private function finalizeLogin():void{
			
			Session.WAIT_FOR_SERVER = false;
			Session.LOGGED_IN = true;
			Session.game.hideLogin.play();
			
			MusicPlayer.getInstance().initMusic();
			
		}
		
		//==================================================================================================//
		// facebook

		private var facebookOperation:int = 0;
		private var NEW_LINK:int = 1;
		private var CONNECT_TO_EXISTING_LINK:int = 2;
		private var LOGIN:int = 3;
		
		public function autoLoginFacebook():void{
			trace("try autoLoginFacebook");
			Session.CONNECTED_TO_FACEBOOK = true;
			facebookOperation = LOGIN;
			Facebook.init("121585177900212", autoLoginFacebookHandler);
		}
		
		public function loginFacebook():void{
			if(Session.isLocal)
				return;
				
			// logged in the uralys account yet
			if(Session.LOGGED_IN){

				// try to link a facebook account with this uralys account.
				if(Session.uralysProfile.facebookUID == null){
					facebookOperation = NEW_LINK;
				}
				// try to connect the facebook account of this uralys account.
				else{
					facebookOperation = CONNECT_TO_EXISTING_LINK;
				}
			}
			// try to log in from the facebook account only.
			else{
				facebookOperation = LOGIN;
			}	
				
			trace("facebookOperation : " + facebookOperation);
			Session.CONNECTED_TO_FACEBOOK = true;
			Facebook.login(loginFacebookHandler,{perms:"user_birthday,read_stream,publish_stream"});
			
		}
		
		protected function autoLoginFacebookHandler(success:Object,fail:Object):void{
			trace("autoLoginFacebookHandler");
			if(success)
				loginFacebookHandler(success, fail);
			else{
				trace("no success");
				Session.CONNECTED_TO_FACEBOOK = false;
				MusicPlayer.getInstance().initMusic();
			}
		}
		
		protected function loginFacebookHandler(success:Object,fail:Object):void{
			Session.CONNECTED_TO_FACEBOOK = false;
			
			if(success){
				trace("loginFacebookHandler success");
				trace(ObjectUtil.toString(success));
				
				switch(facebookOperation){
					case NEW_LINK : 
						accountWrapper.existFacebookPlayer.addEventListener("result", resultExistFBTest);
						accountWrapper.existFacebookPlayer(success.uid);
						break;
					case CONNECT_TO_EXISTING_LINK : 
						if(Session.uralysProfile.facebookUID == success.uid)
							Facebook.api("/"+Session.uralysProfile.facebookUID, badLink);
						else
							Session.game.message(Translations.CONNECTION_OK.getItemAt(Session.LANGUAGE) as String, 4);

						break;
					case LOGIN : 
						trace("Go on login to Uralys-Skooairs");
						Session.CONNECTED_TO_FACEBOOK = true;

						trace("call FB friends");
						Facebook.api("/me/friends", getFriendsHandler);
						
						trace("call accountWrapper.loginFromFacebook");
						accountWrapper.loginFromFacebook.addEventListener("result", resultLoginFromFacebook);
						accountWrapper.loginFromFacebook(success.uid);
						break;
				}
				
			}
		}
		
		protected function badLink(account:Object,fail:Object):void{
			Session.game.message((Translations.URALYS_ACCOUNT_ALREADY_LINKED.getItemAt(Session.LANGUAGE) as String) + account.name, 4);
		}
		
		protected function getFriendsHandler(friends:Object,fail:Object):void{
			Session.friendUIDs = [];
			
			for each(var friend:Object in friends){
				Session.friendUIDs.push(friend.id);	
			}
			
			if(Session.friendUIDs.length > 0){
				playerWrapper.getFriendPlayerUIDs.addEventListener("result", onGetFriendPlayerUIDs);
				playerWrapper.getFriendPlayerUIDs(Session.friendUIDs);
			}
				
		}

		protected function onGetFriendPlayerUIDs(event:ResultEvent):void{
			Session.friendPlayerUIDs = event.result as ArrayCollection;
		}


		// receive result about the NEW_LINK availability for the facebookUID connected
		protected function resultExistFBTest(event:ResultEvent):void{
			var facebookUIDExistsYet:Boolean = event.result as Boolean;
			
			if(facebookUIDExistsYet)
				Session.game.message(Translations.FACEBOOK_ACCOUNT_ALREADY_LINKED.getItemAt(Session.LANGUAGE) as String, 6);
			else{
				Session.CONNECTED_TO_FACEBOOK = true;
				Facebook.api("/me/friends", getFriendsHandler);
				accountWrapper.linkFacebookUID(Session.uralysProfile.uralysUID, Session.uralysProfile.facebookUID);
				playerWrapper.linkFacebookUID(Session.uralysProfile.uralysUID, Session.uralysProfile.facebookUID);
			}
		}

		//==================================================================================================//

		public function logoutFacebook():void{
			
			Facebook.logout(logoutHandler);
			Session.CONNECTED_TO_FACEBOOK = false;
			
			// if the email is not valid, this is a facebookUID : logout the linked uralys account as well
			if(!Utils.isValidEmail(Session.uralysProfile.email)){
				var oldSoundChoice:Boolean = Session.player.musicOn;
				createDummyProfile();
				Session.player.musicOn = oldSoundChoice;
				
				Session.LOGGED_IN = false;
			}
		}
		
		protected function logoutHandler(response:Object):void{
			Session.game.message(Translations.LOGGED_OUT_FACEBOOK.getItemAt(Session.LANGUAGE) as String, 6);
		}
		
	}
}