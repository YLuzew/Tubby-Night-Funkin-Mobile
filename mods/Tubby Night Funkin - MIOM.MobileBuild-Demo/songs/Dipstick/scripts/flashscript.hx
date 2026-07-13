
function stepHit(curStep) {
        switch(curStep) {
            

            case 256:flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha

            case 516:flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha

            case 645:flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha

            case 768:
            FlxTween.tween(barTop, {y: -FlxG.height + 85}, 0.4, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            FlxTween.tween(barBottom, {y: FlxG.height - 85}, 0.4, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            for (i in 0...4) {
				FlxTween.tween(cpu.members[i], {y:90}, 0.4);
				FlxTween.tween(player.members[i], {y: 90}, 0.4);
			}

            case 896 :

             FlxTween.tween(barTop, {y: -FlxG.height}, 0.3, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            FlxTween.tween(barBottom, {y: FlxG.height}, 0.3, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
             for (i in 0...4) {
				FlxTween.tween(cpu.members[i], {y: 50}, 0.4);
				FlxTween.tween(player.members[i], {y: 50}, 0.4);
			}

            case 1152:flash(FlxColor.WHITE, 0,1,100); //color, blend, time, alpha


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

function postCreate() {
       var camCinematics:FlxCamera = new FlxCamera();
    camCinematics.bgColor = 0;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camCinematics, false);
    FlxG.cameras.add(camHUD, false);

    barBottom = new FlxSprite(0, FlxG.height).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barBottom.cameras = [camCinematics];
    add(barBottom);


    barTop = new FlxSprite(0, -FlxG.height).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barTop.cameras = [camCinematics];
    add(barTop);
}