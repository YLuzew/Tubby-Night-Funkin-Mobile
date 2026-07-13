import flixel.addons.display.FlxBackdrop;
import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;
import flixel.text.FlxTextBorderStyle;
import funkin.options.OptionsMenu;
import openfl.ui.Mouse;
import funkin.menus.credits.CreditsMain;
import funkin.savedata.FunkinSave;

var codenameVersion = Application.current.meta.get('version');
var optionShit:Array<String> = ['storymode', 'freeplay', "options", "credits"];
var menuItems:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var camZoom:FlxTween;
var usingMouse:Bool = true;
var confirm:FlxSound;
var locked:FlxSound;
var cancel:FlxSound;
var hover:FlxSound;
var unlocked:FlxSound;
var curSelected:Int = 0;

var freeplayUnlocked:Bool = false;
var isUnlockingRightNow:Bool = false;
var freeplayShake:Float = 0;
var freeplaySprite:FunkinSprite;
var lockSprite:FlxSprite;

var lastHovered:Int = -1;
var selectedSomethin:Bool = false;

var tabText:FunkinText;
var versionShit:FunkinText;
var regenVer:FunkinText;
var sky:FlxSprite;
var behindgrass:FlxSprite;
var grass:FlxSprite;
var overlayinside:FlxSprite;
var background:FlxSprite;
var overlay:FlxSprite;
var overlay_tv:FlxSprite;
var fog:FlxSprite;

// Back 按钮
var backButton:FunkinText;

// ----- 松开触发变量 -----
var pendingAccept:Bool = false;
var pendingBack:Bool = false;
var pendingMouseSelection:Null<Int> = null;

function create() {
    var checkWeekBeaten = function(weekName:String):Bool {
        var scoreE = FunkinSave.getWeekHighscore(weekName, 'easy').score;
        var scoreN = FunkinSave.getWeekHighscore(weekName, 'normal').score;
        var scoreH = FunkinSave.getWeekHighscore(weekName, 'hard').score;
        return (scoreE > 0 || scoreN > 0 || scoreH > 0);
    };

    // 修改点：任意一个周目有分数即解锁
    var anyWeekBeaten:Bool = (checkWeekBeaten('po') || checkWeekBeaten('tinky') || checkWeekBeaten('laa-laa-dipsy'));

    if (anyWeekBeaten) {
        freeplayUnlocked = true;
    } else {
        freeplayUnlocked = false;
        if (FlxG.save.data.hasSeenFreeplayUnlock == true) {
            FlxG.save.data.hasSeenFreeplayUnlock = false;
            FlxG.save.flush();
        }
    }

    if (FlxG.save.data.hasSeenFreeplayUnlock == null) {
        FlxG.save.data.hasSeenFreeplayUnlock = false;
    }

    if (freeplayUnlocked && FlxG.save.data.hasSeenFreeplayUnlock == false) {
        isUnlockingRightNow = true;
    }

    CoolUtil.playMenuSong();
    
    confirm = FlxG.sound.load(Paths.sound('menu/confirm'));
    cancel = FlxG.sound.load(Paths.sound('menu/cancel'));
    locked = FlxG.sound.load(Paths.sound('menu/locked'));
    hover = FlxG.sound.load(Paths.sound('menu/scroll'));
    unlocked = FlxG.sound.load(Paths.sound('menu/cheer unlocked'));

    sky = new FlxSprite(200, 0).loadGraphic(Paths.image('menus/main/sky'));
    sky.antialiasing = Options.antialiasing;
    add(sky);
    sky.scale.set(1, 1);
    sky.scrollFactor.set(0, 0);

    FlxG.mouse.enabled = true;
    FlxG.mouse.useSystemCursor = false;

    tabText = new FunkinText(1050, FlxG.height, 0, '打开模组菜单 [TAB]');
    tabText.y -= tabText.height + 50;
    add(tabText);

    versionShit = new FunkinText(1040, FlxG.height, 0, 'Codename Engine - v.' + codenameVersion);
    versionShit.y -= versionShit.height + 70;
    add(versionShit);

    regenVer = new FunkinText(1007, FlxG.height, 0, '天线夜放克 - 版本 V1');
    regenVer.y -= regenVer.height + 90;
    add(regenVer);

    behindgrass = new FlxSprite(150, 320).loadGraphic(Paths.image('menus/main/behindgrass'));
    behindgrass.antialiasing = Options.antialiasing;
    add(behindgrass);
    behindgrass.scale.set(0.6, 0.6);
    behindgrass.scrollFactor.set(0.6, 0.6);
    behindgrass.frames = Paths.getSparrowAtlas('menus/main/behindgrass');
    behindgrass.animation.addByPrefix('bump', 'Occurrence hill-outback 10', 24, true);
    behindgrass.animation.play('bump');

    grass = new FlxSprite(-20, 0).loadGraphic(Paths.image('menus/main/grass'));
    grass.antialiasing = Options.antialiasing;
    add(grass);
    grass.scale.set(0.6, 0.6);
    grass.scrollFactor.set(0.8, 0.8);
    grass.frames = Paths.getSparrowAtlas('menus/main/grass');
    grass.animation.addByPrefix('bump', 'Occurrence background 10', 24, true);
    grass.animation.play('bump');

    for (i in 0...optionShit.length) {
        var menuItem:FunkinSprite = new FunkinSprite(0, 130);
        menuItem.frames = Paths.getSparrowAtlas('menus/main/menuButtons');
        menuItem.animation.addByPrefix('idle', optionShit[i] + 'basic', 24, true);
        menuItem.animation.addByPrefix('hover', optionShit[i] + 'white', 24, true);
        menuItem.ID = i;
        menuItems.add(menuItem);
        menuItem.scale.set(0.7, 0.7);
        menuItem.scrollFactor.set(0.9, 0.9);
        menuItem.updateHitbox();
        menuItem.antialiasing = Options.antialiasing;

        if (optionShit[i] == "freeplay") {
            freeplaySprite = menuItem;
            if (!freeplayUnlocked || isUnlockingRightNow) {
                menuItem.color = 0xFF555555;
            }
        }

        switch (optionShit[i]) {
            case "storymode":
                menuItem.setPosition(385, 255);
            case "freeplay":
                menuItem.setPosition(355, 355);
            case "options":
                menuItem.setPosition(625, 425);
            case "credits":
                menuItem.setPosition(500, 505);
        }
    }

    add(menuItems);

    if ((!freeplayUnlocked || isUnlockingRightNow) && freeplaySprite != null) {
        lockSprite = new FlxSprite().loadGraphic(Paths.image('menus/main/lock')); 
        lockSprite.antialiasing = Options.antialiasing;
        lockSprite.scale.set(0.8, 0.8); 
        lockSprite.updateHitbox();
        lockSprite.x = freeplaySprite.x + (freeplaySprite.width / 2 + 20) - (lockSprite.width / 2);
        lockSprite.y = freeplaySprite.y + (freeplaySprite.height / 2) - (lockSprite.height / 2);
        lockSprite.scrollFactor.set(0.9, 0.9);
        add(lockSprite);
    }

    overlayinside = new FlxSprite(100, 0).loadGraphic(Paths.image('menus/main/inside'));
    overlayinside.antialiasing = Options.antialiasing;
    add(overlayinside);
    overlayinside.scale.set(0.65, 0.65);
    overlayinside.blend = 0;
    overlayinside.alpha = 0.5;

    background = new FlxSprite(-550, -480).loadGraphic(Paths.image('menus/main/screen'));
    background.antialiasing = Options.antialiasing;
    add(background);
    background.scale.set(0.65, 0.65);
    background.scrollFactor.set(1, 1);
    background.frames = Paths.getSparrowAtlas('menus/main/screen');
    background.animation.addByPrefix('bump', 'Occurrence tv 10', 24, true);
    background.animation.play('bump');

    overlay = new FlxSprite(200, 0).loadGraphic(Paths.image('menus/main/overlay'));
    overlay.antialiasing = Options.antialiasing;
    add(overlay);
    overlay.scale.set(0.62, 0.62);
    overlay.blend = 0;

    overlay = new FlxSprite(200, 0).loadGraphic(Paths.image('menus/main/overlay'));
    overlay.antialiasing = Options.antialiasing;
    add(overlay);
    overlay.scale.set(0.65, 0.65);
    overlay.blend = 0;

    overlay_tv = new FlxSprite(20, -200).loadGraphic(Paths.image('menus/main/overlay tv'));
    overlay_tv.antialiasing = Options.antialiasing;
    add(overlay_tv);
    overlay_tv.scale.set(0.65, 0.65);
    overlay_tv.blend = 0;

    fog = new FlxSprite(-600, -500).loadGraphic(Paths.image('menus/main/fog'));
    fog.antialiasing = Options.antialiasing;
    add(fog);
    fog.scale.set(0.65, 0.65);
    fog.blend = 14;

    updateItems();

    // Back 按钮
    backButton = new FunkinText(20, FlxG.height - 120, 0, "返回", 64);
    backButton.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 64, FlxColor.WHITE, "left");
    backButton.scrollFactor.set(0, 0);
    backButton.antialiasing = Options.antialiasing;
    backButton.borderStyle = FlxTextBorderStyle.NONE;
    add(backButton);

    if (isUnlockingRightNow) {
        FlxG.save.data.hasSeenFreeplayUnlock = true;
        FlxG.save.flush();

        var unlockedOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/main/unlocked overlay'));
        unlockedOverlay.scrollFactor.set(0, 0);
        unlockedOverlay.blend = 0;
        unlockedOverlay.alpha = 0;
        unlockedOverlay.screenCenter();
        add(unlockedOverlay);

        FlxTween.tween(unlockedOverlay, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});

        var unlockAnim = new FlxSprite(-280, -230);
        unlockAnim.frames = Paths.getSparrowAtlas('menus/main/unlocked freeplay');
        unlockAnim.animation.addByPrefix('appear', 'unlocked freeplay', 24, false);
        unlockAnim.animation.addByPrefix('loop', 'unlocked loop0', 24, true);
        unlockAnim.antialiasing = Options.antialiasing;
        unlockAnim.scale.set(0.8, 0.8);
        unlockAnim.scrollFactor.set(0, 0);
        add(unlockAnim);
        unlocked.play(true);
        
        unlockAnim.animation.play('appear');
        
        unlockAnim.animation.finishCallback = function(name:String) {
            if (name == 'appear') {
                unlockAnim.animation.play('loop');
                unlockAnim.x += 345;
                unlockAnim.y += 220;
                freeplaySprite.color = 0xFFFFFFFF;
                if (lockSprite != null) {
                    FlxTween.tween(lockSprite, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.5, {
                        ease: FlxEase.cubeOut,
                        onComplete: function(twn:FlxTween) {
                            lockSprite.destroy();
                            lockSprite = null;
                        }
                    });
                }

                new FlxTimer().start(2.5, function(tmr:FlxTimer) {
                    isUnlockingRightNow = false;
                    FlxTween.tween(unlockAnim, {alpha: 0}, 1, {
                        onComplete: function(twn:FlxTween) {
                            unlockAnim.destroy();
                        }
                    });
                    FlxTween.tween(unlockedOverlay, {alpha: 0}, 1, {
                        onComplete: function(twn:FlxTween) {
                            unlockedOverlay.destroy();
                        }
                    });
                });
            }
        };
    }
}

function update(elapsed:Float) {
    if (FlxG.sound.music != null) FlxG.sound.music.pitch = FlxMath.lerp(FlxG.sound.music.pitch, 1, elapsed * 0.8);
    FlxG.sound.music.volume = 0.5;

    // 锁定抖动效果
    if (freeplayShake > 0) {
        freeplayShake -= elapsed;
        if (freeplaySprite != null) freeplaySprite.offset.set(FlxG.random.float(-8, 8), FlxG.random.float(-8, 8));
        if (lockSprite != null) {
            lockSprite.angle = FlxG.random.float(-15, 15);
            lockSprite.offset.set(FlxG.random.float(-8, 8), FlxG.random.float(-8, 8));
        }
    } else {
        if (freeplaySprite != null) freeplaySprite.offset.set(0, 0);
        if (lockSprite != null) {
            lockSprite.angle = 0;
            lockSprite.offset.set(0, 0);
        }
    }

    // TAB 菜单（无需松开，直接打开）
    if (controls.SWITCHMOD) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = !(persistentDraw = true);
    }

    // 如果正在解锁动画或已经选中，禁止任何输入
    if (isUnlockingRightNow || selectedSomethin) {
        updateCameraScroll(elapsed);
        return;
    }

    // ==================== 一、处理返回（松开触发） ====================
    if (FlxG.keys.justPressed.ESCAPE && !pendingBack) {
        pendingBack = true;
    }

    var mouseOverBack = FlxG.mouse.overlaps(backButton);
    if (FlxG.mouse.justPressed && mouseOverBack && !pendingBack) {
        pendingBack = true;
    }

    if (pendingBack) {
        var shouldGoBack = false;
        if (FlxG.keys.justReleased.ESCAPE) shouldGoBack = true;
        if (FlxG.mouse.justReleasedRight) shouldGoBack = true;
        if (FlxG.mouse.justReleased && mouseOverBack) shouldGoBack = true;

        if (shouldGoBack) {
            pendingBack = false;
            performGoBack();
            return;
        }
        if (!mouseOverBack && FlxG.mouse.pressed && pendingBack) {
            pendingBack = false;
        }
    }

    if (mouseOverBack) {
        backButton.color = 0xFF00BFFF;
        backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        backButton.borderColor = FlxColor.BLACK;
        backButton.borderSize = 2;
    } else {
        backButton.color = FlxColor.WHITE;
        backButton.borderStyle = FlxTextBorderStyle.NONE;
    }

    // ==================== 二、鼠标移动与悬浮（实时） ====================
    if (FlxG.mouse.justMoved) usingMouse = true;

    if (usingMouse) {
        var hoveredIndex:Int = -1;
        for (item in menuItems.members) {
            if (FlxG.mouse.overlaps(item)) {
                hoveredIndex = item.ID;
                if (FlxG.mouse.justPressed && !pendingAccept) {
                    pendingAccept = true;
                    pendingMouseSelection = hoveredIndex;
                }
                break;
            }
        }
        if (hoveredIndex != -1 && hoveredIndex != lastHovered) {
            curSelected = hoveredIndex;
            updateItems();
            CoolUtil.playMenuSFX();
            lastHovered = hoveredIndex;
        }
    }

    var change = (controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0);
    if (change != 0) {
        usingMouse = false;
        curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
        updateItems();
        CoolUtil.playMenuSFX();
    }

    if (controls.ACCEPT && !pendingAccept) {
        pendingAccept = true;
        pendingMouseSelection = null;
    }

    if (pendingAccept && (!controls.ACCEPT && !FlxG.mouse.pressed)) {
        var selectedIndex = (pendingMouseSelection != null && usingMouse) ? pendingMouseSelection : curSelected;
        pendingAccept = false;
        pendingMouseSelection = null;

        var option = optionShit[selectedIndex];
        if (option == "freeplay" && (!freeplayUnlocked || isUnlockingRightNow)) {
            locked.play();
            freeplayShake = 0.1;
            return;
        }

        selectedSomethin = true;
        confirm.play();
        if (Options.flashingMenu) FlxG.camera.fade(FlxColor.WHITE, 0.5, true);
        FlxG.camera.zoom = 1.1;
        FlxTween.tween(FlxG.camera, {zoom: 1}, 2, {ease: FlxEase.expoOut});

        new FlxTimer().start(0.6, function(tmr:FlxTimer) {
            switchStateByIndex(selectedIndex);
        });
        return;
    }

    updateCameraScroll(elapsed);
}

function performGoBack() {
    cancel.play();
    FlxTween.tween(FlxG.camera, {zoom: 1.2}, 2, {ease: FlxEase.expoOut});
    FlxG.camera.fade(FlxColor.BLACK, 0.5, false);
    new FlxTimer().start(0.75, function(tmr:FlxTimer) {
        FlxG.switchState(new TitleState());
    });
}

function updateCameraScroll(elapsed:Float) {
    camera.scroll.x = lerp(camera.scroll.x, (FlxG.mouse.x / FlxG.width) * 40 - 25, 0.04);
    camera.scroll.y = lerp(camera.scroll.y, (FlxG.mouse.y / FlxG.height) * 40 - 25, 0.04);
}

function switchStateByIndex(index:Int) {
    var daChoice = optionShit[index];
    switch (daChoice) {
        case 'storymode': FlxG.switchState(new StoryMenuState());
        case 'freeplay': FlxG.switchState(new ModState('TNF/FreeplayState'));
        case 'options': FlxG.switchState(new OptionsMenu());
        case 'credits': FlxG.switchState(new ModState('TNF/CreditState'));
    }
}

function updateItems() {
    menuItems.forEach(function(spr:FunkinSprite) {
        spr.animation.play(spr.ID == curSelected ? 'hover' : 'idle');
    });
}