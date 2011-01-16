package com.skooairs.core
{

import com.skooairs.constants.Session;
import com.skooairs.resources.SoundsContainer;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

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
		private var soundTransform:SoundTransform = new SoundTransform();
		
		public function initMusic():void{
			if(!music){
				var request:URLRequest = new URLRequest("webresources/music/music1.mp3");
	            music = new Sound();
	            music.load(request);
				
				volume = Session.player.musicOn ? 1 : 0;
				playMusic();	
			}
			else{
				if(volume == 1 && !Session.player.musicOn)
					switchState();
			}
		}

		public function switchState():void{
			if(volume == 1){
				volume = 0;
				soundTransform.volume = 0;
				channel.soundTransform = soundTransform;

				Session.player.musicOn = false;
			}
			else{
				volume = 1;
				soundTransform.volume = 1;
				channel.soundTransform = soundTransform;	

				Session.player.musicOn = true;
			}
		}

		public function playMusic():void{
			
			soundTransform.volume = volume;
			
			channel = music.play();
			channel.soundTransform = soundTransform;
			
			channel.addEventListener(Event.SOUND_COMPLETE, nextMusic);
		}

		private function nextMusic(event:Event):void{			
			playMusic();
		}
		
		public function playOkSound():void{
			if(!Session.player.musicOn)
				return;
			
			var sound:Sound = new SoundsContainer.OK() as Sound; 
			sound.play();
		}

		public function playExplosionSound():void{
			if(!Session.player.musicOn)
				return;	
			
			var sound:Sound = new SoundsContainer.EXPLOSION() as Sound; 
			sound.play();
		}

		public function playLoadBombSound():void{
			if(!Session.player.musicOn)
				return;
			
			var sound:Sound = new SoundsContainer.LOAD() as Sound; 
			sound.play();
		}

		public function playClickSound():void{
			if(!Session.player.musicOn)
				return;
				
			var sound:Sound = new SoundsContainer.CLIC() as Sound; 
			sound.play();
		}

		public function playYeahSound():void{
			if(!Session.player.musicOn)
				return;
				
			var sound:Sound = new SoundsContainer.YEAH() as Sound; 
			sound.play();
		}

		public function playBipSound():void{
			if(!Session.player.musicOn)
				return;
				
            var sound:Sound = new SoundsContainer.BIP() as Sound; 
			sound.play();
		}
		
		//public function playBonusSound(bonusName:String):void{
			//if(!Session.player.musicOn)
			//	return;
				
		//	var request:URLRequest = new URLRequest("music/sounds/bonuses/"+bonusName+".mp3");
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