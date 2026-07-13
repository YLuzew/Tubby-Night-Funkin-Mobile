
function stepHit(curStep) {
        switch(curStep) {
            case 256, 640, 896:
                camZoomingInterval = 2;
            case 512, 768:
                camZoomingInterval = 8;
            case 1184:
                camZoomingInterval = 2;
            case 1312:
                camZoomingInterval = 1;
            case 1409:
                camZoomingInterval = 1;
            case 1568:
                camZoomingInterval = 100;
         
            case 1311:
            FlxTween.tween(barTop, {y: -FlxG.height + 85}, 0.4, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            FlxTween.tween(barBottom, {y: FlxG.height - 85}, 0.4, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            for (i in 0...4) {
                for (strumline in strumLines.members)
                    for (strum in strumline.members) 
                        FlxTween.tween(strum, {y:90}, 0.4);

			}

            case 1567 :

             FlxTween.tween(barTop, {y: -FlxG.height}, 0.3, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            FlxTween.tween(barBottom, {y: FlxG.height}, 0.3, {ease: FlxEase.sineOut, type: FlxTween.ONESHOT});
            for (strumline in strumLines.members)
                for (strum in strumline.members) 
                    FlxTween.tween(strum, {y:50}, 0.4);

            
        }
    }

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