package myriadLands.sound {
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import gamestone.events.SoundsEvent;
	import gamestone.sound.SoundItem;
	import gamestone.sound.SoundManager;
	import gamestone.utils.ArrayUtil;
	
	import myriadLands.core.Settings;
	
	public final class Sounds {
		
		private static var soundManager:SoundManager;
		private static var allMusic:Array;
		
		private static var voicesPlaying:Array;
		
		public static function init():void {
			soundManager = SoundManager.getInstance();
			
			setMusicVolume(Settings.musicVolume);
			setSoundVolume(Settings.soundVolume);
			
			allMusic = soundManager.getSoundIDsByGroup("music");
			
			voicesPlaying = [];
		}
		
		public static function play(soundID:String, loops:int = 1):Boolean {
			return soundManager.playSound(soundID, 0, loops);
		}
		
		public static function play3D(obj:DisplayObject, soundID:String, loops:int = 1):Boolean {
			try {
				var global:Point = obj.stage.localToGlobal(new Point(obj.x, obj.y));
				var pan:Number = 2 * (global.x / Settings.screenWidth) + -1;
				var vol:Number = .3 + (global.y / Settings.screenHeight) * .7;
				var sound:SoundItem = soundManager.getSound(soundID);
				sound.pan = pan;
				sound.volume = sound.startingVolume*vol;
				return play(soundID, loops);
			} catch(error:TypeError) {
				trace("Sounds.play3D null object: " + obj, soundID);
			}
			return false;
		}
		
		public static function playVoice(obj:DisplayObject, soundID:String, loops:int = 1):void {
			if(!Settings.voiceOvers) return;
			
			try {
				if (voicesPlaying.length >= Settings.MAX_CONCURRENT_VOICES)
					return;
				
				soundManager.getSound(soundID).addEventListener(SoundsEvent.PLAYBACK_COMPLETE, voicePlaybackOver, false, 0, true);
				if (play3D(obj, soundID, loops)) {
					//if (voicesPlaying.indexOf(soundID) )
					voicesPlaying.push(soundID);
				}
			} catch (error:TypeError) {
				trace("Error: Sound with id=" + soundID + " does not exist in Sounds.");
				trace(error);
			}
		}
		
		private static function voicePlaybackOver(event:SoundsEvent):void {
			ArrayUtil.remove(voicesPlaying, event.id);
		}
		
		public static function playSpaceBackground():void {
			playMusic("space");
		}
		
		public static function playIntroMusic():void {
			playMusic("intro");
		}
		
		public static function setMusicVolume(v:int):void {
			soundManager.setSoundGroupVolume("music", .01 * v);
			Settings.musicVolume = v;
		}
		
		public static function setSoundVolume(v:int):void {
			soundManager.setSoundGroupVolume("sounds", .01 * v);
			Settings.soundVolume = v;
		}
		
		private static function playMusic(musicID:String):void {
			var music:SoundItem = getMusic(musicID);
			if (music.isPlaying()) return;
			
			fadeAll(musicID);
			music.fadeIn(1, 1500, 0, 1000);
		}
		
		private static function getMusic(id:String):SoundItem {
			return soundManager.getSound(id);
		}
		
		private static function fadeAll(except:String):void {
			var musicID:String;
			var music:SoundItem;
			for each (musicID in allMusic) {
				music = soundManager.getSound(musicID);
				if (music.isPlaying())
					music.fadeOut(0, 1000);
			}
		}
		
	}
}