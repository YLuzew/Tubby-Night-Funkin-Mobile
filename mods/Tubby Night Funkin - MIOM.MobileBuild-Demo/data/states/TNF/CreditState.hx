import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import funkin.backend.utils.DiscordUtil;
import openfl.utils.Assets;
import flixel.math.FlxRect;
import flixel.util.FlxGradient;
import funkin.backend.shaders.CustomShader;
import openfl.display3D.Context3DWrapMode;
import openfl.system.System;
import flixel.text.FlxTextBorderStyle;

var rawCredits:Array = Json.parse(Assets.getText(Paths.json('config/credits')));
var creditsData:Array<Dynamic> = [];
var GRID_COLS:Int = 4;
var ICON_SIZE:Int = 120;
var PADDING:Int = 15;
var GRID_START_X:Float = 540;
var GRID_START_Y:Float = 190;
var MASK_Y:Float = 165;

var curSelected:Int = 0;
var iconGroup:FlxTypedGroup<FlxSprite>;

var nameText:FlxText;
var roleText:FlxText;
var descText:FlxText;
var quoteText:FlxText;
var socialText:FlxText;

var socialSprites:Array<{spr:FlxSprite, type:String}> = [];
var ytSprite:FlxSprite;
var instaSprite:FlxSprite;
var twitterSprite:FlxSprite;
var tiktokSprite:FlxSprite;
var biliSprite:FlxSprite;

var bg:FlxSprite; 
var whiteOverlay:FlxSprite;
var bgSwirl:FlxSprite;
var dots:FlxSprite;
var iconbox:FlxSprite;
var textbox:FlxSprite;
var myShader:CustomShader;
var rotShader:CustomShader;

var targetColor:FlxColor = 0xFFFFFFFF;
var actualColor:FlxColor = 0xFFFFFFFF;

var lastMouseX:Float = 0.0;
var lastMouseY:Float = 0.0;
var currentTimeSpeed:Float = 1.0;
var intensity:Float = 0.001;
var invW:Float = 0.0;
var invH:Float = 0.0;

var targetHue:Float = 0.0;
var currentHue:Float = 0.0;
var rotationTime:Float = 0;

var isDragging:Bool = false;
var dragStartY:Float = 0;
var dragStartCamY:Float = 0;
var velocity:Float = 0;
var targetCamY:Float = 0;
var minCamY:Float = 0;
var maxCamY:Float = 0;
var autoFollowSelection:Bool = true;

var mousePressScreenY:Float = 0;
var mousePressWorldY:Float = 0;
var mousePressedOnIcon:FlxSprite = null;
var dragThreshold:Float = 5;

var backButton:FlxText;
var cancel:FlxSound;

// Back 按钮松开触发状态
var pendingBack:Bool = false;

function create() {
    CoolUtil.playMusic(Paths.music("breakfast"));
    
    invW = 0.2 / FlxG.width;
    invH = 0.2 / FlxG.height;
    lastMouseX = FlxG.mouse.screenX;
    lastMouseY = FlxG.mouse.screenY;

    cancel = FlxG.sound.load(Paths.sound('menu/cancel'));

    bgSwirl = new FlxSprite(-600, -600).loadGraphic(Paths.image('menus/credit/swirl2'));
    bgSwirl.scale.set(1.2, 1.2);
    bgSwirl.updateHitbox();
    bgSwirl.screenCenter();
    bgSwirl.scrollFactor.set(0, 0);
    add(bgSwirl);

    myShader = new CustomShader("swirl");
    myShader.data.iTime.value = [0.0];
    myShader.data.uMouse.value = [0.0, 0.0];
    myShader.data.uIntensity.value = [0.0];
    myShader.data.uHue.value = [0.0];
    bgSwirl.shader = myShader;
    if(bgSwirl.shader.data.bitmap != null) bgSwirl.shader.data.bitmap.wrap = Context3DWrapMode.REPEAT;

    bg = new FlxSprite(350, 80).makeGraphic(FlxG.width, FlxG.height - 70, FlxColor.WHITE);
    bg.scrollFactor.set(0, 0);
    add(bg);

    whiteOverlay = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height - 70, [0xFFFFFFFF, 0x00FFFFFF]);
    whiteOverlay.y = 80;
    whiteOverlay.scrollFactor.set(0, 0);
    add(whiteOverlay);

    dots = new FlxSprite(0, -80).loadGraphic(Paths.image('menus/credit/dots shader placeholder'));
    dots.antialiasing = Options.antialiasing;
    dots.scale.set(0.6, 0.6);
    dots.scrollFactor.set(0, -0.1);
    dots.alpha = 1;
    dots.blend = 0;
    add(dots);

    var boarder = new FlxSprite(200, 0).loadGraphic(Paths.image('menus/credit/boarder'));
    boarder.antialiasing = Options.antialiasing;
    boarder.scale.set(0.79, 0.79);
    boarder.scrollFactor.set(0, 0);
    boarder.screenCenter();
    add(boarder);

    iconbox = new FlxSprite(-25, 40).loadGraphic(Paths.image('menus/credit/top text box'));
    iconbox.antialiasing = Options.antialiasing;
    iconbox.scale.set(0.8, 0.8);
    iconbox.scrollFactor.set(0, 0);
    add(iconbox);

    textbox = new FlxSprite(-25, 220).loadGraphic(Paths.image('menus/credit/text box'));
    textbox.antialiasing = Options.antialiasing;
    textbox.scale.set(0.8, 0.8);
    textbox.scrollFactor.set(0, 0);
    add(textbox);

    rotShader = new CustomShader("rotationX");
    rotShader.yRot = 0.0;

    var heart = new FlxSprite(1100, 70).loadGraphic(Paths.image('menus/credit/heart'));
    heart.scale.set(0.79, 0.79);
    heart.scrollFactor.set(0, 0);
    heart.shader = rotShader;
    add(heart);

    var black_rectangle = new FlxSprite(370, 70).loadGraphic(Paths.image('menus/credit/black rectangle'));
    black_rectangle.antialiasing = Options.antialiasing;
    black_rectangle.scale.set(0.79, 0.79);
    black_rectangle.scrollFactor.set(0, 0);
    add(black_rectangle);

    nameText = new FlxText(40, 120, 300, "Name", 48);
    nameText.setFormat(Paths.font("Tardling-Outline.ttf"), 29, FlxColor.BLACK, "left");
    nameText.scrollFactor.set(0, 0);
    nameText.antialiasing = Options.antialiasing;
    add(nameText);

    socialText = new FlxText(40, 170, 380, "Social:", 20);
    socialText.setFormat(Paths.font("Tardling-Outline.ttf"), 35, 0xFF000000, "left");
    socialText.scrollFactor.set(0, 0);
    socialText.antialiasing = Options.antialiasing;
    add(socialText);
    
    roleText = new FlxText(40, 280, 380, "Role", 24);
    roleText.setFormat(Paths.font("Tardling-Outline.ttf"), 25, 0xFF000000, "left");
    roleText.scrollFactor.set(0, 0);
    roleText.antialiasing = Options.antialiasing;
    add(roleText);

    descText = new FlxText(40, 310, 290, "Description", 20);
    descText.setFormat(Paths.font("Tardling-Outline.ttf"), 20, 0xFF000000, "left");
    descText.scrollFactor.set(0, 0);
    descText.antialiasing = Options.antialiasing;
    add(descText);

    quoteText = new FlxText(40, 340, 290, '"Quote"', 20);
    quoteText.setFormat(Paths.font("Tardling-Outline.ttf"), 29, FlxColor.BLACK, "left");
    quoteText.scrollFactor.set(0, 0);
    quoteText.antialiasing = Options.antialiasing;
    add(quoteText);

    function createSocial(x:Float, img:String, type:String):FlxSprite {
        var s = new FlxSprite(x, 200).loadGraphic(Paths.image('menus/credit/' + img));
        s.setGraphicSize(40, 40);
        s.updateHitbox();
        s.scrollFactor.set(0, 0);
        add(s);
        socialSprites.push({spr: s, type: type});
        return s;
    }

    ytSprite = createSocial(40, 'youtube', 'youtube');
    ytSprite.antialiasing = Options.antialiasing;
    instaSprite = createSocial(100, 'instagram', 'instagram');
    instaSprite.antialiasing = Options.antialiasing;
    twitterSprite = createSocial(160, 'twitter', 'twitter');
    twitterSprite.antialiasing = Options.antialiasing;
    tiktokSprite = createSocial(220, 'tiktok', 'tiktok');
    tiktokSprite.antialiasing = Options.antialiasing;
    biliSprite = createSocial(280, 'bilibili', 'bilibili');
    biliSprite.antialiasing = Options.antialiasing;

    iconGroup = new FlxTypedGroup();
    add(iconGroup);

    var validIndex:Int = 0;
    for (data in rawCredits) {
        var tempGraphic = Paths.image("menus/credit/icons/" + data.name + " icon");
        if (tempGraphic == null) continue;
        var icon = new FlxSprite().loadGraphic(tempGraphic);
        if (icon.width <= 1 || icon.frameWidth <= 1) continue;
        creditsData.push(data);
        var col:Int = validIndex % GRID_COLS; 
        var row:Int = Std.int(validIndex / GRID_COLS);
        icon.setPosition(GRID_START_X + (col * (ICON_SIZE + PADDING)), GRID_START_Y + (row * (ICON_SIZE + PADDING)));
        icon.setGraphicSize(ICON_SIZE, ICON_SIZE);
        icon.updateHitbox();
        icon.antialiasing = Options.antialiasing;
        icon.ID = validIndex;
        iconGroup.add(icon);
        validIndex++;
    }

    var line = new FlxSprite(430,148).loadGraphic(Paths.image('menus/credit/line'));
    line.antialiasing = Options.antialiasing;
    line.scale.set(0.79, 0.79);
    line.scrollFactor.set(0, 0);
    add(line);

    var totalHeight = (Math.ceil(creditsData.length / GRID_COLS) * (ICON_SIZE + PADDING)) - PADDING;
    var viewHeight = FlxG.height - MASK_Y - 50;
    maxCamY = Math.max(0, totalHeight - viewHeight);
    minCamY = 0;
    targetCamY = FlxG.camera.scroll.y;

    backButton = new FlxText(FlxG.width - 200, FlxG.height - 85, 180, "Back", 64);
    backButton.setFormat(Paths.font("Tardling-Outline.ttf"), 64, FlxColor.BLACK, "center");
    backButton.scrollFactor.set(0, 0);
    backButton.antialiasing = Options.antialiasing;
    backButton.alpha = 0.9;
    backButton.borderStyle = FlxTextBorderStyle.NONE;
    add(backButton);

    changeSelection(0);
}

function update(elapsed:Float) {
    if (FlxG.sound.music != null) FlxG.sound.music.pitch = FlxMath.lerp(FlxG.sound.music.pitch, 1, elapsed * 0.8);
    
    var mx = FlxG.mouse.screenX;
    var my = FlxG.mouse.screenY;
    var mouseWorldX = FlxG.mouse.x;
    var mouseWorldY = FlxG.mouse.y;
    var justPressed = FlxG.mouse.justPressed;
    var justReleased = FlxG.mouse.justReleased;
    var pressing = FlxG.mouse.pressed;

    rotationTime += elapsed * 100; 
    rotShader.yRot = rotationTime;
    
    actualColor = FlxColor.interpolate(actualColor, targetColor, elapsed * 4);
    var lightColor = FlxColor.interpolate(actualColor, FlxColor.WHITE, 0.4);
    var darkColor = FlxColor.interpolate(actualColor, FlxColor.BLACK, 0.6);
    bg.color = lightColor;
    iconbox.color = lightColor;
    textbox.color = lightColor;
    bgSwirl.color = actualColor; 
    dots.color = actualColor;
    nameText.color = darkColor;

    if (FlxG.keys.justPressed.SEVEN) {
        persistentUpdate = false; persistentDraw = true;
        openSubState(new EditorPicker()); return;
    }
    if (controls.SWITCHMOD) {
        persistentUpdate = false; persistentDraw = true;
        openSubState(new ModSwitchMenu()); return;
    }
    
    // 键盘 ESC 返回（保持按下立即返回，未要求改动）
    if (controls.BACK) {
        cancel.play();
        FlxG.switchState(new MainMenuState());
        return;
    }

    // ========== Back 按钮松开触发 ==========
    var mouseOverBack = FlxG.mouse.overlaps(backButton);
    // 按下时记录 pending
    if (justPressed && mouseOverBack && !pendingBack) {
        pendingBack = true;
    }
    // 松开时执行返回（如果 pending 为真）
    if (justReleased && pendingBack && mouseOverBack) {
        pendingBack = false;
        cancel.play();
        FlxG.switchState(new MainMenuState());
        return;
    }
    // 如果按着 Back 按钮时移出了按钮区域，取消 pending（避免松开时误触发）
    if (pendingBack && !mouseOverBack && pressing) {
        pendingBack = false;
    }
    
    // Back 按钮视觉反馈
    if (mouseOverBack) {
        backButton.color = FlxColor.WHITE;
        backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
        backButton.borderColor = FlxColor.BLACK;
        backButton.borderSize = 3;
    } else {
        backButton.color = FlxColor.BLACK;
        backButton.borderStyle = FlxTextBorderStyle.NONE;
    }

    if (creditsData.length == 0) return;

    var keyChanged = false;
    if (controls.UP_P) { changeSelection(-GRID_COLS); keyChanged = true; }
    if (controls.DOWN_P) { changeSelection(GRID_COLS); keyChanged = true; }
    if (controls.LEFT_P) { changeSelection(-1); keyChanged = true; }
    if (controls.RIGHT_P) { changeSelection(1); keyChanged = true; }
    if (keyChanged) {
        autoFollowSelection = true;
        velocity = 0;
        isDragging = false;
    }

    var wheel = FlxG.mouse.wheel;
    if (wheel != 0 && !isDragging) {
        autoFollowSelection = false;
        targetCamY -= wheel * 40;
        targetCamY = FlxMath.bound(targetCamY, minCamY, maxCamY);
        velocity = 0;
    }

    if (justPressed && FlxG.mouse.overlaps(iconGroup)) {
        mousePressScreenY = FlxG.mouse.screenY;
        mousePressWorldY = FlxG.mouse.y;
        mousePressedOnIcon = null;
        for (icon in iconGroup.members) {
            if (FlxG.mouse.overlaps(icon)) {
                mousePressedOnIcon = icon;
                break;
            }
        }
        dragStartY = FlxG.mouse.screenY;
        dragStartCamY = FlxG.camera.scroll.y;
        velocity = 0;
        autoFollowSelection = false;
        isDragging = false;
    }

    if (pressing && !isDragging && mousePressedOnIcon != null) {
        var delta = Math.abs(FlxG.mouse.screenY - mousePressScreenY);
        if (delta > dragThreshold) {
            isDragging = true;
        }
    }

    if (isDragging && pressing) {
        var delta = FlxG.mouse.screenY - dragStartY;
        targetCamY = dragStartCamY - delta;
        targetCamY = FlxMath.bound(targetCamY, minCamY, maxCamY);
        var newVelocity = (targetCamY - FlxG.camera.scroll.y) / elapsed;
        velocity = FlxMath.lerp(velocity, newVelocity, 0.6);
    }

    if (justReleased) {
        if (!isDragging && mousePressedOnIcon != null) {
            if (curSelected != mousePressedOnIcon.ID) {
                changeSelection(mousePressedOnIcon.ID - curSelected);
                autoFollowSelection = true;
            }
        }
        isDragging = false;
        mousePressedOnIcon = null;
    }

    if (!isDragging && !autoFollowSelection && Math.abs(velocity) > 0.5) {
        targetCamY += velocity * elapsed;
        targetCamY = FlxMath.bound(targetCamY, minCamY, maxCamY);
        velocity *= (1 - elapsed * 5);
        if (Math.abs(velocity) < 0.5) velocity = 0;
    }

    if (autoFollowSelection && iconGroup.members[curSelected] != null) {
        var targetY = iconGroup.members[curSelected].y - (FlxG.height / 2) + (ICON_SIZE / 2);
        targetY = FlxMath.bound(targetY, minCamY, maxCamY);
        targetCamY = FlxMath.lerp(targetCamY, targetY, elapsed * 5);
        velocity = 0;
    }

    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, targetCamY, elapsed * 12);
    FlxG.camera.scroll.y = FlxMath.bound(FlxG.camera.scroll.y, minCamY, maxCamY);

    var currentData = creditsData[curSelected];
    for (social in socialSprites) {
        var link = Reflect.field(currentData, social.type);
        var spr = social.spr;
        if (link != "" && link != null) {
            if (FlxG.mouse.overlaps(spr)) {
                spr.alpha = 1.0;
                if (justPressed) FlxG.openURL(link);
            } else {
                spr.alpha = 0.7;
            }
        } else {
            spr.alpha = 0.2;
        }
    }

    if (myShader != null) {
        var dx = mx - lastMouseX;
        var dy = my - lastMouseY;
        var ratio = 0.0;
        if (dx != 0.0 || dy != 0.0) {
            var d2 = dx * dx + dy * dy;
            ratio = (d2 > 2500.0) ? 1.0 : Math.sqrt(d2) * 0.02;
        }
        currentTimeSpeed += ((0.5 + (ratio * 20.0)) - currentTimeSpeed) * (elapsed * 2.0);
        intensity += ((ratio * 2.0) - intensity) * (elapsed * 3.5);
        myShader.data.iTime.value[0] += currentTimeSpeed * elapsed;
        myShader.data.uIntensity.value[0] = intensity;
        var sMouse = myShader.data.uMouse.value;
        var lerpT = elapsed * 0.01;
        sMouse[0] += ((mx * invW) - sMouse[0]) * lerpT;
        sMouse[1] += ((my * invH) - sMouse[1]) * lerpT;
        currentHue = FlxMath.lerp(currentHue, targetHue, elapsed * 2.0);
        var shaderVal = currentHue % 1.0;
        if (shaderVal < 0) shaderVal += 1.0;
        myShader.data.uHue.value[0] = shaderVal;
        lastMouseX = mx;
        lastMouseY = my;
    }

    var camScrollY = FlxG.camera.scroll.y;
    var camHeight = FlxG.height;
    iconGroup.forEach(function(spr:FlxSprite) {
        if (!spr.isOnScreen(0, 0, 200, 200)) {
            spr.visible = false;
            return; 
        }
        spr.visible = true;
        if (FlxG.mouse.overlaps(spr)) {
            spr.alpha = (spr.ID == curSelected) ? 1.0 : 0.8;
        } else {
            spr.alpha = (spr.ID == curSelected) ? 1.0 : 0.5;
        }
        var screenY = spr.y - camScrollY;
        if (screenY < MASK_Y) {
            var cutScreenHeight = MASK_Y - screenY;
            if (cutScreenHeight >= spr.height) {
                spr.visible = false;
            } else {
                var cutTextureHeight = cutScreenHeight * (spr.frameHeight / spr.height);
                if (spr.clipRect == null) spr.clipRect = new FlxRect(0, 0, spr.frameWidth, spr.frameHeight);
                if (spr.clipRect.y != cutTextureHeight) {
                    spr.clipRect.y = cutTextureHeight;
                    spr.clipRect.height = spr.frameHeight - cutTextureHeight;
                    spr.clipRect = spr.clipRect;
                }
            }
        } else {
            if (spr.clipRect != null) spr.clipRect = null;
        }
    });
}

function changeSelection(change:Int) {
    curSelected = FlxMath.bound(curSelected + change, 0, creditsData.length - 1);
    var data = creditsData[curSelected];
    nameText.text = data.name.toUpperCase();
    roleText.text = data.role;
    descText.text = data.desc;
    descText.draw();
    quoteText.text = '"' + data.quote + '"';
    quoteText.y = 310 + descText.fieldHeight;
    targetColor = data.color;

    var col:Int = data.color;
    var r:Float = ((col >> 16) & 0xFF) / 255.0;
    var g:Float = ((col >> 8) & 0xFF) / 255.0;
    var b:Float = (col & 0xFF) / 255.0;
    var max = Math.max(r, Math.max(g, b));
    var min = Math.min(r, Math.min(g, b));
    var delta = max - min;
    var hue = 0.0;
    if (delta > 0) {
        if (max == r) hue = ((g - b) / delta) % 6;
        else if (max == g) hue = (b - r) / delta + 2;
        else hue = (r - g) / delta + 4;
    }
    hue *= 60;
    if (hue < 0) hue += 360;
    targetHue = hue / 360.0; 
    var normalizedCurrent = currentHue % 1.0;
    if (normalizedCurrent < 0) normalizedCurrent += 1.0;
    var diff = targetHue - normalizedCurrent;
    if (diff < -0.5) currentHue = normalizedCurrent - 1.0; 
    else if (diff > 0.5) currentHue = normalizedCurrent + 1.0;
    else currentHue = normalizedCurrent;
}