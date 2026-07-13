var onPhase = false;
var globalEyeNames:Array<String> = ['eye1', 'eye2', 'eye3', 'eye4'];
var eyesGroup:FlxGroup;
function create() {
    eyesGroup = new FlxGroup();
	insert(members.indexOf(boyfriend) - 1, eyesGroup);

}

function startPhase() {
    onPhase = true;
    stage.stageSprites["floor"].alpha = 0;
    FlxTween.tween(stage.stageSprites["light"], {alpha: 0.5}, 1, {ease: FlxEase.sinOut});
    stage.stageSprites["evilhand"].animation.curAnim.curFrame = 2;
    stage.stageSprites["evilhand"].alpha = 1;
    stage.stageSprites["evilhand2"].alpha = 1;
}

function closePhase() {
    onPhase = false;
    eyesGroup.clear();
    remove(stage.stageSprites["evilhand"]);
    remove(stage.stageSprites["evilhand2"]);
}

function stepHit(curStep) {
    switch (curStep) {
        case 3460:
            FlxTween.tween(stage.stageSprites["light"], {alpha: 0}, 3, {ease: FlxEase.sinOut});
        case 2896:
            FlxTween.tween(camHUD, {alpha: 0}, 5, {ease: FlxEase.linear}); 
            FlxTween.tween(camGame.scroll, {y: -1000}, 3, {ease: FlxEase.sinOut});
    }

    if (!onPhase) return;
    if (curBeat % 4 == 0 && globalEyeNames.length > 0) {
		var selectedEyeName:String = FlxG.random.getObject(globalEyeNames);
		var eyeSprite:FlxSprite = new FlxSprite(FlxG.random.float(-1000, 2000), FlxG.random.float(-800, 900));
		eyeSprite.frames = Paths.getSparrowAtlas('stages/badDreams/' + selectedEyeName);
        eyeSprite.antialiasing = Options.antialiasing;
		eyeSprite.animation.addByPrefix('idle', "opening0", 24);
		eyeSprite.animation.play('idle');
		eyeSprite.scrollFactor.set(0.5, 0.5);
        eyesGroup.add(eyeSprite);
		new FlxTimer().start(8, tmr -> eyesGroup.remove(eyeSprite));
	}
}