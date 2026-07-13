import haxe.io.Path;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.backend.system.Logs;
import funkin.backend.utils.FlxInterpolateColor;
import hxvlc.flixel.FlxVideoSprite;
import StringTools;
import flixel.util.FlxColor;
import haxe.Timer;
import funkin.ui.FunkinText;

var callback:Void->Void = null;
var vid:FlxVideoSprite;
var cutsceneCamera:FlxCamera = null;
var oldVisible = [];
var vidName:String;
var G = null;

// 三次点击跳过相关
var skipText:FunkinText;
var clicksRemaining:Int = 3;
var skipTimer:Float = 0;        // 阶段计时器
var skipPhase:Int = 0;          // 0:等待0.5s, 1:淡出中(0.5s), -1:完全隐藏
var skipAlpha:Float = 1;

function startVideo(name:String, ?leCallback:Void->Void, ?ext:String, ?usePath:Bool) {
    G = false;
    vidName = name;

    // 保存所有摄像机的可见性并隐藏
    for (cam in FlxG.cameras.list) {
        oldVisible.push(cam.visible);
        cam.visible = false;
    }

    callback = leCallback;
    ext ??= "mp4";
    
    FlxG.save.flush();

    cutsceneCamera = new FlxCamera();
    cutsceneCamera.bgColor = 0xFF000000;
    FlxG.cameras.add(cutsceneCamera, false);

    add(vid = new FlxVideoSprite());
    vid.cameras = [cutsceneCamera];
    vid.antialiasing = CoolUtil.coolTextFile(Paths.video("nonPixelyCutscenes", "txt")).contains(new Path(name).file);
    vid.bitmap.onFormatSetup.add(function() if (vid.bitmap?.bitmapData != null) {
        final width = vid.bitmap.bitmapData.width;
        final height = vid.bitmap.bitmapData.height;
        final scale:Float = Math.min(FlxG.width / width, FlxG.height / height);
        vid.setGraphicSize(Std.int(width * scale), Std.int(height * scale));
        vid.updateHitbox();
        vid.screenCenter();
    });

    // 创建右上角跳过提示文字（英文）
    skipText = new FunkinText(0, 0, 0, 'Skip: $clicksRemaining clicks remaining', 36);
    skipText.setFormat(Paths.font("Tardling-Outline.ttf"), 36, FlxColor.WHITE, "right", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    skipText.borderSize = 2;
    skipText.antialiasing = true;
    skipText.cameras = [cutsceneCamera];
    skipText.alpha = 1;
    // 初始状态
    clicksRemaining = 3;
    skipAlpha = 1;
    skipPhase = 0;
    skipTimer = 0;
    add(skipText);

    if (vid.load(usePath == false ? Paths.video(name, ext) : name)) {
        vid.bitmap.onEndReached.add(onFinish);
        vid.play();
    } else {
        Logs.trace("Failed to load the cutscene, finishing directly!!", 2);
        onFinish();
    }
}

function update(elapsed:Float) {
    try {botplayV = G;} catch (e:Dynamic) {}
    if (vid == null) return;

    // 音量控制
    if (!vid.autoVolumeHandle) {
        vid.bitmap.volume = Math.floor(FlxMath.bound(getCalculatedVolume() * 3, 0, 1) * 100);
    }

    // 更新跳过提示的位置
    if (skipText != null) {
        skipText.x = FlxG.width - skipText.width - 20;
        skipText.y = 20;
    }

    // ========== 计时与透明度逻辑 ==========
    if (skipPhase != -1) {
        skipTimer += elapsed;

        if (skipPhase == 0 && skipTimer >= 0.5) {
            skipPhase = 1;
            skipTimer = 0;
        }

        if (skipPhase == 1) {
            skipAlpha = 1 - (skipTimer / 0.5);
            if (skipAlpha <= 0) {
                skipAlpha = 0;
                skipPhase = -1;
                clicksRemaining = 3;
                updateSkipText();
            }
        }
    }
    if (skipText != null) skipText.alpha = skipAlpha;

    // 鼠标点击任意位置（释放时）处理
    if (FlxG.mouse.justReleased) {
        handleSkipClick();
    }

    // 键盘回车直接跳过（保留）
    if (FlxG.keys.justPressed.ENTER) {
        onFinish();
    }
}

function handleSkipClick() {
    if (clicksRemaining > 1) {
        clicksRemaining--;
        // 重置计时，立即显示
        skipAlpha = 1;
        skipTimer = 0;
        skipPhase = 0;
        updateSkipText();
    } else if (clicksRemaining == 1) {
        onFinish();
    }
    // 如果处于完全隐藏状态 (clicksRemaining == 3)，点击后会进入上面的 >1 分支，减为2并重新计时
}

function updateSkipText() {
    if (skipText != null) {
        skipText.text = 'Skip: $clicksRemaining clicks remaining';
        skipText.x = FlxG.width - skipText.width - 20;
        skipText.y = 20;
    }
}

function getCalculatedVolume() {
    return (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume;
}

function onFinish() {
    G = true;
    if (skipText != null) {
        skipText.destroy();
        skipText = null;
    }
    if (vid != null) {
        vid.destroy();
        vid = null;
    }
    
    if (cutsceneCamera != null) {
        FlxG.cameras.remove(cutsceneCamera, true);
        cutsceneCamera = null;
    }

    botplayV = true;

    // 恢复其他摄像机可见性
    if (!StringTools.contains(vidName, "end-cutscene")) {
        for (i => cam in FlxG.cameras.list) {
            cam.visible = oldVisible[i] ?? true;
        }
    }
    
    if (callback != null) callback();
}