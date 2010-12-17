package com.skooairs.managers {
	
	import com.facebook.graph.Facebook;
	import com.skooairs.constants.Names;
	import com.skooairs.constants.Session;
	import com.skooairs.constants.Translations;
	import com.skooairs.core.MusicPlayer;
	import com.skooairs.entities.Player;
	import com.skooairs.entities.UralysProfile;
	
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
		// CONTROLS
		//============================================================================================//
		//  Controles pour les actions depuis les vues
		
		
		
		
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
		
		public function registered(event:ResultEvent):void{
			
			Session.uralysProfile = event.result as UralysProfile;
			
			if(Session.uralysProfile.uralysUID == "EMAIL_EXISTS"){
				Session.game.message("This email is registered yet", 3);
				Session.WAIT_FOR_SERVER = false;
			}
			else{
				playerWrapper.createPlayer.addEventListener("result", playerCreated);
				playerWrapper.createPlayer(Session.uralysProfile.uralysUID);
			}
		}
		
		
		public function resultLogin(event:ResultEvent):void{
			
			Session.uralysProfile = event.result as UralysProfile;
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
		
		//==================================================================================================//
		// SkooairsServer

		public function playerCreated(event:ResultEvent):void{
			
			Session.player = event.result as Player;
			
			if(!playerCreatedAutomatically)
				Session.game.message("Profil Uralys cree. Bienvenue !", 6);
			
			Session.WAIT_FOR_SERVER = false;
			Session.LOGGED_IN = true;
			Session.game.hideLogin.play();
		}
		
		private var playerCreatedAutomatically:Boolean = false;
		public function receivedPlayer(event:ResultEvent):void{
			
			var player:Player = event.result as Player;
			
			if(player == null){
				playerCreatedAutomatically = true;
				playerWrapper.createPlayer.addEventListener("result", playerCreated);
				playerWrapper.createPlayer(Session.uralysProfile.uralysUID);
			}
			else{
				Session.player = player;
				Session.WAIT_FOR_SERVER = false;
				Session.LOGGED_IN = true;
				Session.game.hideLogin.play();
			}
		}
		
		
		//==================================================================================================//
		// facebook

		private var facebookOperation:int = 0;
		private var NEW_LINK:int = 1;
		private var CONNECT_TO_EXISTING_LINK:int = 2;
		private var LOGIN:int = 3;
		
		private function autoLoginFacebook():void{
			Session.CONNECTED_TO_FACEBOOK = true;
			facebookOperation = LOGIN;
			Facebook.init("121585177900212", loginHandler);
		}
		
		public function loginFacebook():void{
			if(Session.isLocal)
				return;
				
			// logged in the uralys account yet
			if(Session.LOGGED_IN){

				// try to link a facebook account with this uralys account.
				if(Session.player.facebookUID == null){
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
				
			Session.CONNECTED_TO_FACEBOOK = true;
			Facebook.login(loginHandler,{perms:"user_birthday,read_stream,publish_stream"});
			
		}
		
		protected function loginHandler(success:Object,fail:Object):void{
			Session.CONNECTED_TO_FACEBOOK = false;
			
			if(success){
				
				switch(facebookOperation){
					case NEW_LINK : 
						Session.uralysProfile.facebookUID = success.uid;
						accountWrapper.existFacebookPlayer.addEventListener("result", resultExistFBTest);
						accountWrapper.existFacebookPlayer(Session.player.facebookUID);
						break;
					case CONNECT_TO_EXISTING_LINK : 
						if(Session.uralysProfile.facebookUID != success.uid)
							Facebook.api("/"+Session.uralysProfile.facebookUID, badLink);
						else
							Session.game.message(Translations.CONNECTION_OK.getItemAt(Session.LANGUAGE) as String, 4);

						break;
					case LOGIN : 
						Session.CONNECTED_TO_FACEBOOK = true;
						Facebook.api("/me/friends", getFriendsHandler);
						
						accountWrapper.loginFromFacebook.addEventListener("result", resultLogin);
						accountWrapper.loginFromFacebook(Session.player.facebookUID);
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
		
	}
}