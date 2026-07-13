import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import funkin.game.PlayState;
import lime.graphics.Image;
import openfl.text.TextFormat;
import funkin.backend.system.framerate.FramerateCounter;
import funkin.backend.utils.NativeAPI;
import funkin.backend.utils.HttpUtil;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.utils.WindowUtils;

#if desktop
    var normalPixels:flixel.graphics.FlxGraphic;
    var pressedPixels:flixel.graphics.FlxGraphic;
#end
#if mobile
    var normalPixels:flixel.graphics.FlxGraphic;
    var pressedPixels:flixel.graphics.FlxGraphic;
    var mouseShown:Bool = false;   // 手机端是否已被右键呼出
#end

function new() {
    FlxG.cameras.add(HUDcam = new HudCamera(), false);
    HUDcam.bgColor = 0x00000000;
    
    HUDcam.visible = false;
    
    // 加载鼠标图片
    var normalSprite = new FlxSprite().loadGraphic(Paths.image('mouse/cursor1'));
    var pressedSprite = new FlxSprite().loadGraphic(Paths.image('mouse/cursor2'));
    normalPixels = normalSprite.pixels;
    pressedPixels = pressedSprite.pixels;
    
    FlxG.mouse.useSystemCursor = false;
    FlxG.mouse.load(normalPixels, 0.7, 1, -11);
    
    #if mobile
        mouseShown = false;
        // 初始隐藏，后续每帧会强制设置
    #end
}

function update(elapsed:Float) {
    var isPlayState = Std.isOfType(FlxG.state, PlayState);
    
    // ---------- 1. 手机端右键呼出（仅在非 PlayState 且未呼出时）----------
    #if mobile
        if (FlxG.mouse.justPressedRight && !isPlayState && !mouseShown) {
            mouseShown = true;
        }
    #end
    
    // ---------- 2. 每帧强制设置鼠标可见性（防篡改）----------
    if (isPlayState) {
        FlxG.mouse.visible = false;   // 游戏中强制隐藏
    } else {
        #if desktop
            FlxG.mouse.visible = true;      // 桌面端总是显示
        #elseif mobile
            FlxG.mouse.visible = mouseShown; // 手机端依右键呼出状态
        #end
    }
    
    // ---------- 3. 左键按下/释放切换图片（无条件执行）----------
    if (FlxG.mouse.pressed) {
        if (FlxG.mouse.currentCursorGraphic != pressedPixels) {
            FlxG.mouse.load(pressedPixels, 0.7, 1, -11);
        }
    }else{   
        FlxG.mouse.load(normalPixels, 0.7, 1, -11);
    }
}
function preStateSwitch() {
    Framerate.codenameBuildField.text = 'Tubby Night Funkin\nMIOM.MobileBuild-Demo';
    Framerate.codenameBuildField.textColor = 0x02cb4c6;
    Framerate.fpsCounter.fpsNum.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('FridayNightFunkin-Regulare.ttf')), 24);
    Framerate.fpsCounter.fpsLabel.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('FridayNightFunkin-Regulare.ttf')), 16);
    Framerate.memoryCounter.memoryText.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('FridayNightFunkin-Regulare.ttf')), 12);
    Framerate.memoryCounter.memoryPeakText.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('FridayNightFunkin-Regulare.ttf')), 12);
    Framerate.codenameBuildField.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('FridayNightFunkin-Regulare.ttf')), 12);
}