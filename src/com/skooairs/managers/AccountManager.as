package com.skooairs.managers {
	
	import com.skooairs.constants.Names;
	import com.skooairs.constants.Session;
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
			
			if(Session.uralysProfile.uralysUID == "WRONG_PWD"){
				Session.game.message("Authentication Failed", 3);
				Session.WAIT_FOR_SERVER = false;
			}
			else{
				playerWrapper.getPlayer.addEventListener("result", receivedPlayer);
				playerWrapper.getPlayer(Session.uralysProfile.uralysUID);
			}
		}

		//-------------------------------------------------------------------------//
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

	}
}