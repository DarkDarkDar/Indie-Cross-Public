package;

import Shaders.FXHandler;
// import GameJolt.GameJoltAPI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

/**
 * @author BrightFyre
 */
class Caching extends MusicBeatState
{
	var calledDone = false;
	var screen:LoadingScreen;
	var debug:Bool = false;

	public function new()
	{
		super();

		enableTransIn = false;
		enableTransOut = false;
	}

	override function create()
	{
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		super.create();

		screen = new LoadingScreen();
		screen.max = 9;
		add(screen);

		trace("Starting caching...");

		initSettings();
	}

	function initSettings()
	{
		#if debug
		debug = true;
		#end

		FlxG.save.bind(Main.curSave, 'indiecross');

		#if desktop
		DiscordClient.initialize();
		#end

		PlayerSettings.init();
		KadeEngineData.initSave();

		Highscore.load();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		FXHandler.UpdateColors();

		Application.current.onExit.add(function(exitCode)
		{
			FlxG.save.flush();
			#if desktop
			DiscordClient.shutdown();
			#end
			Sys.exit(0);
		});

		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
		FlxG.sound.volume = 1;
		FlxG.sound.muted = false;
		FlxG.fixedTimestep = false;
		FlxG.console.autoPause = false;
		FlxG.autoPause = FlxG.save.data.focusfreeze;

		switch (FlxG.save.data.resolution)
		{
			case 0:
				FlxG.resizeWindow(640, 360);
				FlxG.resizeGame(640, 360);
			case 1:
				FlxG.resizeWindow(768, 432);
				FlxG.resizeGame(768, 432);
			case 2:
				FlxG.resizeWindow(896, 504);
				FlxG.resizeGame(896, 504);
			case 3:
				FlxG.resizeWindow(640, 360);
				FlxG.resizeGame(640, 360);
			case 4:
				FlxG.resizeWindow(1152, 648);
				FlxG.resizeGame(1152, 648);
			case 5:
				FlxG.resizeWindow(1280, 720);
				FlxG.resizeGame(1280, 720);
			case 6:
				FlxG.resizeWindow(1920, 1080);
				FlxG.resizeGame(1920, 1080);
			case 7:
				FlxG.resizeWindow(2560, 1440);
				FlxG.resizeGame(2560, 1440);
			case 8:
				FlxG.resizeWindow(3840, 2160);
				FlxG.resizeGame(3840, 2160);
		}

		// GameJoltAPI.connect();
		// GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		FlxG.worldBounds.set(0, 0);

		FlxG.save.data.optimize = false;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			screen.setLoadingText("Tudo ok!");
			end();
		});
	}

	function end()
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, false);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.switchState(new TitleState());
		});
	}
}
