function stepHit(curStep) {
        switch(curStep) {

            case 144 | 1408:flash(FlxColor.WHITE, 0,0.5,100); //color, blend, time, alpha
            case 1696: flash(FlxColor.WHITE, 0,1,0.7);
        }
    }

function flash(color:FlxColor,blend, time,alpha) {

    flashs = new FunkinSprite().makeSolid(FlxG.width * 2, 9999, color);
    flashs.scrollFactor.set(0, 0);
    flashs.zoomFactor = 0;
    flashs.screenCenter();
    flashs.alpha = alpha;
    insert(1000,flashs);
    flashs.blend = blend;

    FlxTween.tween(flashs, {alpha:0}, time, {ease: FlxEase.smootherStepInOut});

    new FlxTimer().start(time, function(tmr:FlxTimer){
        remove(flashs);
        });
    }

public function scrollSpeed_tween(value:Float, duration:Float)
FlxTween.tween(PlayState.instance, {scrollSpeed: value}, duration); 
