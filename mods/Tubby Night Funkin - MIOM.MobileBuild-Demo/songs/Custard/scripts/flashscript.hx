playCutscenes = true;
function stepHit(curStep) {
        switch(curStep) {

            case 1713 | 1729 | 1824 | 2081:flash(FlxColor.WHITE, 0,0.5,100); //color, blend, time, alpha
  
        }
    }
function flash(color:FlxColor,blend, time,alpha) {

    flashs = new FlxSprite().makeSolid(FlxG.width * 2, 9999, color);
    flashs.scrollFactor.set(0, 0);
    flashs.screenCenter();
    flashs.alpha = alpha;
    insert(members.indexOf(gf)+10, flashs);
    flashs.blend = blend;

    FlxTween.tween(flashs, {alpha:0}, time, {ease: FlxEase.smootherStepInOut});

    new FlxTimer().start(time, function(tmr:FlxTimer){
        remove(flashs);
        });
    }


public function scrollSpeed_tween(value:Float, duration:Float)
FlxTween.tween(PlayState.instance, {scrollSpeed: value}, duration); 
