import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.MusicBeatState;
import flixel.util.FlxAxes;
import funkin.backend.utils.DiscordUtil;

static var initialized:Bool = false;
var pressedEnter:Bool = false;
var transitioning:Bool = false;
var logoBl:FlxSprite;
var textGroup:FlxGroup;
var ngSpr:FlxSprite;
var titleText:FlxSprite;
var glowyThing:FlxSprite;
var gradient:FlxSprite;
var tilesThing:FlxBackdrop;
var starBG:FlxBackdrop;
var starFG:FlxBackdrop;
var curWacky:Array<String> = [];
var steps = 0;

// ----- 松开触发标志 -----
var pendingAccept:Bool = false;

function create() {
	if (!initialized)
		CoolUtil.playMenuSong(true);

	

	textGroup = new FlxGroup();

	back = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/titlescreen/back'));
	back.screenCenter(FlxAxes.X);
	back.antialiasing = Options.antialiasing;
	add(back);
	back.visible = false;

	gradient = new FlxSprite(0, 500).loadGraphic(Paths.image('menus/gradient'));
	gradient.blend = 'add';
	gradient.screenCenter(FlxAxes.X);
	gradient.antialiasing = Options.antialiasing;
	add(gradient);
	gradient.visible = false;

	tilesThing = new FlxBackdrop(Paths.image('menus/checker'));
	tilesThing.antialiasing = Options.antialiasing;
	tilesThing.scrollFactor.set(0, 0);
	tilesThing.velocity.set(100, 100);
	tilesThing.alpha = 0.15;
	tilesThing.scale.set(0.7, 0.7);
	tilesThing.updateHitbox();
	add(tilesThing);


	titleText = new FlxSprite(100, 576);
	titleText.frames = Paths.getSparrowAtlas('menus/titlescreen/titleEnter');
	titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
	titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
	titleText.antialiasing = Options.antialiasing;
	titleText.animation.play('idle');
	titleText.updateHitbox();

	logoBl = new FlxSprite(90, -800);
	logoBl.frames = Paths.getSparrowAtlas('menus/logoBumpin');
	logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
	logoBl.scale.set(0.9, 0.9);
	logoBl.updateHitbox();
	logoBl.antialiasing = Options.antialiasing;
	add(logoBl);

	var stupidArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('titlescreen/introText'));
	if (stupidArray.contains(''))
		stupidArray.remove('');
	curWacky = stupidArray[FlxG.random.int(0, stupidArray.length - 1)].split('--');
	
	add(textGroup);

	glowyThing = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/glowy'));
	glowyThing.blend = 0;
	glowyThing.alpha = 0.5;
	glowyThing.updateHitbox();
	glowyThing.screenCenter(FlxAxes.XY);
	insert(100, glowyThing);
	glowyThing.visible = false;

	if (initialized) {
		skipIntro();
	} else {
		initialized = true;
	}
}

function stepHit(curStep) {
	steps = curStep;
}

function update(elapsed:Float) {
	FlxG.camera.zoom = lerp(FlxG.camera.zoom, 1, 0.05);

	// ----- 按下时仅记录意图，不执行任何动作 -----
	if (!pendingAccept && (controls.ACCEPT || FlxG.mouse.justPressed)) {
		pendingAccept = true;
	}

	// ----- 松开时执行（鼠标或键盘 Enter/Space）-----
	if (FlxG.mouse.justReleased && pendingAccept) {
		doAccept();
	}
	if ((FlxG.keys.justReleased.ENTER || FlxG.keys.justReleased.SPACE) && pendingAccept) {
		doAccept();
	}

	// 原有其他 update 逻辑（无改动）
	if (transitioning && pressedEnter) {
		// 防止在过渡中再次触发
		return;
	}
}

function doAccept() {
	if (!pendingAccept) return;
	pendingAccept = false;

	if (!skippedIntro) {
		skipIntro();
	} else if (skippedIntro && !pressedEnter) {
		if (Options.flashingMenu)
			FlxG.camera.flash(FlxColor.WHITE, 1);

		pressedEnter = transitioning = true;

		titleText.animation.play('press');
		CoolUtil.playMenuSFX(1);

		FlxTween.tween(logoBl, {y: logoBl.y + 1200}, 1.2, {ease: FlxEase.sineIn, startDelay: 0.6});
		FlxTween.tween(titleText, {y: titleText.y + 1200}, 1.2, {ease: FlxEase.sineIn, startDelay: 0.5});

		new FlxTimer().start(1.5, function() {
			FlxG.switchState(new MainMenuState());
		});
	}
}

function goToMainMenu() {
	FlxG.switchState(new MainMenuState());
}

function createCoolText(textArray:Array<String>) {
	for (i => text in textArray) {
		if (text == "" || text == null)
			continue;
		var money:Alphabet = new Alphabet(0, (i * 60) + 200, text, true, false);
		money.screenCenter(FlxAxes.X);
		textGroup.add(money);
	}
}

function addMoreText(text:String) {
	var coolText:Alphabet = new Alphabet(0, (textGroup.length * 120) + 200, text, true, false);
	coolText.screenCenter(FlxAxes.X);
	textGroup.add(coolText);
}

function deleteCoolText() {
	while (textGroup.members.length > 0) {
		textGroup.members[0].destroy();
		textGroup.remove(textGroup.members[0], true);
	}
}

function beatHit(curBeat:Int) {
	logoBl.animation.play('bump', true);
	FlxG.camera.zoom += 0.02;

	if (skippedIntro) return;
	switch (curBeat) {
		case 1:
			createCoolText(['是时候']);
		case 3:
			addMoreText('天线宝宝 ');
		case 4:
			deleteCoolText();
		case 5:
			createCoolText(['导演']);
		case 7:
			addMoreText('TNF团队');
		case 8:
			deleteCoolText();
			
		case 9:
			createCoolText(['越过山丘']);
		case 11:
			addMoreText('来自远方');
		case 12:
			deleteCoolText();
		case 13:
			addMoreText('天线宝宝');
		case 14:
			addMoreText('来吧');
		case 15:
			addMoreText('一起玩');
		case 16:
			skipIntro();
			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.5, {ease: FlxEase.expoOut, type: FlxTween.BACKWARD});
	}
}

var skippedIntro:Bool = false;

function skipIntro() {
	if (skippedIntro) return;
	// 清除等待松开的标志，防止自动跳过后再错误触发
	pendingAccept = false;
	
	FlxG.camera.flash(FlxColor.WHITE, 1);
	remove(textGroup);
	add(titleText);
	FlxTween.tween(logoBl, {y: logoBl.y + 800}, 2, {ease: FlxEase.expoOut});
	skippedIntro = true;
	back.visible = true;
	gradient.visible = true;
	glowyThing.visible = true;
}