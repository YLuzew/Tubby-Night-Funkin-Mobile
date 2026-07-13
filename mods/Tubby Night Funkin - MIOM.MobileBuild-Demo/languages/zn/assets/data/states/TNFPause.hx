import funkin.options.OptionsMenu;
import funkin.options.TreeMenu;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import HealthIcon;

var options:Array<String> = ["继续", "重来", "设置", "退出"];
var cards:Array<Dynamic> = [];
var curSelected:Int = 0;
var pauseCam:FlxCamera;
var canPress:Bool = false;
var isAnimatingOut:Bool = false;
var isIntroAnimating:Bool = true;

// 背景元素
var menuDesat:FlxSprite;
var tilesThing:FlxBackdrop;
var glowyThing:FlxSprite;
var blacktop:FlxSprite;
var blackbottom:FlxSprite;
var cutbox:FlxSprite;
var characterImage:FlxSprite;
var characterImage2:FlxSprite;          // ADDED 第二个角色图片
var disk:FlxSprite;
var songIcon:HealthIcon;
var currentSongColor:FlxColor = 0xFFFFFFFF;

// ========== 可调节的唱片目标位置 ==========
var diskTargetX:Float = -120;
var diskTargetY:Float = FlxG.height -240;

var diskOffset:Float = 280;
var diskEnterStartX:Float;
var diskEnterStartY:Float;
var diskEnterTargetX:Float;
var diskEnterTargetY:Float;
var diskExitStartX:Float;
var diskExitStartY:Float;
var diskExitTargetX:Float;
var diskExitTargetY:Float;

var iconOffsetX:Float = 10;
var iconOffsetY:Float = 15;

var isDragging:Bool = false;
var dragStartY:Float = 0;
var dragAccumulated:Float = 0;
var dragLastY:Float = 0;
var dragStepThreshold:Float = 100;
var dragTotalDelta:Float = 0;

var songNameText:FlxText;
var composerText:FlxText;
var difficultyText:FlxText;

var countdownTexts:Array<FlxText> = [];
var countdownIndex:Int = 0;
var isCountingDown:Bool = false;
var countdownTimer:FlxTimer;

var characterMap:Map<String, Dynamic> = [
    "chill bill"    => { image: "tinkywinky-portrait", x: 640, y: -40 },
    "simulation"    => { image: "tinkywinky-portrait", x: 640, y: -40 },
    "farewell"      => { image: "tinkywinky-portrait", x: 640, y: -40 },
    "optimistic"    => { image: "laalaa-portrait", x: 600, y: -40 },
    "dipstick"      => { image: "dipsy-portrait", x: 600, y: -40 },
    "custa starz"   => { image: "laalaa-portrait", x: 720, y: -40, image2: "dipsy-portrait", x2: 550, y2: -40 },
    // 示例：为 "imagine 2" 添加双图（请根据实际歌曲名和图片名修改）
    // "imagine 2"    => { image: "first-portrait", x: 600, y: -40, image2: "second-portrait", x2: 700, y2: -40 },
    "lighthearted"  => { image: "po-portrait", x: 600, y: -40 },
    "radiant"       => { image: "po-portrait", x: 600, y: -40 },
    "energetic"     => { image: "po-portrait", x: 600, y: -40 },
    "george"        => { image: "george-portrait", x: 620, y: -40 },
    "unhinged"      => { image: "dinkywinky-portrait", x: 650, y: -40 },
    "gifted"        => { image: "newborn-portrait", x: 600, y: -40 },
    "custard"       => { image: "custard-portrait", x: 620, y: -40 },
    "sensed"        => { image: "sensed-portrait", x: 650, y: -70 },
    "carnage"       => { image: "carnage-portrait", x: 670, y: -40 },
    "rabbits blood" => { image: "zalgo-portrait", x: 600, y: -40 },
    "bad dreams"    => { image: "bad-dreams-portrait", x: 628, y: -40 }
];

function create(event) {
    event.cancel();
    cameras = [];
    #if mobile	
        removeTouchPad();
    #end

    pauseCam = new FlxCamera();
    pauseCam.bgColor = 0x00000000;
    pauseCam.alpha = 0;
    FlxG.cameras.add(pauseCam, false);
    FlxTween.tween(pauseCam, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    cameras = [pauseCam];

    createBackground();
    createOptionCards();
    createSongInfoTexts();

    disk = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/disk'));
    disk.antialiasing = Options.antialiasing;
    add(disk);

    var finalTargetY:Float;
    if (diskTargetY >= 0) {
        finalTargetY = diskTargetY;
    } else {
        var leftMargin = -diskTargetX;
        finalTargetY = FlxG.height - disk.height - leftMargin;
    }

    diskEnterTargetX = diskTargetX;
    diskEnterTargetY = finalTargetY;
    diskEnterStartX = diskTargetX - diskOffset;
    diskEnterStartY = finalTargetY + diskOffset;

    diskExitStartX = diskTargetX;
    diskExitStartY = finalTargetY;
    diskExitTargetX = diskTargetX - diskOffset;
    diskExitTargetY = finalTargetY + diskOffset;

    disk.x = diskEnterStartX;
    disk.y = diskEnterStartY;

    var iconName = "face";
    if (PlayState.SONG != null && PlayState.SONG.meta != null && PlayState.SONG.meta.icon != null) {
        iconName = PlayState.SONG.meta.icon;
    }
    songIcon = new HealthIcon(iconName);
    songIcon.scale.set(0.9, 0.9);
    songIcon.antialiasing = Options.antialiasing;
    songIcon.origin.set(songIcon.width / 2, songIcon.height / 2);
    add(songIcon);

    var numbers = ["3", "2", "1"];
    for (i in 0...numbers.length) {
        var txt = new FlxText(0, 0, 0, numbers[i], 120);
        txt.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 120, FlxColor.WHITE, "center");
        txt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4);
        txt.antialiasing = Options.antialiasing;
        txt.screenCenter();
        txt.visible = false;
        txt.alpha = 0;
        add(txt);
        countdownTexts.push(txt);
    }

    updateSelection();
    playIntroAnimation();
}

function createBackground() {
    menuDesat = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menuDesat'));
    menuDesat.screenCenter();
    menuDesat.scale.set(1.1, 1.1);
    menuDesat.antialiasing = Options.antialiasing;
    menuDesat.color = 0xFF222222;
    menuDesat.alpha = 0;
    add(menuDesat);

    tilesThing = new FlxBackdrop(Paths.image('menus/checker'));
    tilesThing.antialiasing = Options.antialiasing;
    tilesThing.scrollFactor.set(0.2, 0.2);
    tilesThing.velocity.set(50, 50);
    tilesThing.alpha = 0;
    tilesThing.scale.set(0.7, 0.7);
    tilesThing.updateHitbox();
    add(tilesThing);

    glowyThing = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/glowy'));
    glowyThing.alpha = 0;
    glowyThing.updateHitbox();
    glowyThing.screenCenter(FlxAxes.XY);
    glowyThing.blend = 0;
    glowyThing.antialiasing = Options.antialiasing;
    add(glowyThing);

    blacktop = new FlxSprite(-10, -150).makeSolid(1320, 200, FlxColor.BLACK);
    blacktop.antialiasing = Options.antialiasing;
    blacktop.angle = 2;
    blacktop.y = -150;
    add(blacktop);

    characterImage = new FlxSprite(0, 0);
    characterImage.antialiasing = Options.antialiasing;
    characterImage.visible = false;
    characterImage.scale.set(1, 1);
    add(characterImage);

    // ADDED 第二个角色图片
    characterImage2 = new FlxSprite(0, 0);
    characterImage2.antialiasing = Options.antialiasing;
    characterImage2.visible = false;
    characterImage2.scale.set(1, 1);
    add(characterImage2);

    blackbottom = new FlxSprite(-10, FlxG.height + 100).makeSolid(1320, 150, FlxColor.BLACK);
    blackbottom.antialiasing = Options.antialiasing;
    blackbottom.angle = 2;
    blackbottom.y = FlxG.height + 100;
    add(blackbottom);

    cutbox = new FlxSprite(1400, 250).loadGraphic(Paths.image('menus/freeplay/black-cut-box-right'));
    cutbox.antialiasing = Options.antialiasing;
    cutbox.scale.set(0.4, 0.4);
    cutbox.x = 1400;
    add(cutbox);
}

function createOptionCards() {
    var meta = PlayState.SONG?.meta;
    currentSongColor = (meta != null && meta.color != null) ? meta.color : FlxColor.WHITE;

    var startX = -800;
    var startTextX = -770;

    for (i in 0...options.length) {
        var card = new FlxSprite(250, 0).loadGraphic(Paths.image('menus/freeplay/songPanel'));
        card.antialiasing = Options.antialiasing;
        card.x = startX;
        add(card);

        var txt = new FlxText(0, 0, 550, options[i].charAt(0).toUpperCase() + options[i].substr(1), 75);
        txt.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 75, FlxColor.WHITE, "center");
        txt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
        txt.antialiasing = Options.antialiasing;
        txt.x = startTextX;
        add(txt);

        cards.push({ card: card, text: txt });
    }

    var ch = FlxG.height * 0.40;
    for (i in 0...cards.length) {
        var item = cards[i];
        var ty = i - curSelected;
        var targetY = ty * 170 + ch;
        item.card.setPosition(startX, targetY);
        item.text.setPosition(startTextX, targetY + 40 + 10);
    }
}

function createSongInfoTexts() {
    var songName = "未知 歌曲名";
    var songArtist = "未知 作曲";
    
    if (PlayState.SONG != null && PlayState.SONG.meta != null) {
        if (PlayState.SONG.meta.displayName != null && PlayState.SONG.meta.displayName != "")
            songName = PlayState.SONG.meta.displayName;
        else if (PlayState.SONG.meta.name != null)
            songName = PlayState.SONG.meta.name;
        if (PlayState.SONG.meta.artists != null && PlayState.SONG.meta.artists != "")
            songArtist = PlayState.SONG.meta.artists;
    }
    
    songNameText = new FlxText(0, 20, 0, songName, 36);
    songNameText.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 36, FlxColor.WHITE, "left");
    songNameText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    songNameText.antialiasing = Options.antialiasing;
    songNameText.alpha = 0;
    add(songNameText);
    
    composerText = new FlxText(0, songNameText.y + songNameText.height, 0, "Composer: " + songArtist, 28);
    composerText.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 28, FlxColor.WHITE, "right");
    composerText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    composerText.antialiasing = Options.antialiasing;
    composerText.alpha = 0;
    add(composerText);
    
    var difficultyRaw = PlayState.difficulty?.toUpperCase();
    var difficultyDisplay = switch (difficultyRaw) {
        case "NORMAL": "[普通]";
        case "EASY":   "[简单]";
        case "HARD":   "[困难]";
        default:       "[普通]";
    }
    var diffColor = switch (difficultyRaw) {
        case "NORMAL": 0xFFFFFF00;
        case "EASY":   0xFF00FF00;
        case "HARD":   0xFFFF0000;
        default:       FlxColor.WHITE;
    }
    difficultyText = new FlxText(0, songNameText.y, 0, difficultyDisplay, 36);
    difficultyText.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 36, diffColor, "left");
    difficultyText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    difficultyText.antialiasing = Options.antialiasing;
    difficultyText.alpha = 0;
    add(difficultyText);
    
    composerText.x = FlxG.width - composerText.width;
    var composerRightEdge = composerText.x + composerText.width;
    difficultyText.x = composerRightEdge - difficultyText.width;
    var difficultyLeftEdge = difficultyText.x;
    var songNameRightEdge = difficultyLeftEdge - 2;
    songNameText.x = songNameRightEdge - songNameText.width;
    if (songNameText.x < 0) songNameText.x = 0;
}

function playIntroAnimation() {
    isIntroAnimating = true;
    canPress = false;
    var animTime = 0.9;

    for (i in 0...cards.length) {
        var item = cards[i];
        var ty = i - curSelected;
        var targetX = -ty * ty * 20 + 50;
        var targetTextX = targetX + 30;
        FlxTween.tween(item.card, {x: targetX}, animTime, {ease: FlxEase.quartOut});
        FlxTween.tween(item.text, {x: targetTextX}, animTime, {ease: FlxEase.quartOut});
    }

    updateCharacterImage();
    if (characterImage.visible) {
        var targetY = characterImage.y;
        characterImage.y = FlxG.height + characterImage.height + 100;
        FlxTween.tween(characterImage, {y: targetY}, animTime, {ease: FlxEase.quartOut});
    }
    // ADDED 第二个角色图片动画
    if (characterImage2 != null && characterImage2.visible) {
        var targetY2 = characterImage2.y;
        characterImage2.y = FlxG.height + characterImage2.height + 100;
        FlxTween.tween(characterImage2, {y: targetY2}, animTime, {ease: FlxEase.quartOut});
    }

    disk.x = diskEnterStartX;
    disk.y = diskEnterStartY;
    FlxTween.tween(disk, {x: diskEnterTargetX, y: diskEnterTargetY}, animTime, {ease: FlxEase.quartOut});

    syncIconToDisk();

    FlxTween.tween(menuDesat, {alpha: 0.75}, animTime, {ease: FlxEase.quartOut});
    FlxTween.tween(tilesThing, {alpha: 0.1}, animTime, {ease: FlxEase.quartOut});
    FlxTween.tween(blacktop, {y: -80}, animTime, {ease: FlxEase.quartOut});
    FlxTween.tween(blackbottom, {y: 680}, animTime, {ease: FlxEase.quartOut});
    FlxTween.tween(cutbox, {x: 750}, animTime, {ease: FlxEase.quartOut});

    var slideOffset = 200;
    FlxTween.tween(songNameText, {x: songNameText.x, alpha: 1}, animTime, {ease: FlxEase.quartOut, start: {x: songNameText.x + slideOffset, alpha: 0}});
    FlxTween.tween(composerText, {x: composerText.x, alpha: 1}, animTime, {ease: FlxEase.quartOut, start: {x: composerText.x + slideOffset, alpha: 0}});
    FlxTween.tween(difficultyText, {x: difficultyText.x, alpha: 1}, animTime, {ease: FlxEase.quartOut, start: {x: difficultyText.x + slideOffset, alpha: 0}});

    new FlxTimer().start(animTime + 0.05, function(_) {
        isIntroAnimating = false;
        canPress = true;
    });
}

function playOutroAnimation() {
    if (isAnimatingOut) return;
    isAnimatingOut = true;
    canPress = false;
    var animTime = 0.9;

    var outX = -800;
    var outTextX = -770;

    for (i in 0...cards.length) {
        var item = cards[i];
        FlxTween.tween(item.card, {x: outX}, animTime, {ease: FlxEase.quartIn});
        FlxTween.tween(item.text, {x: outTextX}, animTime, {ease: FlxEase.quartIn});
    }

    if (characterImage != null && characterImage.visible) {
        FlxTween.tween(characterImage, {y: FlxG.height + characterImage.height + 100}, animTime, {ease: FlxEase.quartIn});
    }
    // ADDED 第二个角色图片退场动画
    if (characterImage2 != null && characterImage2.visible) {
        FlxTween.tween(characterImage2, {y: FlxG.height + characterImage2.height + 100}, animTime, {ease: FlxEase.quartIn});
    }

    diskExitStartX = disk.x;
    diskExitStartY = disk.y;
    diskExitTargetX = diskEnterStartX;
    diskExitTargetY = diskEnterStartY;
    FlxTween.tween(disk, {x: diskExitTargetX, y: diskExitTargetY}, animTime, {ease: FlxEase.quartIn});

    FlxTween.tween(menuDesat, {alpha: 0}, animTime, {ease: FlxEase.quartIn});
    FlxTween.tween(tilesThing, {alpha: 0}, animTime, {ease: FlxEase.quartIn});
    FlxTween.tween(blacktop, {y: -blacktop.height - 100}, animTime, {ease: FlxEase.quartIn});
    FlxTween.tween(blackbottom, {y: FlxG.height + 100}, animTime, {ease: FlxEase.quartIn});
    FlxTween.tween(cutbox, {x: 1400}, animTime, {ease: FlxEase.quartIn});

    var slideOffset = 200;
    FlxTween.tween(songNameText, {x: songNameText.x + slideOffset, alpha: 0}, animTime, {ease: FlxEase.quartIn});
    FlxTween.tween(composerText, {x: composerText.x + slideOffset, alpha: 0}, animTime, {ease: FlxEase.quartIn});
    FlxTween.tween(difficultyText, {x: difficultyText.x + slideOffset, alpha: 0}, animTime, {ease: FlxEase.quartIn});

    new FlxTimer().start(animTime + 0.05, function(_) {
        isAnimatingOut = false;
    });
}

function startCountdown(onComplete: Void->Void) {
    if (isCountingDown) return;
    isCountingDown = true;
    canPress = false;
    countdownIndex = 0;
    
    function showNext() {
        if (countdownIndex >= countdownTexts.length) {
            isCountingDown = false;
            onComplete();
            return;
        }
        
        var txt = countdownTexts[countdownIndex];
        txt.visible = true;
        txt.alpha = 1;
        txt.scale.set(1.5, 1.5);
        
        FlxTween.tween(txt.scale, {x: 1, y: 1}, 0.3, {ease: FlxEase.backOut});
        FlxTween.tween(txt, {alpha: 0}, 0.5, {ease: FlxEase.quadIn, onComplete: function(_) {
            txt.visible = false;
        }});
        
        var num = 3 - countdownIndex;
        var soundName = "tick" + num;
        FlxG.sound.play(Paths.sound(soundName), 0.8);
        
        countdownIndex++;
        countdownTimer = new FlxTimer().start(0.5, function(_) showNext());
    }
    
    showNext();
}

function syncIconToDisk() {
    if (songIcon != null && disk != null) {
        var diskCenterX = disk.x + disk.width / 2;
        var diskCenterY = disk.y + disk.height / 2;
        
        var offsetX = iconOffsetX;
        var offsetY = iconOffsetY;
        
        var angleRad = disk.angle * Math.PI / 180;
        var cosA = Math.cos(angleRad);
        var sinA = Math.sin(angleRad);
        
        var rotatedOffsetX = offsetX * cosA - offsetY * sinA;
        var rotatedOffsetY = offsetX * sinA + offsetY * cosA;
        
        var iconCenterX = diskCenterX + rotatedOffsetX;
        var iconCenterY = diskCenterY + rotatedOffsetY;
        
        songIcon.x = iconCenterX - songIcon.width / 2;
        songIcon.y = iconCenterY - songIcon.height / 2;
        
        songIcon.angle = disk.angle;
    }
}

function updateSelection() {
    for (i in 0...cards.length) {
        var item = cards[i];
        var isSelected = (i == curSelected);
        item.card.color = isSelected ? currentSongColor : 0xFF333333;
        item.card.alpha = isSelected ? 0.8 : 0.5;
        item.text.color = isSelected ? FlxColor.YELLOW : FlxColor.WHITE;
        item.text.alpha = isSelected ? 1 : 0.7;
    }

    var targetBgColor = FlxColor.interpolate(0xFF222222, currentSongColor, 0.4);
    menuDesat.color = targetBgColor;
    menuDesat.alpha = 0.75;

    updateCharacterImage();
}

function updateCharacterImage() {
    var songName = (PlayState.SONG != null) ? PlayState.SONG.meta.name.toLowerCase() : "";
    var data = characterMap.get(songName);
    if (data != null) {
        // 第一个角色
        characterImage.loadGraphic(Paths.image('menus/freeplay/' + data.image));
        characterImage.color = FlxColor.WHITE;
        characterImage.shader = null;
        characterImage.alpha = 1;
        characterImage.visible = true;
        characterImage.setPosition(data.x, data.y);
        
        // ADDED 第二个角色（如果有）
        if (data.image2 != null && data.x2 != null && data.y2 != null) {
            characterImage2.loadGraphic(Paths.image('menus/freeplay/' + data.image2));
            characterImage2.color = FlxColor.WHITE;
            characterImage2.shader = null;
            characterImage2.alpha = 1;
            characterImage2.visible = true;
            characterImage2.setPosition(data.x2, data.y2);
        } else {
            characterImage2.visible = false;
        }
    } else {
        characterImage.visible = false;
        characterImage2.visible = false;
    }
}

function update(elapsed:Float) {
    #if mobile	
        removeTouchPad();
    #end
    
    var rotateSpeed = 20.0;
    if (isIntroAnimating) {
        var progress = (disk.x - diskEnterStartX) / (diskEnterTargetX - diskEnterStartX);
        progress = FlxMath.bound(progress, 0, 1);
        rotateSpeed = 80 + (20 - 80) * progress;
    } else if (isAnimatingOut) {
        var progress = (disk.x - diskExitStartX) / (diskExitTargetX - diskExitStartX);
        progress = FlxMath.bound(progress, 0, 1);
        rotateSpeed = 20 + (80 - 20) * progress;
    }
    if (disk != null) disk.angle += elapsed * rotateSpeed;

    syncIconToDisk();

    if (!canPress || isAnimatingOut || isIntroAnimating || isCountingDown) return;

    // 鼠标拖拽（无改动）
    if (FlxG.mouse.justPressed) {
        isDragging = true;
        dragStartY = FlxG.mouse.screenY;
        dragLastY = dragStartY;
        dragAccumulated = 0;
        dragTotalDelta = 0;
    }

    if (isDragging && FlxG.mouse.pressed) {
        var currentY = FlxG.mouse.screenY;
        var delta = currentY - dragLastY;
        dragLastY = currentY;
        dragAccumulated += delta;
        dragTotalDelta += Math.abs(delta);

        var step = (dragAccumulated > 0 ? 1 : -1);
        while (Math.abs(dragAccumulated) >= dragStepThreshold) {
            var newSel = curSelected - step;
            newSel = FlxMath.bound(newSel, 0, options.length - 1);
            if (newSel != curSelected) {
                curSelected = newSel;
                updateSelection();
                FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
            }
            dragAccumulated -= step * dragStepThreshold;
        }
    }

    if (FlxG.mouse.justReleased) {
        if (isDragging) {
            var mouseX = FlxG.mouse.screenX;
            var mouseY = FlxG.mouse.screenY;
            var halfWidth = FlxG.width / 2;
            var centerY = FlxG.height / 2;
            var isLeftHalf = mouseX >= 0 && mouseX <= halfWidth;
            var isNearCenter = Math.abs(mouseY - centerY) <= 150;
            var isLightTap = dragTotalDelta < 10;

            if (isLeftHalf && isNearCenter && isLightTap) {
                canPress = false;
                FlxG.sound.play(Paths.sound("confirmMenu"));
                selectOption();
            }
        }
        isDragging = false;
        dragAccumulated = 0;
        dragTotalDelta = 0;
    }

    if (controls.UP_P) {
        var ns = curSelected - 1;
        if (ns >= 0) {
            curSelected = ns;
            updateSelection();
            FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
        }
    }
    if (controls.DOWN_P) {
        var ns = curSelected + 1;
        if (ns < options.length) {
            curSelected = ns;
            updateSelection();
            FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
        }
    }
    if (controls.ACCEPT) {
        canPress = false;
        FlxG.sound.play(Paths.sound("confirmMenu"));
        selectOption();
    }

    if (FlxG.mouse.wheel != 0) {
        var dir = (FlxG.mouse.wheel > 0) ? -1 : 1;
        var ns = curSelected + dir;
        ns = FlxMath.bound(ns, 0, options.length - 1);
        if (ns != curSelected) {
            curSelected = ns;
            updateSelection();
            FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
        }
    }

    var lv = FlxMath.bound(elapsed * 9, 0, 1);
    var ch = FlxG.height * 0.40;
    for (i in 0...cards.length) {
        var item = cards[i];
        var ty = i - curSelected;
        var targetX = -ty * ty * 20 + 50;
        var targetY = ty * 170 + ch;
        item.card.x = FlxMath.lerp(item.card.x, targetX, lv);
        item.card.y = FlxMath.lerp(item.card.y, targetY, lv);
        item.text.x = FlxMath.lerp(item.text.x, targetX + 30, lv);
        item.text.y = FlxMath.lerp(item.text.y, targetY + 40 + 10, lv);
    }
}

function selectOption() {
    var option = options[curSelected];
    if (option == "继续") {
        startCountdown(function() {
            FlxTween.tween(pauseCam, {alpha: 0}, 0.2, {
                ease: FlxEase.circIn,
                onComplete: function(_) {
                    close();
                }
            });
        });
        playOutroAnimation();
    } else {
        comeOnDoSomething(option);
    }
}

function comeOnDoSomething(option:String) {
    switch(option) {
        case "重试":
            game.registerSmoothTransition();
            FlxG.resetState();
            break;
        case "设置":
            FlxG.switchState(new OptionsMenu((_) -> FlxG.switchState(new PlayState())));
            break;
        case "退出":
            CoolUtil.playMenuSong();
            FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
            break;
    }
}