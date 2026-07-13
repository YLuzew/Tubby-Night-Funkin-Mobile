import hxvlc.flixel.FlxVideoSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

introLength = 0;

var barTop:FlxSprite;
var barBottom:FlxSprite;
var ending:FlxVideoSprite;
var tinky:FunkinSprite;
var whiteFlash:FlxSprite;
var blackBarThingie:FlxSprite;
var sceneObjects:Array<FlxBasic>;

var warningActive:Bool = false;
var camWarning:FlxCamera;
var warningBg:FlxSprite;
var warningText:FlxText;
var optionYes:FlxText;
var optionNo:FlxText;
var selectedOption:Int = 0;          // 0=YES, 1=NO
var keyboardSelectionEnabled:Bool;    // 是否通过方向键激活了选中
var currentCensor:Bool = false;

// 鼠标/触摸交互变量
var pressedButton:Int = -1;           // -1=无按下, 0=YES, 1=NO
var hoverButton:Int = -1;             // 当前悬浮的按钮

function onCountdown(event) {
        event.cancel(); 
}

function postCreate() {
    sky = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000033);
    sky.setGraphicSize(Std.int(sky.width + 800));
    sky.scrollFactor.set(0, 0);
    sky.screenCenter();
    insert(members.indexOf(mountain) - 1, sky);

    blackBarThingie = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width + 2500));
    blackBarThingie.scrollFactor.set(0, 0);
    blackBarThingie.screenCenter();
    blackBarThingie.cameras = [camHUD];
    blackBarThingie.alpha = 0;
    add(blackBarThingie);
    
    blackBarThingiegame = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBarThingiegame.setGraphicSize(Std.int(blackBarThingiegame.width + 2500));
    blackBarThingiegame.scrollFactor.set(0, 0);
    blackBarThingiegame.screenCenter();
    blackBarThingiegame.alpha = 0;
    add(blackBarThingiegame);

    whiteFlash = new FlxSprite().makeGraphic(FlxG.width, 1500, FlxColor.WHITE);
    whiteFlash.setGraphicSize(Std.int(whiteFlash.width + 2500));
    whiteFlash.scrollFactor.set(0, 0);
    whiteFlash.screenCenter();
    whiteFlash.alpha = 0;
    add(whiteFlash);
    
    camHUD.visible = false;

    var camCinematics:FlxCamera = new FlxCamera();
    camCinematics.bgColor = 0;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camCinematics, false);
    FlxG.cameras.add(camHUD, false);

    barBottom = new FlxSprite(0, FlxG.height).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barBottom.cameras = [camCinematics];
    add(barBottom);

    barTop = new FlxSprite(0, -FlxG.height).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barTop.cameras = [camCinematics];
    add(barTop);
    
    blackchara = new FlxSprite(-200, 0).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    blackchara.scrollFactor.set(0, 0);
    blackchara.alpha = 0;
    insert(members.indexOf(dad) - 2, blackchara);

    tinky = new FunkinSprite(1250, 400, Paths.image("stages/mainlandV2/tinky"));
    tinky.antialiasing = Options.antialiasing;
    XMLUtil.addAnimToSprite(tinky, { name: "scream", anim: "TINKY-WINKY-TWEAKING", fps: 24, loop: false });
    tinky.visible = false;
    tinky.updateHitbox();
    insert(members.indexOf(dad) + 5, tinky);

    ending = new FlxVideoSprite(-320, -185);
    
    sceneObjects = [mountain, ground, tree, custard, dad, boyfriend, sky, po, po_alt, poeyes, treealt];

    if (!Options.lowMemoryMode) {
        if (stage.stageSprites.exists("fog_back")) sceneObjects.push(stage.stageSprites.get("fog_back"));
        if (stage.stageSprites.exists("bg_fog")) sceneObjects.push(stage.stageSprites.get("bg_fog"));
        if (stage.stageSprites.exists("fog_above")) sceneObjects.push(stage.stageSprites.get("fog_above"));
        if (stage.stageSprites.exists("custardGlow")) sceneObjects.push(stage.stageSprites.get("custardGlow"));
    }

    var shaderBruh = new CustomShader('adjustColor');
    shaderBruh.brightness = 0;
    shaderBruh.hue = 0;
    shaderBruh.saturation = -60;
    shaderBruh.contrast = 0;
    camGame.addShader(shaderBruh); 
}

function setupWarningMenu() {
    warningActive = true;
    FlxG.timeScale = 0.0001; 
    
    camWarning = new FlxCamera();
    camWarning.bgColor = 0x00000000;
    FlxG.cameras.add(camWarning, false);

    warningBg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xDD000000); 
    warningBg.cameras = [camWarning];
    warningBg.screenCenter();
    add(warningBg);

    warningText = new FlxText(0, 100, FlxG.width, "!! Content Warning !!\n\nThis song contains a very graphic asset.\nWould you like to turn on censored mode?\n\nYou can revert these changes in the options menu.", 32);
    warningText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, "center");
    warningText.cameras = [camWarning];
    warningText.screenCenter(FlxAxes.X);
    add(warningText);

    optionYes = new FlxText(FlxG.width / 2 - 200, 500, 0, "YES", 48);
    optionNo = new FlxText(FlxG.width / 2 + 100, 500, 0, "NO", 48);

    for (opt in [optionYes, optionNo]) {
        opt.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, "center");
        opt.cameras = [camWarning];
        add(opt);
    }

    // 初始化状态
    #if mobile
    keyboardSelectionEnabled = false;  // 手机端默认无键盘选中
    #else
    keyboardSelectionEnabled = true;   // 电脑端默认键盘选中 YES
    selectedOption = 0;
    #end
    pressedButton = -1;
    hoverButton = -1;
    updateButtonColors();
}

function updateButtonColors() {
    // 如果有鼠标/手指按下，两个按钮都是白色（不显示任何高亮）
    if (pressedButton != -1) {
        optionYes.color = FlxColor.WHITE;
        optionNo.color = FlxColor.WHITE;
        return;
    }
    // 悬浮优先：如果悬浮在某个按钮上，该按钮黄色，另一按钮根据键盘选中状态显示
    if (hoverButton != -1) {
        if (hoverButton == 0) {
            optionYes.color = FlxColor.YELLOW;
            optionNo.color = keyboardSelectionEnabled ? (selectedOption == 1 ? FlxColor.YELLOW : FlxColor.WHITE) : FlxColor.WHITE;
        } else {
            optionNo.color = FlxColor.YELLOW;
            optionYes.color = keyboardSelectionEnabled ? (selectedOption == 0 ? FlxColor.YELLOW : FlxColor.WHITE) : FlxColor.WHITE;
        }
        return;
    }
    // 正常状态：根据键盘选中显示高亮
    if (keyboardSelectionEnabled) {
        optionYes.color = (selectedOption == 0) ? FlxColor.YELLOW : FlxColor.WHITE;
        optionNo.color = (selectedOption == 1) ? FlxColor.YELLOW : FlxColor.WHITE;
    } else {
        optionYes.color = FlxColor.WHITE;
        optionNo.color = FlxColor.WHITE;
    }
}

function applyCensor(isCensored:Bool) {
    po.visible = !isCensored;
    po_alt.visible = isCensored;
    poeyes_alt.visible = isCensored;
    poeyes.visible = !isCensored;
    tree.visible = !isCensored;
    treealt.visible = isCensored;
}

function confirmWarning(choice:Int) {
    warningActive = false;
    FlxG.timeScale = 1;

    var censorVal:Bool = (choice == 0);
    FlxG.save.data.censorPoCustard = censorVal;
    Options.censorPoCustard = censorVal;
    currentCensor = censorVal;
    
    FlxG.save.flush();
    applyCensor(censorVal);
    
    warningBg.destroy();
    warningText.destroy();
    optionYes.destroy();
    optionNo.destroy();
    FlxG.cameras.remove(camWarning);
    
    if (inst != null) inst.play();
    if (vocals != null) vocals.play();
    PlayState.instance.startCountdown();
}

function update(elapsed:Float) {
    if (!warningActive) {
        return;
    }

    Conductor.songPosition = -1000; 
    if (inst != null && inst.playing) inst.pause();
    if (vocals != null && vocals.playing) vocals.pause();

    // ----------------- 使用摄像机坐标转换获取鼠标位置 -----------------
    var mousePos = FlxG.mouse.getWorldPosition(camWarning);
    var mouseX = mousePos.x;
    var mouseY = mousePos.y;

    var overYes:Bool = (optionYes.visible && mouseX >= optionYes.x && mouseX <= optionYes.x + optionYes.width &&
                        mouseY >= optionYes.y && mouseY <= optionYes.y + optionYes.height);
    var overNo:Bool = (optionNo.visible && mouseX >= optionNo.x && mouseX <= optionNo.x + optionNo.width &&
                       mouseY >= optionNo.y && mouseY <= optionNo.y + optionNo.height);

    // ----- 鼠标/触摸按下 -----
    if (FlxG.mouse.justPressed) {
        if (overYes) {
            pressedButton = 0;
        } else if (overNo) {
            pressedButton = 1;
        } else {
            pressedButton = -1;
        }
        if (pressedButton != -1) {
            // 按下时禁用键盘选中状态，并强制两个按钮变白
            keyboardSelectionEnabled = false;
            updateButtonColors();
        }
    }

    // ----- 鼠标/触摸移动（检测是否移出按钮）-----
    if (pressedButton != -1 && FlxG.mouse.pressed) {
        var stillOver = (pressedButton == 0 && overYes) || (pressedButton == 1 && overNo);
        if (!stillOver) {
            // 移出按钮区域，取消按下状态
            pressedButton = -1;
            updateButtonColors();
        }
    }

    // ----- 鼠标/触摸释放 -----
    if (FlxG.mouse.justReleased && pressedButton != -1) {
        confirmWarning(pressedButton);
        pressedButton = -1;
        return;
    }

    // ----- 悬浮检测（仅在未按下时生效）-----
    if (pressedButton == -1) {
        var newHover = -1;
        if (overYes) newHover = 0;
        else if (overNo) newHover = 1;
        if (newHover != hoverButton) {
            hoverButton = newHover;
            updateButtonColors();
        }
    } else {
        if (hoverButton != -1) {
            hoverButton = -1;
            updateButtonColors();
        }
    }

    // ----- 键盘左右方向键（统一处理）-----
    if (controls.LEFT_P || controls.RIGHT_P) {
        if (!keyboardSelectionEnabled) {
            keyboardSelectionEnabled = true;
            // 如果此前没有选中过，默认选中 YES
            selectedOption = 0;
        } else {
            selectedOption = (selectedOption == 0) ? 1 : 0;
        }
        updateButtonColors();
    }

    // ----- 回车确认（统一处理）-----
    if (controls.ACCEPT) {
        var finalChoice = keyboardSelectionEnabled ? selectedOption : 0;
        confirmWarning(finalChoice);
    }
}

function onStartSong() {
    camGame.fade(FlxColor.BLACK, 6, true);
    FlxTween.tween(FlxG.camera, {zoom: 0.5}, 6, {ease: FlxEase.quadInOut});
    allowCameraMoving = true;
    instantCamMove = true;
    camZooming = false;
}

function onStartCountdown() {
    var savedCensor = FlxG.save.data.censorPoCustard;
    currentCensor = (savedCensor != null) ? savedCensor : Options.censorPoCustard;
 
    // 从未设置过，则强制弹出警告
    if (savedCensor == null) {
        setupWarningMenu();
    } else {
        applyCensor(currentCensor);
    }
}

function stepHit(curStep:Int) {
    switch (curStep) {
        case 76:
            defaultCamZoom = 0.5;
            blackBarThingie.alpha = 1;
        case 80:
            blackBarThingie.alpha = 0;
            whiteFlash.alpha = 0.8;
            camHUD.visible = true;
            FlxTween.tween(whiteFlash, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
        case 207:
            defaultCamZoom = 0.7;
            allowCameraMoving = true;
            instantCamMove = false;
        case 326:
            FlxTween.tween(blackBarThingiegame, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut});
            FlxTween.tween(camHUD, {alpha: 0}, 1);   
        case 345:
            for (obj in sceneObjects) obj.visible = false;
            camGame.zoom = 0.6;
             FlxTween.tween(blackBarThingiegame, {alpha: 0}, 4, {ease: FlxEase.quadInOut});
            FlxTween.tween(camGame, {zoom: 0.7}, 5, {ease: FlxEase.sineOut});
            tinky.visible = true;
            tinky.playAnim("scream", true);
            camHUD.visible = false;
        case 400:
        whiteFlash.alpha = 0.8;
        FlxTween.tween(whiteFlash, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
        camHUD.visible = true;
        camHUD.alpha = 1;
        for (obj in sceneObjects) {
            if (obj != po && obj != po_alt && obj != tree && obj != treealt && obj != poeyes && obj != poeyes_alt) {
                obj.visible = true;
            }
        }
        tinky.visible = false;
        
    camZoomingInterval = 4;
    applyCensor(currentCensor);
        case 528 | 1040 | 1632 | 1824 | 2208:
            camZoomingInterval = 2;
        case 784 | 1568 | 1664 | 1952 | 2272:
            camZoomingInterval = 1;
        case 1041 | 2080 | 2321:
            defaultCamZoom = 0.8;
            camZoomingInterval = 8;
            FlxTween.tween(barTop, {y: -FlxG.height + 85}, 0.4, {ease: FlxEase.quadInOut});
            FlxTween.tween(barBottom, {y: FlxG.height - 85}, 0.4, {ease: FlxEase.quadInOut});
            for (i in 0...4) {
                FlxTween.tween(cpu.members[i], {y: 90}, 0.4);
                FlxTween.tween(player.members[i], {y: 90}, 0.4);
            }
        case 1296:
            defaultCamZoom = 0.7;
            camZoomingInterval = 2;
            whiteFlash.alpha = 0.8;
            FlxTween.tween(whiteFlash, {alpha: 0}, 1);
            FlxTween.tween(barTop, {y: -FlxG.height}, 0.3, {ease: FlxEase.quadInOut});
            FlxTween.tween(barBottom, {y: FlxG.height}, 0.3, {ease: FlxEase.quadInOut});
            for (i in 0...4) {
                FlxTween.tween(cpu.members[i], {y: 50}, 0.4);
                FlxTween.tween(player.members[i], {y: 50}, 0.4);
            }
            FlxTween.tween(tinkyFB, { x: 700 }, 10, { ease: FlxEase.linear, type: FlxTween.ONESHOT });
            FlxTween.tween(tinkyFB, { alpha: 0.5 }, 3, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
        case 1360:
            FlxTween.tween(tinkyFB, { alpha: 0 }, 2, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
            FlxTween.tween(laalaaFB, { x: -1000 }, 10, { ease: FlxEase.linear, type: FlxTween.ONESHOT });
            FlxTween.tween(laalaaFB, { alpha: 0.5 }, 2, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
        case 1424:
            camZoomingInterval = 1;
            FlxTween.tween(laalaaFB, { alpha: 0 }, 2, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
            FlxTween.tween(dipsyFB, { x: 1000 }, 10, { ease: FlxEase.linear, type: FlxTween.ONESHOT });
            FlxTween.tween(dipsyFB, { alpha: 0.5 }, 2, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
        case 1488:
            FlxTween.tween(dipsyFB, { alpha: 0 }, 2, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
            FlxTween.tween(poFB, { alpha: 0.5 }, 1, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
            FlxTween.tween(poFB, { x: -1000 }, 10, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
        case 1552:
            camZoomingInterval = 4;
            FlxTween.tween(poFB, { alpha: 0 }, 1, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT });
        case 1556 | 1944:
            defaultCamZoom = 0.9;
            FlxG.camera.shake(0.005, 1);
            new FlxTimer().start(1, tmr -> { defaultCamZoom = 0.7; });
        case 2335:
            whiteFlash.alpha = 1;
        case 2336:
            ending.bitmap.onFormatSetup.add(() -> { ending.alpha = 1; });
           var videoName:String = currentCensor ? "Custard Ending Censored" : "Custard Ending";
            if (FlxG.save.data.censorPoCustard) {
                videoName = "Custard Ending Censored";
            }
            ending.load(Assets.getPath(Paths.video(videoName)));
            insert(members.indexOf(dad) + 25, ending);
            ending.scale.set(0.69, 0.69);
            ending.cameras = [camHUD];
            ending.antialiasing = Options.antialiasing;
            ending.play();
            whiteFlash.cameras = [camHUD];
            FlxTween.tween(whiteFlash, {alpha: 0}, 2, {ease: FlxEase.quadInOut});
            blackBarThingie.alpha = 0;
    }
}