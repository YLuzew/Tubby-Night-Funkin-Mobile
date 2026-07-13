
function stepHit(curStep) {
        switch(curStep) {
            case 528 | 1296:
                camZoomingInterval = 4;
                flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha
  
            case 272:
                camZoomingInterval = 1;
                flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha
                
            case 1040:
                camZoomingInterval = 1; 
                flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha

             case 1360:
                camZoomingInterval = 2;

            case 1008 | 1392:
                camZoomingInterval = 1;

            case 1408:
                camZoomingInterval = 0.5;    

            case 1032 | 1416:
                camZoomingInterval = 4;

            case 1424:
                
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
