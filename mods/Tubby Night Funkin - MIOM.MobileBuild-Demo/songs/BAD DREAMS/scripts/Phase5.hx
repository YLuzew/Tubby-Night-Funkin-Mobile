import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxTypedEmitter;
import flixel.effects.particles.FlxEmitterMode;
import flixel.util.helpers.FlxRange;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import Reflect;

var onPhase = false;
var bg:FunkinSprite;
var bgFront:FunkinSprite;
var girlsAura:FunkinSprite;
var riseEmitter:FlxTypedEmitter<FlxParticle>;
var whiteFade:FunkinSprite;

function create() {
    bg = new FunkinSprite(0, 0).loadSprite(Paths.image("stages/badDreams/final-bg"));
    bg.scrollFactor.set(0, 0);
    bg.screenCenter();
    bg.zoomFactor = 0;
    bg.alpha = 0;
    insert(0, bg);

    girlsAura = new FunkinSprite(1360, 0).loadSprite(Paths.image("stages/badDreams/pink-aura"));
    girlsAura.scale.set(1.5, 1.5);
    girlsAura.antialiasing = Options.antialiasing;
    girlsAura.addAnim("aura", "aura", 24, true);
    girlsAura.playAnim("aura", true, "LOCK");
    girlsAura.alpha = 0;
    insert(members.indexOf(bf)-1, girlsAura);


    bgFront = new FunkinSprite(-400, -100).loadSprite(Paths.image("stages/badDreams/final-light-front"));
    bgFront.scale.set(1.5, 1.5);
    bgFront.antialiasing = Options.antialiasing;
    bg.zoomFactor = 0.5;
    bgFront.alpha = 0;
    add(bgFront);

    if (!Options.lowMemoryMode) {
        riseEmitter = new FlxTypedEmitter<FlxParticle>(0, 1000, 300);
        riseEmitter.loadParticles(Paths.image("stages/badDreams/particle"), 1000, 0);
        
        riseEmitter.width = FlxG.width * 2.5;
        riseEmitter.launchMode = FlxEmitterMode.SQUARE;
        riseEmitter.velocity.set(0, -400, 0, -50);
        riseEmitter.alpha.set(1, 1, 0, 0);
        riseEmitter.scale.set(1, 1, 1, 1, 0, 0, 0, 0);
        riseEmitter.lifespan.set(5, 25);
        add(riseEmitter);
    }

    whiteFade = new FunkinSprite().makeSolid(camGame.width, camGame.height, FlxColor.WHITE);
    whiteFade.scrollFactor.set();
    whiteFade.zoomFactor = 0;
    whiteFade.alpha = 0;
    add(whiteFade);

}

function startPhase() {
    onPhase = true;
    bg.alpha = 1;
    bgFront.alpha = 1;
    girlsAura.alpha = 0.9;
    
    remove(dad);
    insert(members.indexOf(girlsAura)-1, dad);

    if (!Options.lowMemoryMode && riseEmitter != null) {
        riseEmitter.start(false, 0.05);
    }
}

function postUpdate() {
    if (onPhase) {
        defaultCamZoom = 0.475;
        camHUD.x = Math.sin((Conductor.songPosition / 1000)*4) * 2;
        camHUD.y = Math.cos((Conductor.songPosition / 1000)*2) * 10;
        camHUD.angle = Math.sin((Conductor.songPosition / 1000)*2) * 1;
    }
}

function beatHit(curBeat) {
    switch (curBeat) {
        case 1276:
            FlxTween.tween(whiteFade, {alpha:1}, (Conductor.stepCrochet / 1000) * 32);
            FlxTween.tween(bg, {y:1500}, (Conductor.stepCrochet / 1000) * 32);
        case 1284:
            FlxTween.color(whiteFade, (Conductor.stepCrochet / 1000) * 32, FlxColor.WHITE, FlxColor.BLACK);

    }
}