
import hxvlc.flixel.FlxVideoSprite;
superZoomShit = false;
var video = new FlxVideoSprite(-200,-150);
var blood:FunkinSprite;
var camCinematics:FlxCamera;

function postUpdate() {

        defaultCamZoom = (curCameraTarget == 1) ? 0.7 : 0.8;
}


function stepHit(curStep:Int) {
    switch (curStep) {
        case 1638:
            blood.playAnim("splat", true);
            blood.visible = true;

        case 1648:
            camCinematics.bgColor = FlxColor.BLACK;
            FlxTween.tween(camHUD, {alpha:0}, 0.4);


        case 1732:
            FlxTween.tween(blood, {alpha:0}, 1);

        // case 272:  camZoomingInterval = 1;

        //  case 528:  camZoomingInterval = 2;

        //  case 784:  camZoomingInterval = 4;

        //  case 912:  superZoomShit = true;
        case 1160:  //camZoomingInterval = 2;
        superZoomShit = false;

        // case 1424: for (H in [topgradient,light]) {
        //        FlxTween.tween(H, { alpha: 0 }, 2);
        //     }
        //     FlxTween.tween(overlayblack, { alpha: 1 }, 2);
            
        //     //camZoomingInterval = 6;
        //     video.bitmap.onFormatSetup.add(function() {
        //     video.scale.set(1.2,1.2);
        //     video.alpha = 0;
        //     video.blend = 12;
        //     video.scrollFactor.set(0.5, 0.5);
        //     });
        //     video.load(Assets.getPath(Paths.video("fog")), [':input-repeat=65535', ':no-audio']);
        //     add(video);
        //     video.play();

        //     FlxTween.tween(video, { alpha: 0.7 }, 2);
            
    }
}

function postCreate() {
    camCinematics = new FlxCamera();
                 
    camCinematics.bgColor = 0;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camCinematics, false);
    FlxG.cameras.add(camHUD, false);

    barBottom = new FlxSprite(0, FlxG.height -70).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barBottom.cameras = [camCinematics];
    add(barBottom);

    blackchara = new FunkinSprite(0, 0).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    blackchara.scrollFactor.set(0, 0);
    blackchara.zoomFactor = 0;
    blackchara.alpha = 0;
    insert(members.indexOf(dad) - 2, blackchara);

    barTop = new FlxSprite(0, -FlxG.height +70).makeSolid(FlxG.width * 2, FlxG.height, FlxColor.BLACK);
    barTop.cameras = [camCinematics];
    add(barTop);

    blood = new FunkinSprite(-550, -150).loadSprite(Paths.image("stages/carnage/blood-splat"));
    blood.addAnim("splat", "blood-splat instance 1");
    blood.visible = false;
    blood.scrollFactor.set();
    blood.zoomFactor = 0;
    blood.cameras = [camCinematics];
    add(blood);
}
