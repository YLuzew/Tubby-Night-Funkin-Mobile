var camCinematics:FlxCamera;


function stepHit(curStep:Int) {
    switch (curStep) {
        case 1184:
            camCinematics.bgColor = FlxColor.BLACK;
        
        case 1216:
            FlxG.cameras.remove(camCinematics, false);

        case 1488:
            FlxTween.tween(camHUD, {alpha:0}, 3);

        case 1552:
            FlxG.cameras.remove(camHUD, false);
            FlxG.cameras.add(camCinematics, false);
            FlxG.cameras.add(camHUD, false);
    }
}

function postCreate() {
    camCinematics = new FlxCamera();
                 
    camCinematics.bgColor = 0;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camCinematics, false);
    FlxG.cameras.add(camHUD, false);

}