
function startPhase() {
    stage.stageSprites["floor"].alpha = 0;
    stage.stageSprites["solocircle"].alpha = 1;
    stage.stageSprites["sololight"].alpha = 1;

    
    var mists = [stage.stageSprites["mist_back"], stage.stageSprites["mist_mid"], stage.stageSprites["mist_front"]];

    for (I in 0...mists.length){
        var spr = mists[I];
        FlxTween.tween(spr, {alpha:1, y:-300}, 5+(I*5), {ease:FlxEase.sineOut});
    }
    
    FlxTween.tween(stage.stageSprites["mist_back"], {x:-200}, 15);
    FlxTween.tween(stage.stageSprites["mist_mid"], {x:-600}, 15);
    FlxTween.tween(stage.stageSprites["mist_front"], {x:-600}, 15);

    dad.alpha = 0;
    gf.alpha = 0;
}

function closePhase() {
    stage.stageSprites["solocircle"].alpha = 0;
    stage.stageSprites["sololight"].alpha = 0;
    stage.stageSprites["mist_back"].alpha = 0;
    stage.stageSprites["mist_mid"].alpha = 0;
    stage.stageSprites["mist_front"].alpha = 0;
        
    camera.flash(0.5, FlxColor.WHITE);
}

function stepHit(curStep) {
    switch (curStep) {
        case 4543:
            gf.alpha = 0;
        case 4550:
            bf.alpha = 0;
        case 4554:
            camera.fade(FlxColor.WHITE, (Conductor.stepCrochet / 1000) * 6, false, () -> {camera._fxFadeAlpha = 0;}, true);
    }

}

function beatHit(curBeat) {
    switch (curBeat) {
        case 1106:
            remove(dad);
            insert(members.indexOf(bf) - 1, dad);
    }
}