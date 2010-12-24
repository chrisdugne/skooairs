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
				Session.WAIT_FOR_CONNECTION = false;
			}
			else{
				playerWrapper.createPlayer.addEventListener("result", playerCreated);
				playerWrapper.createPlayer(Session.uralysProfile.uralysUID, Session.uralysProfile.facebookUID);
			}
		}
		
		
		private function resultLogin(event:ResultEvent):void{
			
			Session.uralysProfile = event.result as UralysProfile;
			trace("resultLogin");
			trace(ObjectUtil.toString(Session.uralysProfile));
			Session.LANGUAGE = Session.uralysProfile.language;
			
			if(Session.uralysProfile.uralysUID == "WRONG_PWD"){
				Session.game.message("Authentication Failed", 3);
				Session.WAIT_FOR_CONNECTION = false;
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
			
			// on aura la requete facebook pour les friends en meme temps que le call AMF get/create Player
			// et ensuite le call AMF getFriendsUIDs se fera bien tout seul, et non en meme temps (ce qui casse l'appel AMF)
			getFriends();
		}
		
		//==================================================================================================//
		// SkooairsServer

		private function playerCreated(event:ResultEvent):void{
			
			playerWrapper.createPlayer.removeEventListener("result", playerCreated);
			Session.player = event.result as Player;
			trace("playerCreated");
			trace(ObjectUtil.toString(Session.player));
			
			if(!playerCreatedAutomatically)
				Session.game.message("Profil Uralys cree. Bienvenue !", 6);
			
			finalizeLogin();
		}
		
		private var playerCreatedAutomatically:Boolean = false;
		private function receivedPlayer(event:ResultEvent):void{
			
			playerWrapper.getPlayer.removeEventListener("result", receivedPlayer);
			var player:Player = event.result as Player;
			trace("receivedPlayer");
			trace(ObjectUtil.toString(player));
			
			if(player == null){
				playerCreatedAutomatically = true;
				playerWrapper.createPlayer.addEventListener("result", playerCreated);
				playerWrapper.createPlayer(Session.uralysProfile.uralysUID, Session.uralysProfile.facebookUID);
			}
			else{
				Session.player = player;
				finalizeLogin();
			}
		}
		
		private function finalizeLogin():void{
			
			Session.WAIT_FOR_CONNECTION = false;
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
			Session.WAIT_FOR_CONNECTION = true;
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
			Facebook.login(loginFacebookHandler,{perms:"user_birthday,read_stream,publish_stream"});
			
		}
		
		protected function autoLoginFacebookHandler(success:Object,fail:Object):void{
			trace("autoLoginFacebookHandler");
			if(success)
				loginFacebookHandler(success, fail);
			else{
				trace("no success");
				Session.WAIT_FOR_CONNECTION = false;
				Session.CONNECTED_TO_FACEBOOK = false;
				MusicPlayer.getInstance().initMusic();
			}
		}
		
		private var lastFacebookAccountLoggedIn:String;
		protected function loginFacebookHandler(success:Object,fail:Object):void{
			
			if(success){
				trace("loginFacebookHandler success");
				trace(ObjectUtil.toString(success));
				lastFacebookAccountLoggedIn = success.uid;
				
				switch(facebookOperation){
					case NEW_LINK : 
						accountWrapper.existFacebookPlayer.addEventListener("result", resultExistFBTest);
						accountWrapper.existFacebookPlayer(lastFacebookAccountLoggedIn);
						break;
					case CONNECT_TO_EXISTING_LINK : 
						if(Session.uralysProfile.facebookUID != lastFacebookAccountLoggedIn)
							Facebook.api("/"+Session.uralysProfile.facebookUID, badLink);
						else{
							Session.game.message(Translations.CONNECTION_OK.getItemAt(Session.LANGUAGE) as String, 4);
							Session.CONNECTED_TO_FACEBOOK = true;
							getFriends();
						}

						break;
					case LOGIN : 
						trace("Go on login to Uralys-Skooairs");
						Session.CONNECTED_TO_FACEBOOK = true;
						
						trace("call accountWrapper.loginFromFacebook");
						accountWrapper.loginFromFacebook.addEventListener("result", resultLoginFromFacebook);
						accountWrapper.loginFromFacebook(lastFacebookAccountLoggedIn);
						break;
				}
				
			}
			else{
				Session.WAIT_FOR_CONNECTION = false;
			}
		}
		
		protected function badLink(account:Object,fail:Object):void{
			Session.game.message((Translations.URALYS_ACCOUNT_ALREADY_LINKED.getItemAt(Session.LANGUAGE) as String) + account.name, 4);
			
			Session.CONNECTED_TO_FACEBOOK = true;
			trace("bad link : relog using accountWrapper.loginFromFacebook");
			accountWrapper.loginFromFacebook.addEventListener("result", resultLoginFromFacebook);
			accountWrapper.loginFromFacebook(lastFacebookAccountLoggedIn);
		}
		
		//------------------------------------------------------------------------------------//
		
		protected function getFriends():void{
			trace("call FB friends");
			Facebook.api("/me/friends", getFriendsHandler);
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
			Session.CONNECTED_TO_FACEBOOK = true;
			
			// force logout and 'loginfromfacebook' with the new FB user
			if(facebookUIDExistsYet){
				Session.game.message(Translations.FACEBOOK_ACCOUNT_ALREADY_LINKED.getItemAt(Session.LANGUAGE) as String, 6);
				trace("call accountWrapper.loginFromFacebook");
				accountWrapper.loginFromFacebook.addEventListener("result", resultLoginFromFacebook);
				accountWrapper.loginFromFacebook(lastFacebookAccountLoggedIn);
			}
			else{
				Session.uralysProfile.facebookUID = lastFacebookAccountLoggedIn;
				accountWrapper.linkFacebookUID(Session.uralysProfile.uralysUID, lastFacebookAccountLoggedIn);
				playerWrapper.linkFacebookUID(Session.uralysProfile.uralysUID, lastFacebookAccountLoggedIn);
				getFriends();
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