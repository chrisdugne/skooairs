package com.skooairs.core
{

import flash.net.URLRequest;
import flash.media.Sound;    
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.events.Event;

import com.skooairs.constants.Session;

/**
The MusicPlayer manages the sounds
*/
public class MusicPlayer
{		
		/**
			Ménilmontant (Charles Trenet) performed by Swing from Paris at The Vaults Feb 2009.
			
			
			Fenner Curtis - Violin
			Andy Bowen - Lead Guitar
			John Vickers - Double Bass
			Stefan Doucette - Rhythm Guitar
			
			For tracks and more info please visit www.swingfromparis.com
			
			Recorded and edited by Dale Campbell.
		**/
		private static var instance : MusicPlayer = new MusicPlayer(); 
	
		public static function getInstance():MusicPlayer{
			return instance;
		}

		public function MusicPlayer(){}

		//=====================================================================================//
		
		private var music:Sound;
		private var volume:int = 1;
		private var channel:SoundChannel;
		private var soundTransform:SoundTransform;
		
		public function initMusic():void{
			var request:URLRequest = new URLRequest("webresources/music/music1.mp3");
            music = new Sound();
            music.load(request);
			
			volume = Session.uralysProfile.musicOn ? 1 : 0;
			playMusic();	
		}

		/* called when a player just log in
			return false if the Off status must be recorded 
		*/
		public function testMusic():Boolean{
			if(volume == 1 && !Session.uralysProfile.musicOn){
				// volume was on and the loggedin player recorded off
				volume = 0;
				
				if(soundTransform){
					soundTransform.volume = 0;
					channel.soundTransform = soundTransform;
				}
			}
			else if(volume == 0){
				// volume was off : record this choice for the loggedin player (by returning false)
				Session.uralysProfile.musicOn = false;
				return false; 
			}
			else{
				initMusic();
			}
			
			return true;
		}

		public function switchState():void{
			if(volume == 1){
				volume = 0;
				soundTransform.volume = 0;
				channel.soundTransform = soundTransform;

				Session.uralysProfile.musicOn = false;
			}
			else{
				volume = 1;
				soundTransform.volume = 1;
				channel.soundTransform = soundTransform;	

				Session.uralysProfile.musicOn = true;
			}
		}

		public function playMusic():void{
			
			soundTransform = new SoundTransform();
			soundTransform.volume = volume;
			
			channel = music.play();
			channel.soundTransform = soundTransform;
			
			channel.addEventListener(Event.SOUND_COMPLETE, nextMusic);
		}

		private function nextMusic(event:Event):void{			
			playMusic();
		}
		
		public function playOkSound():void{
			if(!Session.uralysProfile.musicOn)
				return;
				
			var request:URLRequest = new URLRequest("webresources/music/sounds/ok.mp3");
            var sound:Sound = new Sound();
            sound.load(request);
			sound.play();
		}

		public function playExplosionSound():void{
			if(!Session.uralysProfile.musicOn)
				return;
				
			var request:URLRequest = new URLRequest("webresources/music/sounds/explosion.mp3");
            var sound:Sound = new Sound();
            sound.load(request);
			sound.play();
		}

		public function playLoadBombSound():void{
			if(!Session.uralysProfile.musicOn)
				return;
				
			var request:URLRequest = new URLRequest("webresources/music/sounds/load.mp3");
            var sound:Sound = new Sound();
            sound.load(request);
			sound.play();
		}

		public function playClickSound():void{
			if(!Session.uralysProfile.musicOn)
				return;
				
			var request:URLRequest = new URLRequest("webresources/music/sounds/clic.mp3");
            var sound:Sound = new Sound();
            sound.load(request);
			sound.play();
		}

		public function playYeahSound():void{
			if(!Session.uralysProfile.musicOn)
				return;
				
			var request:URLRequest = new URLRequest("webresources/music/sounds/yeah.mp3");
            var sound:Sound = new Sound();
            sound.load(request);
			sound.play();
		}

		public function playBipSound():void{
			if(!Session.uralysProfile.musicOn)
				return;
				
			var request:URLRequest = new URLRequest("webresources/music/sounds/bip.mp3");
            var sound:Sound = new Sound();
            sound.load(request);
			sound.play();
		}
		
		//public function playBonusSound(bonusName:String):void{
			//if(!Session.uralysProfile.musicOn)
			//	return;
				
		//	var request:URLRequest = new URLRequest("webresources/music/sounds/bonuses/"+bonusName+".mp3");
        //    var sound:Sound = new Sound();
        //     sound.load(request);
		//	sound.play();
		//}
		
		
		/*
			volume management
			
			mySoundChannel = music.play(); 
			mySoundTransform = new SoundTransform;
			mySoundTransform.volume = 0.5;
			mySoundChannel.soundTransform = mySoundTransform;
			
		*/
}


}