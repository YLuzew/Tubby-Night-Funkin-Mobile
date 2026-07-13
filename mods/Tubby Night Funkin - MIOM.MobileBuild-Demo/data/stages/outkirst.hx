import flixel.addons.display.FlxBackdrop;

var loopedTimah:FlxTimer;
var norun = true;
var drain = false;

var barTop:FlxSprite;
var barBottom:FlxSprite;
var fart:FunkinSprite; 

var splashShader:CustomShader;

function postUpdate() {
    if (norun) {
        defaultCamZoom = (curCameraTarget == 1) ? 0.7 : 0.8;
    }
    
    if (drain) {
        iconP2.x = 900;
        iconP2.flipX = true;
        
        if (health > 0.5) {
            if (PlayState.difficulty == 'HARD') health -= .0007;
            else if (PlayState.difficulty == 'NORMAL') health -= .0004;
        }
    }

    if (!norun && boyfriend.animation.curAnim.name == "idle" && !arm.visible){
        arm.visible = true;
        arm.animation.play("idle", true);
    }
}

function onPlayerHit(e) {
    if (!norun) {
        arm.visible = false; 
    }
}

function postCreate() {
    whiteFlash = new FlxSprite().makeSolid(FlxG.width, 100, FlxColor.WHITE);
    whiteFlash.setGraphicSize(Std.int(whiteFlash.width + 1800));
    whiteFlash.scrollFactor.set(0, 0);
    whiteFlash.screenCenter();
    whiteFlash.alpha = 0;
    add(whiteFlash);
    whiteFlash.blend = 0;

    blackBarThingie = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBarThingie.zoomFactor = 0;
    blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width + 500));
    blackBarThingie.scrollFactor.set(0, 0);
    blackBarThingie.screenCenter();
    blackBarThingie.alpha = 0;

    remove(camHUD);
    add(blackBarThingie);
    add(camHUD);

    mountain = new FlxBackdrop(Paths.image("stages/outkirts/run/mountain"), 1, -500);
    mountain.velocity.set(100);
    mountain.antialiasing = Options.antialiasing;
    insert(members.indexOf(dad), mountain);
    mountain.scrollFactor.set(0.1, 0.1);
    mountain.y = 300;
    mountain.visible = false;

    ruinsfarback = new FlxBackdrop(Paths.image("stages/outkirts/run/ruins-far-back"), 1, -500);
    ruinsfarback.velocity.set(3000);
    ruinsfarback.antialiasing = Options.antialiasing;
    insert(members.indexOf(dad), ruinsfarback);
    ruinsfarback.scrollFactor.set(0.7, 0.7);
    ruinsfarback.y = 750;
    ruinsfarback.visible = false;

    if (!Options.lowMemoryMode) {
        fogfront = new FlxSprite(-800,-100).loadGraphic(Paths.image("stages/outkirts/run/fog-front"));
        fogfront.cameras = [camHUD];
        fogfront.antialiasing = Options.antialiasing;
        fogfront.scrollFactor.set(0, 0);
        fogfront.blend = 0;
        insert(members.indexOf(dad), fogfront);
        fogfront.visible = false;
    }

    ruinsbackground = new FlxBackdrop(Paths.image("stages/outkirts/run/ruins-background"), 1, -500);
    ruinsbackground.velocity.set(3500);
    ruinsbackground.antialiasing = Options.antialiasing;
    insert(members.indexOf(dad), ruinsbackground);
    ruinsbackground.scrollFactor.set(0.8, 0.8);
    ruinsbackground.y = 550;
    ruinsbackground.visible = false;

    groundrun = new FlxBackdrop(Paths.image("stages/outkirts/run/ground"), 1, -1000);
    groundrun.velocity.set(4200);
    groundrun.antialiasing = Options.antialiasing;
    insert(members.indexOf(dad), groundrun);
    groundrun.scrollFactor.set(1, 1);
    groundrun.y = 1300;
    groundrun.visible = false;

    leg = new FlxSprite(1230, 790);
    leg.frames = Paths.getFrames('stages/outkirts/anims/legs');
    leg.animation.addByPrefix("idle", "legs0", 24, true);
    leg.antialiasing = Options.antialiasing;
    insert(members.indexOf(groundrun) + 1, leg);
    leg.scale.set(1, 1);
    leg.visible = false;

    arm = new FlxSprite(1230, 790);
    arm.frames = Paths.getFrames('stages/outkirts/anims/arms');
    arm.animation.addByPrefix("idle", "idle-arm", 24, true);
    arm.antialiasing = Options.antialiasing;
    insert(members.indexOf(groundrun) + 1, arm);
    arm.scale.set(1, 1);
    arm.visible = false;

    laaleg = new FlxSprite(2677, 980);
    laaleg.frames = Paths.getFrames('stages/outkirts/anims/laa-laa-legs');
    laaleg.animation.addByPrefix("idle", "laa-laa-legs", 24, true);
    laaleg.antialiasing = Options.antialiasing;
    insert(members.indexOf(groundrun) + 1, laaleg);
    laaleg.scale.set(1, 1);
    laaleg.visible = false;

    wallfront = new FlxBackdrop(Paths.image("stages/outkirts/run/walls-up-front"), 1, 500);
    wallfront.velocity.set(5000);
    wallfront.antialiasing = Options.antialiasing;
    insert(members.indexOf(boyfriend) + 2, wallfront);
    wallfront.scrollFactor.set(1.2, 1.2);
    wallfront.y = 1050;
    wallfront.visible = false;

    fart = new FunkinSprite(3200, 1360, Paths.image("stages/outkirts/run/LAA-LAA-RUNING-WALL"));
    XMLUtil.addAnimToSprite(fart, {
        name: "death", anim: "laa laa death", fps: 30, loop: false, 
        animType: "loop", x: 4090, y: 930, indices: [], forced: false 
    });
    fart.visible = false;
    insert(members.indexOf(dad) + 1, fart);

    var camCinematics:FlxCamera = new FlxCamera();
    camCinematics.bgColor = 0;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camCinematics, false);
    FlxG.cameras.add(camHUD, false);

    barBottom = new FlxSprite(0, FlxG.height).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barBottom.cameras = [camCinematics];
    add(barBottom);

    blackchara = new FlxSprite(-200, 0).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    blackchara.scrollFactor.set(0, 0);
    insert(members.indexOf(dad) - 2, blackchara);
    blackchara.alpha = 0;

    barTop = new FlxSprite(0, -FlxG.height).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barTop.cameras = [camCinematics];
    add(barTop);

    if (!Options.lowMemoryMode) {
        if (Options.gameplayShaders) {
            splashShader = new CustomShader('adjustColor');
            splashShader.hue = 0;
            splashShader.saturation = -255;
            splashShader.brightness = 255;
            splashShader.contrast = 0;
        }
    }
}

function stepHit(curStep:Int) {
    switch (curStep) {
        case 287:
            camZoomingInterval = 2;

        case 400:
            FlxTween.tween(blackBarThingie, {alpha: 1}, 1);
            FlxTween.tween(camGame, {zoom: 1.2}, 1.5, {ease: FlxEase.quadInOut});

        case 416:
            leg.visible = true;
            leg.animation.play("idle");
            laaleg.animation.play("idle");
            arm.animation.play("idle", true);

        case 418:
            FlxTween.tween(blackBarThingie, {alpha: 0}, 0.01);
            
            var hideStage = ["bg", "wbbg", "wbg", "ground", "wallfg"];
            for (spr in hideStage) {
                if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].visible = false;
            }

            if (stage.stageSprites.exists("skyrun")) {
                stage.stageSprites["skyrun"].visible = true;
                stage.stageSprites["skyrun"].alpha = 1;
            }

            if (!Options.lowMemoryMode) {
                if (stage.stageSprites.exists("overlay")) stage.stageSprites["overlay"].visible = false;
                if (stage.stageSprites.exists("overlayrun")) {
                    stage.stageSprites["overlayrun"].visible = true;
                    stage.stageSprites["overlayrun"].alpha = 0.5;
                }
            }

            norun = false;
            drain = true;

            for (H in [groundrun, mountain, wallfront, ruinsbackground, laaleg, ruinsfarback]) {
                H.visible = true;
            }

            camZoomingInterval = 1;
            whiteFlash.alpha = 0.8;
            FlxTween.tween(whiteFlash, {alpha: 0}, 1);
            defaultCamZoom = 0.4;

            for (i in 0...4) {
                FlxTween.tween(player.members[i], {x:100 + i * 115}, 0.4,{ease: FlxEase.quadInOut});
                FlxTween.tween(cpu.members[i], {x:700 + i * 115}, 0.4,{ease: FlxEase.quadInOut});
            }

        case 568 | 632 | 672:
            defaultCamZoom = 0.8;
            camZoomingInterval = 8;
            FlxTween.tween(barTop, {y: -FlxG.height + 85}, 0.4, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            FlxTween.tween(barBottom, {y: FlxG.height - 85}, 0.4, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            for (i in 0...4) {
                FlxTween.tween(cpu.members[i], {y:90}, 0.4);
                FlxTween.tween(player.members[i], {y: 90}, 0.4);
            }

        case 576 | 640 | 928:
            defaultCamZoom = 0.4;
            camZoomingInterval = 1;
            whiteFlash.alpha = 0.8;
            FlxTween.tween(whiteFlash, {alpha: 0}, 1);
            FlxTween.tween(barTop, {y: -FlxG.height}, 0.3, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            FlxTween.tween(barBottom, {y: FlxG.height}, 0.3, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            for (i in 0...4) {
                FlxTween.tween(cpu.members[i], {y: 50}, 0.4);
                FlxTween.tween(player.members[i], {y: 50}, 0.4);
            }
    
        case 1180: 
            blackBarThingie.cameras = [camHUD];
            FlxTween.tween(blackBarThingie, {alpha: 1}, 0.15);
            FlxTween.tween(camGame, {zoom: 1}, 0.3, {ease: FlxEase.quadInOut});
            
        case 1182:  
            iconP2.flipX = false;     
            drain = false;
            
        case 1184:  
            FlxTween.tween(blackBarThingie, {alpha: 0}, 1.2);
            arm.visible = false;
            arm.alpha = 0;  
            for(a in strumLines){
                for(b in a){
                    updateStrumSkin(b, "game/notes/wire", b.ID);
                    b.y = a.startingPos.y;
                }
                for(c in a.notes)
                    updateNoteSkin(c, "game/notes/wire");
            }
            
            for (H in [groundrun, mountain, wallfront, ruinsbackground, laaleg, ruinsfarback, leg]) {
                H.visible = false;
            }

            if (stage.stageSprites.exists("skyrun")) stage.stageSprites["skyrun"].visible = false;

            if (!Options.lowMemoryMode) {
                var hideRunXML = ["overlayrun", "overlay", "fogbbg"];
                for (spr in hideRunXML) {
                    if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].visible = false;
                }

                if (Options.gameplayShaders) {
                    healthBarBG.shader = new CustomShader('adjustColor');
                    healthBarBG.shader.hue = 0;
                    healthBarBG.shader.saturation = 0;
                    healthBarBG.shader.brightness = 255;
                    healthBarBG.shader.contrast = 0;
                }
            }

            if (Options.lowMemoryMode) {
                healthBarBG.shader = null;
            }

            drain = false;
            defaultCamZoom = 0.9;
            boyfriend.alpha = 0.0001;
            camZoomingInterval = 6;

            iconP2.setIcon('laalaa-outline');
            iconP1.setIcon('bf-outline');

            healthBar.createFilledBar(FlxColor.BLACK, FlxColor.BLACK);
           
            if (stage.stageSprites.exists("outlinestage")) stage.stageSprites["outlinestage"].alpha = 1;
            for (a in [scoreTxt, missesTxt, accuracyTxt]) {
                a.alpha = 0;
            }

       case 1419:
            blackBarThingie.cameras = [camGame];
            FlxTween.tween(blackBarThingie, {alpha: 1}, 0.3);
            FlxTween.tween(camGame, {zoom: 0.8}, 0.5, {ease: FlxEase.quadInOut});

        case 1423: 
            for(a in strumLines){
                for(b in a){
                    updateStrumSkin(b, "game/notes/default", b.ID);
                    b.y = a.startingPos.y;
                }
                for(c in a.notes)
                    updateNoteSkin(c, "game/notes/default");
            }    
            arm.alpha = 1;
            blackBarThingie.alpha = 0;
            whiteFlash.alpha = 0.8;
            FlxTween.tween(whiteFlash, {alpha: 0}, 1);
            
            for (H in [groundrun, mountain, wallfront, ruinsbackground, laaleg, ruinsfarback, leg]) {
                H.visible = true;
            }
            
            if (stage.stageSprites.exists("skyrun")) stage.stageSprites["skyrun"].visible = true;

            if (!Options.lowMemoryMode) {
                var showRunXML = ["overlayrun", "overlay", "fogbbg"];
                for (spr in showRunXML) {
                    if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].visible = true;
                }
            }

            healthBarBG.shader = null;

            iconP2.setIcon('outskirt');
            iconP1.setIcon('bf');

            healthBar.createFilledBar(dad.iconColor, boyfriend.iconColor);

            for (a in [scoreTxt, missesTxt, accuracyTxt]) {
                a.alpha = 1;
            }
            defaultCamZoom = 0.4;
            boyfriend.alpha = 1;
            camZoomingInterval = 1;
            
            if (stage.stageSprites.exists("outlinestage")) stage.stageSprites["outlinestage"].alpha = 0;
            drain = true;
            iconP2.flipX = true; 

        case 1947: 
            fart.visible = true;
            fart.playAnim("death", true);
            dad.visible = false;
            laaleg.visible = false;

        case 1968:
            blackBarThingie.cameras = [camHUD];
            blackBarThingie.alpha = 1;
    }
}

function onSplashShown(e){
    if (!Options.lowMemoryMode) {
        if (splashShader != null) {
            e.splash.shader = (curStep >= 1184 && curStep < 1423) ? splashShader : null;
        }
    }
}

function updateStrumSkin(theFucking:Strum, newSkin:String, id:Int) {
    theFucking.frames = Paths.getSparrowAtlas(newSkin);

    theFucking.animation.addByPrefix('green', 'arrowUP');
    theFucking.animation.addByPrefix('blue', 'arrowDOWN');
    theFucking.animation.addByPrefix('purple', 'arrowLEFT');
    theFucking.animation.addByPrefix('red', 'arrowRIGHT');

    theFucking.antialiasing = Options.antialiasing;
    theFucking.setGraphicSize(Std.int(theFucking.width * 0.7));

    theFucking.animation.addByPrefix('static', 'arrow' + ["left", "down", "up", "right"][id].toUpperCase());
    theFucking.animation.addByPrefix('pressed', ["left", "down", "up", "right"][id] + ' press', 24, false);
    theFucking.animation.addByPrefix('confirm', ["left", "down", "up", "right"][id] + ' confirm', 24, false);

    theFucking.animation.play('static');
    theFucking.updateHitbox();
}

function updateNoteSkin(theFucker:Note, newSkin:String){
    var idk = theFucker.animation.name;
    theFucker.frames = Paths.getSparrowAtlas(newSkin);

    theFucker.animation.addByPrefix(idk, switch(idk){
        case 'scroll': ['purple', 'blue', 'green', 'red'][theFucker.strumID % 4] + '0';
        case 'hold': ['purple hold piece', 'blue hold piece', 'green hold piece', 'red hold piece'][theFucker.strumID % 4];
        case 'holdend': ['pruple end hold', 'blue hold end', 'green hold end', 'red hold end'][theFucker.strumID % 4] + '0';
    });

    theFucker.animation.play(idk);
    theFucker.updateHitbox();
}