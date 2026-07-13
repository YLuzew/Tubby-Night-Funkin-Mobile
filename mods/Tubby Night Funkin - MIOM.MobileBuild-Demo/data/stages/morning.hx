var overlay:FlxSprite;
var hud:FlxSprite;
var whiteFlash:FlxSprite;
var blackBarThingie:FlxSprite;

function postCreate() {
    if (curSong == "custa starz") {
        
        remove(lala);
        remove(dipsy);
        strumLines.members[0].characters[0].x = -32;
        strumLines.members[2].characters[0].x = -232;
	
    }

   if (curSong == "custa-starz-old") {
        
        remove(lala);
        remove(dipsy);
        strumLines.members[0].characters[0].x = -32;
        strumLines.members[2].characters[0].x = -232;
	
    }
    
    if (curSong == "optimistic") {
        remove(lala);

        overlay = new FlxSprite(-630, -350).loadGraphic(Paths.image('stages/morning/hud'));
        overlay.cameras = [camHUD];
        overlay.scale.set(0.55, 0.55);
        overlay.scrollFactor.set(0, 0);
        overlay.blend = 0;
        overlay.alpha = 0;
        add(overlay);

        hud = new FlxSprite(-900, -500).loadGraphic(Paths.image('stages/morning/flowers-hud'));
        hud.frames = Paths.getSparrowAtlas('stages/morning/flowers-hud');
        hud.animation.addByPrefix('idle', "Occurrence flowers-hud 10", 24);
        hud.animation.play('idle');
        hud.scale.set(0.5, 0.5);
        hud.cameras = [camHUD];
        hud.scrollFactor.set(0, 0);
        hud.alpha = 0;
        add(hud);

        whiteFlash = new FlxSprite().makeSolid(FlxG.width, 100, FlxColor.WHITE);
        whiteFlash.setGraphicSize(Std.int(whiteFlash.width + 4000));
        whiteFlash.scrollFactor.set(0, 0);
        whiteFlash.screenCenter();
        whiteFlash.alpha = 0;
        whiteFlash.blend = 0;
        add(whiteFlash);

        camHUD.alpha = 0;
    }

    if (curSong == "dipstick") {
        remove(dipsy);
        remove(overlay);

        blackBarThingie = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width + 1000));
        blackBarThingie.scrollFactor.set(0, 0);
        blackBarThingie.screenCenter();
        blackBarThingie.alpha = 0;
        insert(members.indexOf(gf) + 10, blackBarThingie);
    }
}

var boyfriendDances = false;

function stepHit(curStep) {
    if (curSong == 'dipstick') {
        switch (curStep) {
            case 128:
                camZoomingInterval = 2;
            case 192, 516, 896, 1152:
                camZoomingInterval = 1;
            case 512:
                camZoomingInterval = 100;
            case 768:
                camZoomingInterval = 8;
            case 1024:
                camZoomingInterval = 4;
            case 1409:
                camZoomingInterval = 1;
                FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.smootherStepInOut});
                boyfriend.playAnim('bf-wait-what');
                gf.playAnim('gf-oh-what');
                lala.playAnim('dancelala', true);
            case 1472:
                camZoomingInterval = 1;
                boyfriendDances = true;
                defaultCamZoom = 0.7;
            case 1588:
                FlxTween.tween(blackBarThingie, {alpha: 1}, 4, {ease: FlxEase.smootherStepInOut});
        }

        if(curStep >= 1408 && curStep <= 1660){
            if(curStep % 4 == 0){
                dad.playSingAnim(1, '-alt', 'SING', true);
                if(boyfriendDances) boyfriend.playSingAnim(1, '-dance', 'SING', true);
            }else if(curStep % 2 == 0){
                dad.playSingAnim(2, '-alt', 'SING', true);
                if(boyfriendDances) boyfriend.playSingAnim(2, '-dance', 'SING', true);
            }
        }
    }

    if (curSong == "optimistic") {
        switch (curStep) {
            case 10:
                FlxTween.tween(camHUD, {alpha: 1}, 6, {ease: FlxEase.linear});
            case 192:
                camZoomingInterval = 2;
            case 320:
                FlxTween.tween(hud, {alpha: 1}, 2, {ease: FlxEase.smootherStepInOut});
                FlxTween.tween(overlay, {alpha: 1}, 2, {ease: FlxEase.smootherStepInOut});
                triggerFlash();
            case 448, 512, 704, 768, 912, 976:
                triggerFlash();
            case 576:
                FlxTween.tween(hud, {alpha: 0}, 2, {ease: FlxEase.smootherStepInOut});
                FlxTween.tween(overlay, {alpha: 0}, 2, {ease: FlxEase.smootherStepInOut});
                triggerFlash();
            case 848:
                FlxTween.tween(overlay, {alpha: 1}, 2, {ease: FlxEase.smootherStepInOut});
                FlxTween.tween(hud, {alpha: 1}, 2, {ease: FlxEase.smootherStepInOut});
                triggerFlash();
            case 1104:
                FlxTween.tween(overlay, {alpha: 0}, 2, {ease: FlxEase.smootherStepInOut});
                FlxTween.tween(hud, {alpha: 0}, 2, {ease: FlxEase.smootherStepInOut});
                triggerFlash();
            case 1232:
                FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.linear});
        }
    }
}

function triggerFlash() {
    whiteFlash.alpha = 0.7;
    FlxTween.tween(whiteFlash, {alpha: 0}, 1, {ease: FlxEase.smootherStepInOut});
}