package;

import Shaders.WhiteOverlayShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

/**
 * @author BrightFyre
 */
class FreeplaySelect extends MusicBeatState
{
	static final freeplayStrings:Array<String> = ["story", "bonus", "nightmare"];

	static var curSelected:Int = 0;

	var disableInput:Bool = false;

	var freeplayItems:FlxTypedGroup<FlxSprite>;

	var accepted:Bool = false;

	var allowTransit:Bool = false;

	override public function create()
	{
		super.create();

		persistentUpdate = true;

		#if desktop
		DiscordClient.changePresence("Browsing the Freeplay Select", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.highquality;
		add(bg);

		freeplayItems = new FlxTypedGroup<FlxSprite>();
		add(freeplayItems);

		generateButtons(332);
		changeSelection(curSelected);

		#if android
		addVirtualPad(LEFT_RIGHT, A_B);
		#end

		new FlxTimer().start(Main.transitionDuration, function(tmr:FlxTimer)
		{
			allowTransit = true;
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music(Main.menuMusic));

		if (!disableInput)
		{
			if (controls.ACCEPT)
			{
				enterSelection();
			}

			if (controls.BACK && allowTransit)
			{
				backOut();
			}

			if (controls.LEFT_P)
			{
				changeSelection(curSelected - 1);
			}

			if (controls.RIGHT_P)
			{
				changeSelection(curSelected + 1);
			}
		}
	}

	function backOut()
	{
		allowTransit = false;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxG.switchState(new MainMenuState());
	}

	function generateButtons(sep:Float)
	{
		if (freeplayItems == null)
			return;

		if (freeplayItems.members != null && freeplayItems.members.length > 0)
			freeplayItems.forEach(function(_:FlxSprite)
			{
				freeplayItems.remove(_);
				_.destroy();
			});

		for (i in 0...freeplayStrings.length)
		{
			var str:String = freeplayStrings[i];

			var freeplayItem:FlxSprite = new FlxSprite();
			if (FlxG.save.data.freeplayunlocked[i])
				freeplayItem.loadGraphic(Paths.image("freeplayselect/unlocked", "preload"));
			else
				freeplayItem.loadGraphic(Paths.image("freeplayselect/" + str, "preload"));
			freeplayItem.origin.set();
			freeplayItem.scale.set(MainMenuState.daScaling, MainMenuState.daScaling);
			freeplayItem.updateHitbox();
			freeplayItem.alpha = 0.5;
			freeplayItem.shader = new WhiteOverlayShader();
			freeplayItem.setPosition(120 + (i * sep), 20);

			freeplayItems.add(freeplayItem);
		}
	}

	function changeSelection(selection:Int)
	{
		if (!accepted)
		{
			if (selection != curSelected)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (selection < 0)
				selection = freeplayStrings.length - 1;
			if (selection >= freeplayStrings.length)
				selection = 0;

			trace('selected ' + selection);

			for (i in 0...freeplayStrings.length)
			{
				var freeplayItem:FlxSprite = freeplayItems.members[i];
				if (i == selection)
					freeplayItem.alpha = 1.0;
				else
					freeplayItem.alpha = 0.5;
			}

			curSelected = selection;
		}
	}

	function enterSelection()
	{
		if (FlxG.save.data.freeplayunlocked[curSelected])
		{
			FlxG.camera.shake(0.01);
			FlxG.sound.play(Paths.sound("weekDeny", "shared"));

			trace(FlxG.save.data.freeplayunlocked);

			return;
		}

		accepted = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(1, 0);
		}

		FlxG.sound.play(Paths.sound('confirmMenu'));
		FreeplayState.fromWeek = -1;
		FreeplayState.freeplayType = curSelected;

		freeplayItems.members[curSelected].shader.data.progress.value = [1.0];
		FlxTween.num(1.0, 0.0, 1.0, {ease: FlxEase.cubeOut}, function(num:Float)
		{
			freeplayItems.members[curSelected].shader.data.progress.value = [num];
		});

		for (i in 0...freeplayItems.members.length)
		{
			if (i != curSelected)
			{
				FlxTween.tween(freeplayItems.members[i], {alpha: 0}, 1, {ease: FlxEase.cubeOut});
			}
		}

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.switchState(new FreeplayState());
		});
	}
}
