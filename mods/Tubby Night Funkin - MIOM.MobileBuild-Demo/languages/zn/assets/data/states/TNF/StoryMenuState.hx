import haxe.io.Path;
import sys.FileSystem;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.week.Week;
import funkin.savedata.FunkinSave;
import flixel.text.FlxTextBorderStyle as Border;
import flixel.text.FlxTextBorderStyle;

// ========== 测试模式已删除 ==========

var weeks:Array<Week> = ['tinky', 'laa-laa-dipsy', 'po'].map(name -> Week.loadWeek(name, true));
var curWeek:Int = 0, curDifficulty:Int = 1, canSelect:Bool = true, ogVol:Float = FlxG.sound.music?.volume ?? 1;
var lerpScore:Float = 0, intendedScore:Int = 0;
public static var lastWeek:Int = 0;
public static var lastDifficulty:Int = 1;

var locked:Array<Bool> = [];

var upArrow:FunkinSprite;
var downArrow:FunkinSprite;

// Back 按钮
var backButton:FunkinText;
var bottomText:FlxBackdrop;

// ----- 鼠标拖拽/释放状态 -----
var pendingWeekChange:Null<Int> = null;     // 记录按下的区域：-1左，0中，1右
var pendingDiffChange:Null<Int> = null;     // 记录按下的箭头：-1下, 1上
var pendingBack:Bool = false;               // 记录Back按钮是否被按下

// 用于箭头鼠标点击动画
var upArrowPressed:Bool = false;
var downArrowPressed:Bool = false;

// ===== “po”角色偏移量（可随意修改）=====
var poXOffset:Int = 0;   // 向右移动的像素数（默认为120）
var poYOffset:Int = 0;    // 向下移动的像素数（默认为20）

for (a in ['backgrounds', 'text'])
    for (file in Paths.getFolderContent('images/menus/storymenu/' + a))
        graphicCache.cache(Paths.image('menus/storymenu/' + a + '/' + Path.withoutExtension(file)));

for (file in ['normal', 'hard', 'easy', 'assets'])
    graphicCache.cache(Paths.image('menus/freeplay/' + file));

function create() {

    CoolUtil.playMenuSong();
    FlxG.sound.music.volume = ogVol;

    curDifficulty = lastDifficulty;

    add(bg = new FunkinSprite(0, 0, Paths.image('menus/storymenu/backgrounds/tinky-bg'))).setGraphicSize(1280, 720);
    bg.screenCenter();

    add(overlay = new FunkinSprite(0, 0, Paths.image('menus/storymenu/backgrounds/tinky-overlay'))).setGraphicSize(1280, 720);
    overlay.screenCenter();
    overlay.blend = 0;

    add(bar = new FunkinSprite().makeSolid(FlxG.width, FlxG.height*0.5, FlxColor.BLACK)).screenCenter();
    bar.onDraw = (spr:FunkinSprite) -> {
        for (y in [FlxG.height - spr.height * 0.2, -spr.height * 0.8]) {
            spr.y = y; spr.draw();
        }
    };

    add(chars = new FlxTypedGroup());
    for (a in 0...weeks.length) {
        // 直接使用真实解锁条件
        var unlocked:Bool = isUnlocked(a);
        locked[a] = !unlocked;

        // 计算初始 X 坐标，如果是“po”则加上偏移量
        var startX = 240 + 324 * (a - lastWeek);
        var startY = -111;   // 基础Y坐标
        
        if (weeks[a].id == 'po') {
            startX += poXOffset;
            startY += poYOffset;
        }

        chars.add(char = new FunkinSprite(startX, startY, Paths.image('menus/storymenu/characters/' + (locked[a] ? 'locked' : weeks[a].id))));
        char.addAnim('idle', 'idle', 24, true);
        if (unlocked) char.addAnim('confirm', 'confirm', 24);
        char.playAnim('idle');
        char.antialiasing = Options.antialiasing;
        char.scale.set(0.7 - Math.abs(a - lastWeek) * 0.1, 0.7 - Math.abs(a - lastWeek) * 0.1);
        char.ID = a;
    }

    for (a in 0...2) {
        insert(members.indexOf(bar)+1, txt = new FlxBackdrop(Paths.image('menus/storymenu/text/' + weeks[0].id + '-text'), FlxAxes.X)).velocity.set(a == 1 ? 200 : -200);
        txt.antialiasing = Options.antialiasing;
        txt.spacing.set(40, 0);
        txt.scale.set(0.88, 0.88);
        txt.y = a == 1 ? -2 : FlxG.height - txt.height -2;
        if (a == 1) bottomText = txt;
    }

    add(selected = new FunkinSprite(362, -100, Paths.image('menus/storymenu/selected'))).scale.set(0.73, 0.73);
    selected.addAnim('idle', 'idle', 24, true); 
    selected.playAnim('idle'); 

    add(diffBG = new FunkinSprite(-250, 500, Paths.image('menus/storymenu/diff-bar'))).scale.set(0.75, 0.75);
    diffBG.screenCenter(FlxAxes.Y);

    add(diff = new FunkinSprite(10, 210, Paths.image('menus/freeplay/' + weeks[curWeek].difficulties[curDifficulty].toLowerCase()))).scale.set(0.62, 0.62);
    diff.updateHitbox();

    // 上下箭头图标
    upArrow = new FunkinSprite(100, 100, Paths.image('menus/freeplay/assets'));
    upArrow.addAnim('idle', 'arrow left');
    upArrow.addAnim('push', 'arrow push left');
    upArrow.angle = 90;
    upArrow.antialiasing = Options.antialiasing;
    add(upArrow);

    downArrow = new FunkinSprite(200, 100, Paths.image('menus/freeplay/assets'));
    downArrow.addAnim('idle', 'arrow left');
    downArrow.addAnim('push', 'arrow push left');
    downArrow.angle = -90;
    downArrow.antialiasing = Options.antialiasing;
    add(downArrow);

    add(weekScore = new FunkinText(10, 290, FlxG.width, '周分数: 0')).setFormat(Paths.font('VCR.ttf'), 35, -1, 'left', Border.OUTLINE, FlxColor.BLACK).borderSize = 2;

    // Back 按钮
    var btnHeight = 64;
    var spacing = 5;
    var btnY = FlxG.height - bottomText.height - btnHeight - spacing;
    backButton = new FunkinText(15, 550, 0, "返回", 64);
    backButton.setFormat(Paths.font("HanYiCaiYunTiJian.ttf"), 64, FlxColor.BLACK, "left");
    backButton.scrollFactor.set(0, 0);
    backButton.antialiasing = Options.antialiasing;
    backButton.borderStyle = FlxTextBorderStyle.NONE;
    add(backButton);

    FlxG.state.forEachOfType(FlxBasic, a -> if (Std.isOfType(a, FunkinSprite)) a.antialiasing = Options.antialiasing);
    changeWeek(lastWeek);
}

function update(elapsed:Float) {
    lerpScore = lerp(lerpScore, intendedScore, 0.5);
    weekScore.text = '周分数: ' + Math.round(lerpScore);

    for (a in 0...chars.length) {
        var scaleFactor = Math.max(0, 0.6 - chars.members[a].scale.x) * 200;
        
        // 计算目标 X 坐标，如果是“po”则加上偏移量（Y坐标不变，保持初始偏移）
        var targetX = 240 + (348 - scaleFactor) * (a - curWeek);
        if (weeks[a].id == 'po') targetX += poXOffset;
        
        chars.members[a].x = lerp(chars.members[a].x, targetX, 0.13);
        chars.members[a].scale.x = chars.members[a].scale.y = lerp(chars.members[a].scale.x, a == curWeek ? 0.7 : 0.7 - Math.abs(a - curWeek) * 0.1, 0.13);
        if (!canSelect) chars.members[a].alpha = lerp(chars.members[a].alpha, a == curWeek ? 1 : 0, 0.1);
    }

    diff.scale.x = diff.scale.y = lerp(diff.scale.x, 0.62, 0.2);

    // ----- 鼠标按下时记录动作 -----
    if (FlxG.mouse.justPressed && canSelect) {
        // 检查Back按钮
        if (FlxG.mouse.overlaps(backButton)) {
            pendingBack = true;
        }
        // 检查箭头
        else if (FlxG.mouse.overlaps(upArrow)) {
            pendingDiffChange = 1;
            upArrowPressed = true;
        }
        else if (FlxG.mouse.overlaps(downArrow)) {
            pendingDiffChange = -1;
            downArrowPressed = true;
        }
        // 检查屏幕三分区域（避开按钮区域）
        else {
            var clickedOnBack = FlxG.mouse.overlaps(backButton);
            var clickedOnArrow = FlxG.mouse.overlaps(upArrow) || FlxG.mouse.overlaps(downArrow);
            if (!clickedOnBack && !clickedOnArrow) {
                var zoneWidth = FlxG.width * 0.5;
                var zoneLeft = (FlxG.width - zoneWidth) / 2;
                var zoneRight = zoneLeft + zoneWidth;
                var mouseX = FlxG.mouse.screenX;
                if (mouseX >= zoneLeft && mouseX <= zoneRight) {
                    var third = zoneWidth / 3;
                    if (mouseX < zoneLeft + third) pendingWeekChange = -1;
                    else if (mouseX < zoneLeft + 2 * third) pendingWeekChange = 0;
                    else pendingWeekChange = 1;
                }
            }
        }
    }

    // ----- 鼠标释放时根据记录执行动作（仅当仍在相同元素上）-----
    if (FlxG.mouse.justReleased && canSelect) {
        // Back按钮
        if (pendingBack && FlxG.mouse.overlaps(backButton)) {
            goBack();
        }
        // 难度箭头
        if (pendingDiffChange != null) {
            var stillOver = (pendingDiffChange == 1 && FlxG.mouse.overlaps(upArrow)) ||
                            (pendingDiffChange == -1 && FlxG.mouse.overlaps(downArrow));
            if (stillOver) changeDifficulty(pendingDiffChange);
        }
        // 三分区域
        if (pendingWeekChange != null) {
            var zoneWidth = FlxG.width * 0.5;
            var zoneLeft = (FlxG.width - zoneWidth) / 2;
            var zoneRight = zoneLeft + zoneWidth;
            var mouseX = FlxG.mouse.screenX;
            var inZone = (mouseX >= zoneLeft && mouseX <= zoneRight);
            if (inZone) {
                var third = zoneWidth / 3;
                var currentArea = (mouseX < zoneLeft + third) ? -1 : (mouseX < zoneLeft + 2*third) ? 0 : 1;
                if (currentArea == pendingWeekChange) {
                    if (pendingWeekChange == 0) {
                        if (!locked[curWeek]) selectWeek();
                        else CoolUtil.playMenuSFX(3);
                    } else {
                        changeWeek(pendingWeekChange);
                    }
                }
            }
        }
        // 清除记录
        pendingWeekChange = null;
        pendingDiffChange = null;
        pendingBack = false;
        upArrowPressed = false;
        downArrowPressed = false;
    }

    // 箭头动画（按下时显示push，基于记录的状态）
    upArrow.animation.play((pendingDiffChange == 1 && upArrowPressed) ? 'push' : 'idle');
    downArrow.animation.play((pendingDiffChange == -1 && downArrowPressed) ? 'push' : 'idle');

    // Back 按钮视觉效果（鼠标悬停）
    var mouseOverBack = FlxG.mouse.overlaps(backButton);
    if (mouseOverBack) {
        backButton.color = FlxColor.WHITE;
        backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        backButton.borderColor = FlxColor.BLACK;
        backButton.borderSize = 3;
    } else {
        backButton.color = FlxColor.BLACK;
        backButton.borderStyle = FlxTextBorderStyle.NONE;
    }

    if (!canSelect) {
        for (a in [bg,overlay]) a.alpha = lerp(a.alpha, 0.2, 0.05);
        return;
    }

    // ----- 键盘操作改为“释放时触发” -----
    if (canSelect) {
        if (FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT || FlxG.mouse.wheel != 0) {
            var dir = (FlxG.keys.justReleased.LEFT || FlxG.mouse.wheel > 0) ? -1 : 1;
            changeWeek(dir);
        }
        if (FlxG.keys.justReleased.UP || FlxG.keys.justReleased.DOWN) {
            var dir = FlxG.keys.justReleased.UP ? 1 : -1;
            changeDifficulty(dir);
        }
        if (FlxG.keys.justReleased.SPACE || FlxG.keys.justReleased.ENTER) {
            if (!locked[curWeek]) selectWeek();
            else CoolUtil.playMenuSFX(3);
        }
        if (FlxG.keys.justReleased.ESCAPE) {
            goBack();
        }
    }
}

function goBack() {
    CoolUtil.playMenuSFX(2);
    FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.5, {ease: FlxEase.expoIn});
    FlxG.camera.fade(FlxColor.BLACK, 0.5, false);
    new FlxTimer().start(0.5, function(tmr:FlxTimer) FlxG.switchState(new MainMenuState()));
}

function updateSelection() {
    for (a in [for (s in FlxG.state.members) if (Std.isOfType(s,FlxBackdrop)) s]) a.loadGraphic(Paths.image('menus/storymenu/text/' + weeks[curWeek].id + '-text'));
    for (a in [bg,overlay]) {
        a.loadGraphic(Paths.image('menus/storymenu/backgrounds/' + weeks[curWeek].id + (a == bg ? '-bg' : '-overlay'))).setGraphicSize(1280,720);
        a.screenCenter();
    }
}

function changeWeek(change:Int) {
    var newWeek = FlxMath.wrap(curWeek + change, 0, weeks.length - 1);
    if (locked[newWeek]) return;
    curWeek = newWeek;
    CoolUtil.playMenuSFX();
    updateSelection();
    updateScore();
}

function changeDifficulty(change:Int) {
    curDifficulty = FlxMath.wrap(curDifficulty + change, 0, weeks[curWeek].difficulties.length - 1);
    diff.loadGraphic(Paths.image('menus/freeplay/' + weeks[curWeek].difficulties[curDifficulty].toLowerCase())).updateHitbox();
    diff.scale.set(0.68, 0.7);
    CoolUtil.playMenuSFX();
    updateScore();
}

function updateScore()
    intendedScore = FunkinSave.getWeekHighscore(weeks[curWeek].id, weeks[curWeek].difficulties[curDifficulty]).score;

import funkin.backend.MusicBeatTransition; 

function selectWeek() {
    if (locked[curWeek]) return;
    canSelect = false;
    if (Options.flashingMenu) FlxG.camera.flash(-1, 1);

    MusicBeatTransition.script = 'data/stickerTransition.hx';

    lastWeek = curWeek;
    lastDifficulty = curDifficulty;

    for (char in chars) if (char.ID == curWeek) char.playAnim('confirm');
    
    PlayState.loadWeek(weeks[curWeek], weeks[curWeek].difficulties[curDifficulty]);

    CoolUtil.playMenuSFX(1).onComplete = () -> {
        FlxG.switchState(new PlayState());
    };
}

function isUnlocked(week) return week == 0 || [for (diff in weeks[week-1].difficulties) FunkinSave.getWeekHighscore(weeks[week-1].id, diff).score > 0].contains(true);
function destroy() FlxG.sound.music?.volume = ogVol;