import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.system.FunkinSprite;
import funkin.backend.utils.XMLUtil;
import funkin.backend.shaders.CustomShader;

var isDead = false;
var deathSprite:FunkinSprite;
var deathGlow:FunkinSprite;

var cyanShader:CustomShader;
var auraShader:CustomShader;
var auraSprite:FlxSprite;

var whiteOverlay:FlxSprite;
var canRestart:Bool = false;
var bopTimer:Float = 0;

function postCreate() {
    cyanShader = new CustomShader("cyan_glow");
    cyanShader.intensity = 0.0;
    
    if (dad != null) {
        dad.shader = cyanShader;
    }

    auraShader = new CustomShader("radial_glow");
    auraShader.intensity = 0.0;

    auraSprite = new FlxSprite(0, 0).makeSolid(4000, 4000, 0xFFFFFFFF);
    auraSprite.shader = auraShader;
    auraSprite.blend = 0; 
    auraSprite.scrollFactor.set(1, 1);
    
    insert(members.indexOf(dad) + 1, auraSprite);
}

function update(elapsed:Float) {
    if (dad != null && auraSprite != null) {
        auraSprite.x = dad.getGraphicMidpoint().x - (auraSprite.width / 2);
        auraSprite.y = dad.getGraphicMidpoint().y - (auraSprite.height / 2);
    }

    if (isDead) {
        Conductor.songPosition = 0;
        
        bopTimer += elapsed;
        if (bopTimer >= Conductor.crochet / 1000) {
            if (gf != null) gf.dance();
            if (dad != null) dad.dance();
            bopTimer = 0;
        }
        
        if (PlayState.instance.inst != null) {
            PlayState.instance.inst.volume = 0;
            PlayState.instance.inst.pause();
        }
        if (PlayState.instance.vocals != null) {
            PlayState.instance.vocals.volume = 0;
            PlayState.instance.vocals.pause();
        }
    }

    if (canRestart) {
        var accept = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE;
        var back = FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE;
        
        if (PlayState.instance.controls != null) {
            accept = accept || PlayState.instance.controls.ACCEPT;
            back = back || PlayState.instance.controls.BACK;
        }

        if (accept) {
            FlxG.resetState(); 
        }
        if (back) {
            FlxG.switchState(new FreeplayState());
        }
    }
}

function onGameOver(e) {
    e.cancel();

    if (isDead) return;
    isDead = true;

    var instance = PlayState.instance;
    
    instance.canPause = false; 

    if (inst != null && inst.playing) inst.pause();
    if (vocals != null && vocals.playing) vocals.pause();
    
    FlxG.sound.play(Paths.sound("georgegameOverSFK"));

    FlxTween.tween(instance.camHUD, {alpha: 0}, 0.7 * FlxG.timeScale, {ease: FlxEase.quadOut});

    if (instance.inst != null) {
        instance.inst.volume = 0;
        instance.inst.stop();
    }
    if (instance.vocals != null) {
        instance.vocals.volume = 0;
        instance.vocals.stop();
    }

    deathSprite = new FunkinSprite(boyfriend.x, boyfriend.y, Paths.image("characters/Boyfriend/boyfriend george death"));
    
    deathGlow = new FunkinSprite(100, -700, Paths.image("stages/george-stage/death glow"));
    deathGlow.blend = 0; 
    deathGlow.alpha = 0;
    deathGlow.scale.set(2,2);
    insert(members.indexOf(instance.boyfriend) + 1, deathGlow); 

    XMLUtil.addAnimToSprite(deathSprite, {
        name: "die",
        anim: "bf-blinded",
        fps: 24,
        loop: false,
        animType: "none",
        x: -205,
        y: -155,
        indices: [],
        forced: true
    });

    insert(members.indexOf(instance.boyfriend), deathSprite);
    deathSprite.visible = false;

    new FlxTimer().start(0.5 * FlxG.timeScale, function(t:FlxTimer) {
        instance.boyfriend.visible = false;
        deathSprite.visible = true;
        deathSprite.playAnim("die", true);
        
        FlxG.camera.flash(0xFFFFFFFF, 0.5);
        FlxTween.tween(deathGlow, {alpha: 1}, 2, {ease: FlxEase.quadIn});
        
        FlxTween.num(0.0, 0.2, 0.5 * FlxG.timeScale, {ease: FlxEase.cubeOut}, function(v:Float) {
            if (cyanShader != null) cyanShader.intensity = v * 0.4;
            if (auraShader != null) auraShader.intensity = v;
        });

        new FlxTimer().start(1 * FlxG.timeScale, function(tmr2:FlxTimer) {
            FlxTween.num(0.2, 3.0, 8.0 * FlxG.timeScale, {ease: FlxEase.quadIn}, function(v:Float) {
                if (cyanShader != null) cyanShader.intensity = v * 0.4;
                if (auraShader != null) auraShader.intensity = v;
            });
        });
    });
    
    FlxG.camera.target = null; 
    var bfCam = instance.boyfriend.getCameraPosition();
    var targetScrollX = bfCam.x - (FlxG.width / 2) - 400;
    var targetScrollY = bfCam.y - (FlxG.height / 2);

    FlxTween.tween(FlxG.camera.scroll, {x: targetScrollX, y: targetScrollY}, 2 * FlxG.timeScale, {ease: FlxEase.quadOut});
    defaultCamZoom = 0.5;

    new FlxTimer().start(4 * FlxG.timeScale, function(t:FlxTimer) {
        whiteOverlay = new FlxSprite(-FlxG.width, -FlxG.height).makeSolid(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), 0xFFFFFFFF);
        whiteOverlay.scrollFactor.set(0, 0); 
        whiteOverlay.blend = 0; 
        whiteOverlay.alpha = 0;
        
        add(whiteOverlay); 

        FlxTween.tween(whiteOverlay, {alpha: 1}, 2 * FlxG.timeScale, {
            ease: FlxEase.quadIn,
            onComplete: function(twn:FlxTween) {
                canRestart = true;
            }
        });
    });
}