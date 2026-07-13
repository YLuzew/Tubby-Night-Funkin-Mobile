import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.backend.chart.Chart;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.savedata.FunkinSave;
import funkin.backend.shaders.CustomShader; 
import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;

static var selectedSong = 0;

var difficulties:Array<String> = ["NORMAL", "EASY", "HARD"];
var scarySongs:Array<String> = ["custard", "rabbits blood", "carnage", "sensed", "bad dreams"];

var backgroundGroup:FlxGroup;
var midgroundGroup:FlxGroup;
var foregroundGroup:FlxGroup;
var diskGroup:FlxGroup;

var menuDesat:FlxSprite;
var tilesThing:FlxBackdrop;
var blacktop:FlxSprite;
var blackbottom:FlxSprite;
var glowyThing:FlxSprite;
var cutbox:FlxSprite;
var leftArrow:FunkinSprite;
var rightArrow:FunkinSprite;

var characterImage:FlxSprite;
var characterImage2:FlxSprite;
var charTween:FlxTween;
var targetCharX:Float = 0;
var targetCharY:Float = 0;

var songs:Array<ChartMetaData> = [];
var cards:Array<Dynamic> = [];
var curSelected:Int = 0;
var canSelect:Bool = true;

var confirm:FlxSound;
var cancel:FlxSound;
var hover:FlxSound;
var locked:FlxSound;

var currentDifficulty:Int = 0;
var difficultyIcons:Array<FlxSprite> = [];
var lerpAccuracy:Int = 0;
var intendedAccuracy:Int = 0;
var accuracyRank:String = "";
var accuracyText:FlxText;
var lastAccuracyDisplay:String = "";

var disk:FlxSprite; 
var bgColor:FlxColor = 0xFFFFFFFF; 

var inCreepyMode:Bool = false;
var targetPitch:Float = 1.0;
var creepyShakeAmount:Float = 0;
var creepyTimer:Float = 0; 

var canInteract:Bool = true;

var backButton:FlxText;

var isDragging:Bool = false;
var dragStartY:Float = 0;
var dragStartSelected:Int = 0;
var dragThreshold:Float = 5;
var pressedCard:Int = -1;
var dragSensitivity:Float = 0.018;

var pendingLeft:Bool = false;
var pendingRight:Bool = false;
var leftPress:Bool = false;
var rightPress:Bool = false;

var characterMap:Map<String, Dynamic> = [
    "chill bill"    => { image: "tinkywinky-portrait", x: 640, y: -40 },
    "simulation"    => { image: "tinkywinky-portrait", x: 640, y: -40 },
    "farewell"      => { image: "tinkywinky-portrait", x: 640, y: -40 },
    "optimistic"    => { image: "laalaa-portrait", x: 600, y: -40 },
    "dipstick"      => { image: "dipsy-portrait", x: 600, y: -40 },
    "custa starz"   => { image: "laalaa-portrait", x: 720, y: -40 , image2: "dipsy-portrait", x2: 550, y: -40 },
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

var weekSongs:Array<String> = [
    "chill bill", "simulation", "farewell",
    "energetic", "radiant", "lighthearted",
    "optimistic", "dipstick", "custa starz"
];

// ---- 性能优化 ----
var songIndexMap:Map<String,Int> = [];
var songUnlocked:Array<Bool> = [];
var songScored:Array<Bool> = [];
var custardPlayed:Bool = false;
var allWeekUnlocked:Bool = false;

var blurShader2:CustomShader;
var blurShader35:CustomShader;

var lockShakeTimer:Float = 0;
var lockShakeIntensity:Float = 12;
var cardShakeMultiplier:Float = 1.5;

var acceptPressed:Bool = false;

// 获取所有隐藏歌曲（保持原顺序）
function getHiddenSongs():Array<String> {
    var hidden:Array<String> = [];
    for (s in songs) {
        var n = s.name.toLowerCase();
        if (!weekSongs.contains(n)) hidden.push(n);
    }
    return hidden;
}

// ---------- 缓存刷新 ----------
function refreshCache() {
    songIndexMap = [];
    for (i in 0...songs.length) {
        songIndexMap[songs[i].name.toLowerCase()] = i;
    }

    songScored = [];
    for (i in 0...songs.length) {
        songScored.push(calcScored(i));
    }

    // 三个周目是否都已完成（用于显示隐藏歌曲）
    allWeekUnlocked = checkAllWeeksBeaten();

    songUnlocked = [];
    for (i in 0...songs.length) {
        songUnlocked.push(calcUnlocked(i));
    }

    custardPlayed = false;
    var cidx = songIndexMap["custard"];
    if (cidx != null) {
        custardPlayed = songScored[cidx];
    }
}

// 检查三个周目是否都有通关记录（任意难度）
function checkAllWeeksBeaten():Bool {
    function weekBeaten(weekName:String):Bool {
        var scoreE = FunkinSave.getWeekHighscore(weekName, 'easy').score;
        var scoreN = FunkinSave.getWeekHighscore(weekName, 'normal').score;
        var scoreH = FunkinSave.getWeekHighscore(weekName, 'hard').score;
        return (scoreE > 0 || scoreN > 0 || scoreH > 0);
    }
    return weekBeaten('tinky') && weekBeaten('po') && weekBeaten('laa-laa-dipsy');
}

function calcScored(idx:Int):Bool {
    if (idx < 0 || idx >= songs.length) return false;
    var name = songs[idx].name;
    var diffs = ["NORMAL","EASY","HARD","normal","easy","hard",""];
    for (d in diffs) {
        var sd = FunkinSave.getSongHighscore(name, d);
        if (sd != null && (sd.score > 0 || sd.accuracy > 0)) return true;
    }
    return false;
}

// 解锁逻辑：
// 周目歌曲：需要自身有游玩记录
// 隐藏歌曲：必须三个周目都通关，且自身有游玩记录
function calcUnlocked(idx:Int):Bool {
    if (idx < 0 || idx >= songs.length) return false;
    var songName = songs[idx].name.toLowerCase();

    // 周目歌曲：需要自身有游玩记录
    if (weekSongs.contains(songName)) {
        return calcScored(idx);
    }

    // 隐藏歌曲：前提是三个周目都通关，并且自身有游玩记录
    return allWeekUnlocked && calcScored(idx-1);
}

// 可见性：周目歌曲始终可见；隐藏歌曲只有三个周目都通关后才可见
function isVisible(idx:Int):Bool {
    if (idx < 0 || idx >= songs.length) return false;
    var songName = songs[idx].name.toLowerCase();
    if (weekSongs.contains(songName)) return true;
    return allWeekUnlocked;
}

function refreshAllCards() {
    for (i in 0...cards.length) {
        if (i >= songs.length) continue;
        var unlocked = songUnlocked[i];
        var scored = songScored[i];
        var cardItem = cards[i];
        var visible = isVisible(i);
        if (!visible) {
            cardItem.card.visible = false;
            cardItem.text.visible = false;
            cardItem.icon.visible = false;
            if (cardItem.lock != null) cardItem.lock.visible = false;
            continue;
        }
        cardItem.card.visible = true;
        cardItem.text.visible = true;
        cardItem.icon.visible = true;

        if (unlocked && scored) {
            cardItem.card.color = songs[i].color;
            cardItem.card.alpha = 1.0;
            cardItem.text.text = songs[i].displayName;
            cardItem.text.alpha = 1.0;
            cardItem.icon.color = FlxColor.WHITE;
            cardItem.icon.shader = null;
            if (cardItem.lock != null) cardItem.lock.visible = false;
        } else if (unlocked && !scored) {
            // 解锁但未游玩：黑色卡片，“???”，无锁
            cardItem.card.color = 0xFF333333;
            cardItem.card.alpha = 0.6;
            cardItem.text.text = "???";
            cardItem.text.alpha = 0.6;
            cardItem.icon.color = FlxColor.BLACK;
            cardItem.icon.shader = blurShader2;
            if (cardItem.lock != null) cardItem.lock.visible = false;
        } else {
            // 未解锁：黑色卡片，“???”，有锁
            cardItem.card.color = 0xFF333333;
            cardItem.card.alpha = 0.6;
            cardItem.text.text = "???";
            cardItem.text.alpha = 0.6;
            cardItem.icon.color = FlxColor.BLACK;
            cardItem.icon.shader = blurShader2;
            if (cardItem.lock != null) cardItem.lock.visible = true;
        }
    }
    if (!isVisible(curSelected)) {
        var last = curSelected;
        while (last > 0 && !isVisible(last)) last--;
        if (isVisible(last)) changeSelection(last - curSelected, true);
        else changeSelection(-curSelected, true);
    }
}

function create() {
    CoolUtil.playMenuSong();
    var songListData = FreeplaySonglist.get();
    var allSongs = (songListData != null) ? songListData.songs : [];
    songs = allSongs.copy();

    if (selectedSong >= songs.length) selectedSong = songs.length > 0 ? songs.length - 1 : 0;
    curSelected = selectedSong;

    blurShader2 = new CustomShader("blur");
    blurShader2.blurRadius = 2;
    blurShader2.blurAmount = 2.0;
    blurShader35 = new CustomShader("blur");
    blurShader35.blurAmount = 3.5;
    blurShader35.blurRadius = 2;
    refreshCache();

    confirm = FlxG.sound.load(Paths.sound('menu/confirm'));
    cancel = FlxG.sound.load(Paths.sound('menu/cancel'));
    hover = FlxG.sound.load(Paths.sound('menu/scroll'));
    locked = FlxG.sound.load(Paths.sound('menu/locked'));

    menuDesat = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menuDesat'));
    menuDesat.screenCenter();
    menuDesat.scale.set(1.1, 1.1);
    menuDesat.antialiasing = Options.antialiasing;
    menuDesat.color = 0xFF222222;
    add(menuDesat);

    tilesThing = new FlxBackdrop(Paths.image('menus/checker'));
    tilesThing.antialiasing = Options.antialiasing;
    tilesThing.scrollFactor.set(0.2, 0.2);
    tilesThing.velocity.set(50, 50);
    tilesThing.alpha = 0.1;
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
    add(blacktop);

    characterImage = new FlxSprite(0, 0);
    characterImage.antialiasing = Options.antialiasing;
    characterImage.visible = false;
    characterImage.scale.set(1, 1);
    add(characterImage);

    characterImage2 = new FlxSprite(0, 0);
    characterImage2.antialiasing = Options.antialiasing;
    characterImage2.visible = false;
    characterImage2.scale.set(1, 1);
    add(characterImage2);

    accuracyText = new FlxText(FlxG.width, 10, 400, "准度: 0% (?)", 48);
    accuracyText.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 32, FlxColor.WHITE, "right", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    accuracyText.borderSize = 2;
    accuracyText.antialiasing = Options.antialiasing;
    add(accuracyText);

    add(backgroundGroup = new FlxGroup());
    add(midgroundGroup = new FlxGroup());

    disk = new FlxSprite(-50, 420).loadGraphic(Paths.image('menus/freeplay/disk'));
    disk.antialiasing = Options.antialiasing;

    blackbottom = new FlxSprite(-10, FlxG.height + 100).makeSolid(1320, 150, FlxColor.BLACK);
    blackbottom.antialiasing = Options.antialiasing;
    blackbottom.angle = 2;
    add(blackbottom);

    add(diskGroup = new FlxGroup());
    add(foregroundGroup = new FlxGroup());
    diskGroup.add(disk);

    if (songs.length > 0) for (i in 0...songs.length) addCard(i);

    cutbox = new FlxSprite(1400, 250).loadGraphic(Paths.image('menus/freeplay/black-cut-box-right'));
    cutbox.antialiasing = Options.antialiasing;
    cutbox.scale.set(0.4, 0.4);
    add(cutbox);

    leftArrow = new FunkinSprite(730, FlxG.height, Paths.image('menus/freeplay/assets'));
    leftArrow.addAnim('idle', 'arrow left');
    leftArrow.addAnim('press', 'arrow push left');
    leftArrow.antialiasing = Options.antialiasing;
    add(leftArrow);

    rightArrow = new FunkinSprite(1180, FlxG.height, Paths.image('menus/freeplay/assets'));
    rightArrow.addAnim('idle', 'arrow left');
    rightArrow.addAnim('press', 'arrow push left');
    rightArrow.flipX = true;
    rightArrow.antialiasing = Options.antialiasing;
    add(rightArrow);

    var diffs = ["NORMAL", "EASY", "HARD"];
    for (name in diffs) {
        var icon = new FlxSprite((name == "NORMAL") ? 700 : 785, FlxG.height).loadGraphic(Paths.image('menus/freeplay/' + name));
        if (name == "EASY") icon.x = 795;
        else if (name == "HARD") icon.x = 785;
        icon.antialiasing = true;
        icon.scale.set(0.6, 0.6);
        icon.visible = false;
        difficultyIcons.push(icon);
        add(icon);
    }
    if (difficultyIcons.length > currentDifficulty) difficultyIcons[currentDifficulty].visible = true;
    leftArrow.animation.play('idle');
    rightArrow.animation.play('idle');

    backButton = new FlxText(20, FlxG.height - 70, 0, "返回", 48);
    backButton.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 48, FlxColor.WHITE, "left");
    backButton.scrollFactor.set(0, 0);
    backButton.antialiasing = Options.antialiasing;
    backButton.borderStyle = FlxTextBorderStyle.NONE;
    add(backButton);

    performIntro();
    refreshAllCards();
    changeSelection(0, true);
}

function performIntro() {
    FlxTween.tween(blacktop, {y: -80}, 1, {ease: FlxEase.expoOut});
    FlxTween.tween(blackbottom, {y: 680}, 1, {ease: FlxEase.expoOut});
    FlxTween.tween(cutbox, {x: 750}, 1, {ease: FlxEase.expoOut, startDelay: 0.2});
    FlxTween.tween(accuracyText, {x: 870}, 1, {ease: FlxEase.expoOut, startDelay: 0.4});
    FlxTween.tween(leftArrow, {y: FlxG.height - 100}, 1, {ease: FlxEase.backOut, startDelay: 0.5});
    FlxTween.tween(rightArrow, {y: FlxG.height - 100}, 1, {ease: FlxEase.backOut, startDelay: 0.6});
    for (icon in difficultyIcons) FlxTween.tween(icon, {y: FlxG.height - 115}, 1, {ease: FlxEase.backOut, startDelay: 0.55});
}

var focusLost = false;

// 当窗口获得焦点时刷新缓存（解决游玩后返回不更新的问题）
function onFocus() {
    focusLost = true;
    refreshCache();
    refreshAllCards();
    updateScore();
    if (charTween != null) charTween.cancel();
    updateCharacter(false);
    new FlxTimer().start(0.25, () -> focusLost = false);
}

function update(elapsed:Float) {
    if (!canInteract) return;

    if (lockShakeTimer > 0) {
        lockShakeTimer -= elapsed;
        if (lockShakeTimer <= 0) {
            lockShakeTimer = 0;
            if (cards.length > 0 && curSelected < cards.length) {
                var item = cards[curSelected];
                item.card.offset.set(0, 0);
                item.text.offset.set(0, 0);
                if (item.lock != null) item.lock.offset.set(0, 0);
            }
        } else {
            if (cards.length > 0 && curSelected < cards.length) {
                var item = cards[curSelected];
                var cs = lockShakeIntensity * cardShakeMultiplier;
                item.card.offset.set(FlxG.random.float(-cs, cs), FlxG.random.float(-cs, cs));
                item.text.offset.set(FlxG.random.float(-cs, cs), FlxG.random.float(-cs, cs));
                if (item.lock != null && item.lock.visible)
                    item.lock.offset.set(FlxG.random.float(-lockShakeIntensity, lockShakeIntensity),
                                         FlxG.random.float(-lockShakeIntensity, lockShakeIntensity));
            }
        }
    }

    var mouseOverBack = FlxG.mouse.overlaps(backButton);
    if (!mouseOverBack) {
        if (FlxG.mouse.justPressed && !isDragging && canSelect) {
            var hit = -1;
            for (i in 0...cards.length) {
                var c = cards[i];
                if (isVisible(i) && (FlxG.mouse.overlaps(c.card) || FlxG.mouse.overlaps(c.text))) { hit = i; break; }
            }
            if (hit != -1) {
                isDragging = true;
                dragStartY = FlxG.mouse.screenY;
                dragStartSelected = curSelected;
                pressedCard = hit;
            }
        }
        if (isDragging && FlxG.mouse.justReleased) {
            var delta = FlxG.mouse.screenY - dragStartY;
            if (Math.abs(delta) <= dragThreshold && pressedCard != -1) {
                if (pressedCard == curSelected) selectSong();
                else changeSelection(pressedCard - curSelected);
            }
            isDragging = false;
            pressedCard = -1;
        }
        if (isDragging && FlxG.mouse.pressed && canSelect && lockShakeTimer <= 0) {
            var delta = FlxG.mouse.screenY - dragStartY;
            var ns = dragStartSelected - Math.round(delta * dragSensitivity);
            ns = FlxMath.bound(ns, 0, songs.length - 1);
            while (ns > 0 && !isVisible(ns)) ns--;
            while (ns < songs.length - 1 && !isVisible(ns)) ns++;
            if (ns != curSelected) changeSelection(ns - curSelected);
        }
    }

    if (controls.ACCEPT) {
        if (!acceptPressed) {
            acceptPressed = true;
            selectSong();
        }
    } else {
        acceptPressed = false;
    }

    if (lockShakeTimer <= 0) {
        if (!isVisible(curSelected)) {
            var n = curSelected;
            while (n > 0 && !isVisible(n)) n--;
            if (isVisible(n) && n != curSelected) changeSelection(n - curSelected, true);
        }

        if (FlxG.keys.justPressed.LEFT && !pendingLeft) pendingLeft = true;
        if (FlxG.keys.justPressed.RIGHT && !pendingRight) pendingRight = true;
        if (FlxG.mouse.justPressed) {
            if (FlxG.mouse.overlaps(leftArrow) && !pendingLeft) { pendingLeft = true; leftPress = true; }
            if (FlxG.mouse.overlaps(rightArrow) && !pendingRight) { pendingRight = true; rightPress = true; }
        }
        if (FlxG.keys.justReleased.LEFT && pendingLeft) { pendingLeft = false; changeDifficulty(1); }
        if (FlxG.keys.justReleased.RIGHT && pendingRight) { pendingRight = false; changeDifficulty(-1); }
        if (FlxG.mouse.justReleased) {
            if (pendingLeft && FlxG.mouse.overlaps(leftArrow)) { pendingLeft = false; leftPress = false; changeDifficulty(1); }
            if (pendingRight && FlxG.mouse.overlaps(rightArrow)) { pendingRight = false; rightPress = false; changeDifficulty(-1); }
        }
        if (pendingLeft && !FlxG.mouse.overlaps(leftArrow) && FlxG.mouse.pressed) { pendingLeft = false; leftPress = false; }
        if (pendingRight && !FlxG.mouse.overlaps(rightArrow) && FlxG.mouse.pressed) { pendingRight = false; rightPress = false; }
        leftArrow.animation.play(pendingLeft ? 'press' : 'idle');
        rightArrow.animation.play(pendingRight ? 'press' : 'idle');

        if (!isDragging && !mouseOverBack && canSelect) {
            var shift = (controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel;
            if (shift != 0) {
                var ns = curSelected + shift;
                if (ns < 0) ns = 0;
                if (ns >= songs.length) ns = songs.length - 1;
                var step = shift > 0 ? 1 : -1;
                while (ns >= 0 && ns < songs.length && !isVisible(ns)) ns += step;
                if (ns < 0) ns = 0;
                if (ns >= songs.length) ns = songs.length - 1;
                if (isVisible(ns) && ns != curSelected) changeSelection(ns - curSelected);
            }
        }

        if (mouseOverBack) {
            backButton.color = FlxColor.BLUE;
            if (FlxG.mouse.justPressed) { performGoBack(); return; }
        } else backButton.color = FlxColor.WHITE;
        if (controls.BACK) { performGoBack(); return; }
    }

    var newDisplay = "";
    if (songUnlocked[curSelected] && songScored[curSelected])
        newDisplay = "准度: " + Math.floor(lerpAccuracy) + "% (" + accuracyRank + ")";
    else if (songUnlocked[curSelected])
        newDisplay = "准度: 0% (?)";
    else
        newDisplay = "未解锁";

    if (newDisplay != lastAccuracyDisplay) {
        accuracyText.text = newDisplay;
        lastAccuracyDisplay = newDisplay;
    }

    var ls = FlxMath.bound(elapsed * 12, 0, 1);
    lerpAccuracy = FlxMath.lerp(lerpAccuracy, intendedAccuracy, ls);
    if (Math.abs(lerpAccuracy - intendedAccuracy) <= 1) lerpAccuracy = intendedAccuracy;

    var lv = FlxMath.bound(elapsed * 9, 0, 1);
    var px = (FlxG.mouse.screenX - FlxG.width / 2) * 0.02;
    var py = (FlxG.mouse.screenY - FlxG.height / 2) * 0.02;

    if (FlxG.sound.music != null)
        FlxG.sound.music.pitch = FlxMath.lerp(FlxG.sound.music.pitch, targetPitch, elapsed * 0.8);

    if (inCreepyMode) {
        var base = (songs[curSelected] != null) ? songs[curSelected].color : FlxColor.WHITE;
        bgColor = FlxColor.interpolate(bgColor, FlxColor.interpolate(FlxColor.interpolate(base, FlxColor.BLACK, 0.75), 0xFF550000, 0.25), 0.05);
        creepyShakeAmount = FlxMath.lerp(creepyShakeAmount, 1.5, elapsed * 2);
        var sx = FlxG.random.float(-creepyShakeAmount, creepyShakeAmount);
        var sy = FlxG.random.float(-creepyShakeAmount, creepyShakeAmount);
        menuDesat.offset.set(sx, sy);
        characterImage.offset.set(sx, sy);
        characterImage2.offset.set(sx, sy);
        menuDesat.alpha = FlxG.random.bool(3) ? 0.6 : FlxMath.lerp(menuDesat.alpha, 1, elapsed * 8);
        creepyTimer += elapsed;
        FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1 + Math.sin(creepyTimer * 1.5) * 0.03, elapsed);
        FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, Math.sin(creepyTimer * 0.3) * 2, elapsed);
        tilesThing.alpha = FlxMath.lerp(tilesThing.alpha, 0.4, elapsed);
        tilesThing.color = FlxColor.RED;
    } else {
        creepyShakeAmount = FlxMath.lerp(creepyShakeAmount, 0, elapsed * 4);
        menuDesat.offset.set(0, 0);
        characterImage.offset.set(0, 0);
        characterImage2.offset.set(0, 0);
        menuDesat.alpha = 1;
        if (!controls.ACCEPT) FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, elapsed * 4);
        FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, elapsed * 4);
        bgColor = FlxColor.interpolate(bgColor, (songUnlocked[curSelected] && songScored[curSelected]) ? songs[curSelected].color : FlxColor.fromRGB(60, 60, 60), 0.04);
        tilesThing.alpha = FlxMath.lerp(tilesThing.alpha, 0.1, elapsed);
        tilesThing.color = FlxColor.WHITE;
    }
    menuDesat.color = glowyThing.color = bgColor;
    menuDesat.setPosition(FlxMath.lerp(menuDesat.x, -px, lv), FlxMath.lerp(menuDesat.y, -py, lv));
    if (characterImage.visible)
        characterImage.setPosition(FlxMath.lerp(characterImage.x, targetCharX - px * 1.5, lv), FlxMath.lerp(characterImage.y, targetCharY - py * 1.5, lv));
    if (characterImage2.visible) {
        var data = characterMap.get(songs[curSelected].name.toLowerCase());
        var tx = data?.x2 ?? targetCharX + 200;
        var ty = data?.y2 ?? targetCharY;
        characterImage2.setPosition(FlxMath.lerp(characterImage2.x, tx - px * 1.5, lv), FlxMath.lerp(characterImage2.y, ty - py * 1.5, lv));
    }

    if (disk != null) disk.angle += elapsed * 20;

    var ch = FlxG.height * 0.40;
    for (i in 0...cards.length) {
        var item = cards[i];
        if (!isVisible(i)) {
            item.card.visible = false;
            item.text.visible = false;
            item.icon.visible = false;
            if (item.lock != null) item.lock.visible = false;
            continue;
        }
        var ty = i - curSelected;
        if (Math.abs(ty) > 6 && i != curSelected) {
            item.card.visible = item.text.visible = item.icon.visible = false;
            if (item.lock != null) item.lock.visible = false;
            continue;
        }
        if (!item.card.visible) {
            item.card.visible = item.text.visible = item.icon.visible = true;
        }
        var unlocked = songUnlocked[i];
        var scored = songScored[i];
        var baseAlpha = (unlocked && !scored) ? 0.6 : (unlocked ? 1.0 : 0.6);
        var alpha = (i == curSelected) ? baseAlpha : baseAlpha * (1 - Math.abs(ty) * 0.15);
        var scale = (i == curSelected) ? 1.05 : 1 - Math.abs(ty) * 0.06;
        item.card.setPosition(FlxMath.lerp(item.card.x, -ty * ty * 20 + 50, lv), FlxMath.lerp(item.card.y, ty * 170 + ch, lv));
        item.card.alpha = item.text.alpha = alpha;
        item.icon.alpha = (i == curSelected) ? 1 : 0;
        item.card.scale.set(scale, scale);
        item.text.scale.set(scale, scale);
        item.text.setPosition(item.card.x + 30, item.card.y + 40 + 10);
        if (item.lock != null) {
            item.lock.visible = !unlocked;
            if (item.lock.visible) {
                item.lock.setPosition(item.card.x + item.card.width/2 - item.lock.width/2, item.text.y - item.lock.height - 5);
                item.lock.alpha = 1.0;
            }
        }
        if (i == curSelected) {
            item.icon.scale.set(scale - 0.1, scale - 0.1);
            item.icon.origin.set(item.icon.width/2 - 10, item.icon.height/2 - 15);
            item.icon.x = disk.x + 10 + disk.width/2 - item.icon.width/2;
            item.icon.y = disk.y + 15 + disk.height/2 - item.icon.height/2;
            item.icon.angle = disk.angle;
        }
    }
}

function beatHit() {
    if (difficultyIcons.length > currentDifficulty) {
        var ic = difficultyIcons[currentDifficulty];
        FlxTween.cancelTweensOf(ic.scale);
        ic.scale.set(0.7, 0.7);
        FlxTween.tween(ic.scale, {x: 0.6, y: 0.6}, 0.2, {ease: FlxEase.quadOut});
    }
    FlxTween.cancelTweensOf(tilesThing.scale);
    tilesThing.scale.set(0.72, 0.72);
    FlxTween.tween(tilesThing.scale, {x: 0.7, y: 0.7}, 0.3, {ease: FlxEase.circOut});
    if (cards.length > 0 && cards[curSelected] != null) {
        var ic = cards[curSelected].icon;
        FlxTween.cancelTweensOf(ic.scale);
        ic.scale.set(1.1, 1.1);
        FlxTween.tween(ic.scale, {x: 0.9, y: 0.9}, 0.2, {ease: FlxEase.quadOut});
    }
}

// updateCharacter 增加 forceNormal 参数，用于强制显示正常（已游玩）样式
function updateCharacter(isConfirm:Bool, forceNormal:Bool = false) {
    if (songs.length == 0 || !isVisible(curSelected)) {
        characterImage.visible = false;
        characterImage2.visible = false;
        return;
    }
    var unlocked = songUnlocked[curSelected];
    var scored = songScored[curSelected];
    if (forceNormal) {
        unlocked = true;
        scored = true;
    }
    var data = characterMap.get(songs[curSelected].name.toLowerCase());
    if (data != null) {
        characterImage.loadGraphic(Paths.image('menus/freeplay/' + data.image));
        characterImage.antialiasing = Options.antialiasing; // 确保抗锯齿
        if (unlocked && scored) {
            characterImage.color = FlxColor.WHITE;
            characterImage.shader = null;
            characterImage.alpha = 1.0;
        } else {
            characterImage.color = FlxColor.BLACK;
            characterImage.shader = blurShader35;
            characterImage.alpha = 0.85;
        }
        targetCharX = data.x;
        targetCharY = data.y;
        if (!isConfirm) characterImage.x = targetCharX;
        if (!characterImage.visible) characterImage.visible = true;

        if (data.image2 != null) {
            characterImage2.loadGraphic(Paths.image('menus/freeplay/' + data.image2));
            characterImage2.antialiasing = Options.antialiasing;
            if (unlocked && scored) {
                characterImage2.color = FlxColor.WHITE;
                characterImage2.shader = null;
                characterImage2.alpha = 1.0;
            } else {
                characterImage2.color = FlxColor.BLACK;
                characterImage2.shader = blurShader35;
                characterImage2.alpha = 0.85;
            }
            var tX2 = data.x2 ?? targetCharX + 200;
            var tY2 = data.y2 ?? targetCharY;
            if (!isConfirm) characterImage2.x = tX2;
            if (!characterImage2.visible) characterImage2.visible = true;
        } else {
            characterImage2.visible = false;
        }

        if (!isConfirm) {
            characterImage.alpha = 0;
            characterImage.y = targetCharY + 50;
            FlxTween.cancelTweensOf(characterImage);
            FlxTween.tween(characterImage, {alpha: (unlocked && scored ? 1.0 : 0.85), y: targetCharY}, 0.4, {ease: FlxEase.quartOut});
            if (data.image2 != null) {
                characterImage2.alpha = 0;
                characterImage2.y = (data.y2 ?? targetCharY) + 50;
                FlxTween.cancelTweensOf(characterImage2);
                FlxTween.tween(characterImage2, {alpha: (unlocked && scored ? 1.0 : 0.85), y: (data.y2 ?? targetCharY)}, 0.4, {ease: FlxEase.quartOut});
            }
        } else {
            FlxTween.cancelTweensOf(characterImage.scale);
            characterImage.scale.set(1.1, 1.1);
            FlxTween.tween(characterImage.scale, {x: 1, y: 1}, 0.4, {ease: FlxEase.backOut});
            if (data.image2 != null) {
                FlxTween.cancelTweensOf(characterImage2.scale);
                characterImage2.scale.set(1.1, 1.1);
                FlxTween.tween(characterImage2.scale, {x: 1, y: 1}, 0.4, {ease: FlxEase.backOut});
            }
        }
    } else {
        characterImage.visible = false;
        characterImage2.visible = false;
    }
}

// selectSong 修改：点击瞬间立刻恢复正常视觉，并正确处理未游玩歌曲的过渡
function selectSong() {
    if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length || songs[curSelected] == null) return;
    if (!isVisible(curSelected) || !songUnlocked[curSelected]) {
        locked.play();
        lockShakeTimer = 0.25;
        return;
    }
    if (lockShakeTimer > 0) return;

    selectedSong = curSelected;
    canInteract = false;
    FlxG.sound.music.pitch = 1;

    // 立即恢复正常视觉（无论是否已游玩）
    if (songUnlocked[curSelected]) {
        var item = cards[curSelected];
        if (item != null) {
            item.card.color = songs[curSelected].color;
            item.card.alpha = 1.0;
            item.text.text = songs[curSelected].displayName;
            item.text.alpha = 1.0;
            item.icon.color = FlxColor.WHITE;
            item.icon.shader = null;
            if (item.lock != null) item.lock.visible = false;
        }

        // 强制角色恢复正常（无模糊、无黑色）
        if (characterImage != null && characterImage.visible) {
            characterImage.color = FlxColor.WHITE;
            characterImage.shader = null;
            characterImage.alpha = 1.0;
        }
        if (characterImage2 != null && characterImage2.visible) {
            characterImage2.color = FlxColor.WHITE;
            characterImage2.shader = null;
            characterImage2.alpha = 1.0;
        }

        updateScore(); // 立即刷新左下角准确率
    }

    if (!songScored[curSelected]) {
        confirm.play();
        FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.3, {ease: FlxEase.expoOut});
        FlxG.camera.fade(FlxColor.WHITE, 0.2, true);
        new FlxTimer().start(0.2, _ -> {
            // 同步一次确保视觉正确
            var item = cards[curSelected];
            if (item != null) {
                item.card.color = songs[curSelected].color;
                item.card.alpha = 1.0;
                item.text.text = songs[curSelected].displayName;
                item.text.alpha = 1.0;
                item.icon.color = FlxColor.WHITE;
                item.icon.shader = null;
                if (item.lock != null) item.lock.visible = false;
            }
            // 强制角色播放选中动画且保持正常样式
            updateCharacter(true, true);
            new FlxTimer().start(0.5, _ -> startSong());
        });
    } else {
        confirm.play();
        updateCharacter(true);
        if (cards[curSelected] != null)
            FlxTween.tween(cards[curSelected].card.scale, {x: 1.1, y: 1.1}, 0.1, {ease: FlxEase.backOut, type: FlxTween.PINGPONG});
        if (Options.flashingMenu)
            FlxG.camera.fade(FlxColor.WHITE, 0.8, true);
        FlxG.camera.zoom = 1;
        FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.expoOut});
        new FlxTimer().start(1, _ -> startSong());
    }
}

function startSong() {
    Options.freeplayLastSong = songs[curSelected].name;
    var diffs = songs[curSelected].difficulties;
    if (diffs != null && diffs.length > 0 && difficulties != null) {
        var diff = (currentDifficulty < difficulties.length) ? difficulties[currentDifficulty] : difficulties[0];
        Options.freeplayLastDifficulty = diff;
        PlayState.loadSong(songs[curSelected].name, diff, false, false);
        FlxG.switchState(new PlayState());
    } else trace("Error: Cannot load song due to missing difficulty data.");
}

function checkCreepyState() {
    if (songs.length == 0 || songs[curSelected] == null) return;
    inCreepyMode = scarySongs.contains(songs[curSelected].name.toLowerCase()) && custardPlayed;
    targetPitch = inCreepyMode ? 0.6 : 1.0;
}

function changeSelection(change:Int = 0, force:Bool = false) {
    if (songs.length == 0) {
        glowyThing.visible = characterImage.visible = characterImage2.visible = false;
        updateScore();
        return;
    }
    var ns = curSelected + change;
    if (ns < 0) ns = 0;
    if (ns >= songs.length) ns = songs.length - 1;
    var step = change > 0 ? 1 : -1;
    while (ns >= 0 && ns < songs.length && !isVisible(ns)) ns += step;
    if (ns < 0) ns = 0;
    if (ns >= songs.length) ns = songs.length - 1;
    if (!isVisible(ns) || (ns == curSelected && !force)) return;
    curSelected = ns;
    if (!force) CoolUtil.playMenuSFX();
    checkCreepyState();
    glowyThing.visible = true;
    glowyThing.alpha = 0;
    FlxTween.cancelTweensOf(glowyThing);
    FlxTween.tween(glowyThing, {alpha: 0.6}, 0.4);
    if (charTween != null) charTween.cancel();
    updateCharacter(false);
    updateScore();
}

function addCard(songIdx:Int) {
    if (songIdx < 0 || songIdx >= songs.length) return;
    var unlocked = songUnlocked[songIdx];
    var scored = songScored[songIdx];
    var visible = isVisible(songIdx);
    var card = new FlxSprite(250, 0).loadGraphic(Paths.image('menus/freeplay/songPanel'));
    card.visible = visible;
    card.color = (unlocked && scored) ? songs[songIdx].color : 0xFF333333;
    card.alpha = (unlocked && scored) ? 1.0 : 0.6;
    card.antialiasing = Options.antialiasing;
    backgroundGroup.add(card);

    var txt = (unlocked && scored) ? songs[songIdx].displayName : "???";
    var songText = new FlxText(-5000, 20, 550, txt, 48);
    songText.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 60, FlxColor.WHITE, "center");
    songText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    songText.alpha = (unlocked && scored) ? 1.0 : 0.6;
    songText.visible = visible;
    songText.antialiasing = Options.antialiasing;
    midgroundGroup.add(songText);

    var icon = new HealthIcon(songs[songIdx].icon);
    icon.scale.set(0.9, 0.9);
    icon.visible = visible;
    icon.antialiasing = Options.antialiasing;
    if (unlocked && scored) {
        icon.color = FlxColor.WHITE;
        icon.shader = null;
    } else {
        icon.color = FlxColor.BLACK;
        icon.shader = blurShader2;
    }
    foregroundGroup.add(icon);

    var lockImg = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/lock'));
    lockImg.visible = visible && !unlocked;
    lockImg.antialiasing = Options.antialiasing;
    lockImg.alpha = 1.0;
    midgroundGroup.add(lockImg);

    cards.push({ card: card, text: songText, icon: icon, lock: lockImg });

    var ch = FlxG.height * 0.40;
    var ty = songIdx - curSelected;
    card.setPosition(-ty * ty * 20 + 50, ty * 170 + ch);
    songText.setPosition(card.x + 30, card.y + 40 + 10);
    lockImg.setPosition(card.x + card.width/2 - lockImg.width/2, songText.y - lockImg.height - 5);
}

function changeDifficulty(change:Int) {
    difficultyIcons[currentDifficulty].visible = false;
    currentDifficulty = FlxMath.wrap(currentDifficulty + change, 0, difficulties.length - 1);
    var icon = difficultyIcons[currentDifficulty];
    icon.visible = true;
    icon.scale.set(0.4, 0.4);
    FlxTween.cancelTweensOf(icon.scale);
    FlxTween.tween(icon.scale, {x: 0.6, y: 0.6}, 0.2, {ease: FlxEase.backOut});
    updateScore();
}

function updateScore() {
    if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length) {
        accuracyText.text = "准度: 0% (?)";
        accuracyRank = "未/记"; intendedAccuracy = 0; return;
    }
    if (!isVisible(curSelected) || !songUnlocked[curSelected]) {
        accuracyText.text = "未解锁";
        intendedAccuracy = 0; lerpAccuracy = 0; return;
    }
    var diff = (currentDifficulty < difficulties.length) ? difficulties[currentDifficulty] : "NORMAL";
    var acc = 0;
    var searchDiffs = [diff, diff.toLowerCase(), diff.toUpperCase(), ""];
    for (d in searchDiffs) {
        var sd = FunkinSave.getSongHighscore(songs[curSelected].name, d);
        if (sd != null && (sd.score > 0 || sd.accuracy > 0)) {
            acc = Math.floor(sd.accuracy * 100);
            break;
        }
    }
    intendedAccuracy = acc;

    if (intendedAccuracy == 0) accuracyRank = "?";
    else if (intendedAccuracy >= 100) accuracyRank = "S++";
    else if (intendedAccuracy >= 95) accuracyRank = "S";
    else if (intendedAccuracy >= 90) accuracyRank = "A";
    else if (intendedAccuracy >= 85) accuracyRank = "B";
    else if (intendedAccuracy >= 80) accuracyRank = "C";
    else if (intendedAccuracy >= 70) accuracyRank = "D";
    else if (intendedAccuracy >= 50) accuracyRank = "E";
    else accuracyRank = "F";
}

function performGoBack() {
    cancel.play();
    FlxG.sound.music.pitch = 1;
    FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.5, {ease: FlxEase.expoIn});
    FlxG.camera.fade(FlxColor.BLACK, 0.5, false);
    new FlxTimer().start(0.5, _ -> FlxG.switchState(new MainMenuState()));
}