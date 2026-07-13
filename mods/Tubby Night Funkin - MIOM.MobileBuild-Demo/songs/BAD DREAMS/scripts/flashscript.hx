
function stepHit(curStep) {
        switch(curStep) {
            case 1024:
                camZoomingInterval = 4;

            case 272 |1168:
                camZoomingInterval = 2;
  

            case 400:
                camZoomingInterval = 1;
                flash(FlxColor.WHITE, 0,0.9,1); //color, blend, time, alpha
                
            case 832 |1040 | 1808:
                camZoomingInterval = 1;
                
            case 1296:
                camZoomingInterval = 4; 

            case 816:
                camZoomingInterval = 1.5;
            
            case 1680:
                camZoomingInterval = 2;
                flash(FlxColor.WHITE, 0,0.9,1); //color, blend, time, alpha
            
            case 1424 | 2192:
                camZoomingInterval = 4;

            case 2448:
                camZoomingInterval = 4;
                FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.linear}); 
                
            case 2512:
                camZoomingInterval = 1.5;
                flash(FlxColor.WHITE, 0,0.9,1); //color, blend, time, alpha
                FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});

            case 2896:
                FlxTween.tween(camHUD, {alpha: 0}, 4, {ease: FlxEase.linear}); 
                
            case 3536:
                camZoomingInterval = 1;
                flash(FlxColor.WHITE, 0,0.9,1); //color, blend, time, alpha

            case 4304:
                camZoomingInterval = 4;

            case 4432:
                camZoomingInterval = 2;

            case 4544:
                camZoomingInterval = 4;

            case 4560:
                camZoomingInterval = 1;

            case 5088:
                camZoomingInterval = 4;
                FlxTween.tween(camHUD, {alpha: 0}, 4, {ease: FlxEase.linear}); 

        }
    }
function flash(color:FlxColor,blend, time,alpha) {

    flashs = new FlxSprite().makeSolid(FlxG.width * 2, 9999, color);
    flashs.scrollFactor.set(0, 0);
    flashs.setGraphicSize(Std.int(flashs.width + 2500));
    flashs.screenCenter();
    flashs.alpha = alpha;
    insert(members.indexOf(gf)+15, flashs);
    flashs.blend = blend;

    FlxTween.tween(flashs, {alpha:0}, time, {ease: FlxEase.smootherStepInOut});

    new FlxTimer().start(time, function(tmr:FlxTimer){
        remove(flashs);
        });
    }

public function scrollSpeed_tween(value:Float, duration:Float)
FlxTween.tween(PlayState.instance, {scrollSpeed: value}, duration); 

