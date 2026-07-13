public var camSpeed = 0.04;

function stepHit(curStep) {
    if (curSong == 'farewell') {
        switch (curStep) {
            case 264 | 794 | 876 | 892 | 908 | 1324:
                camZoomingInterval = 1;
            case 529 | 1191:
                camZoomingInterval = 2;
            case 873 | 890 | 905 | 1059 | 1587:
                camZoomingInterval = 4;
        }
    }

    switch (curStep) {
        case 396 | 927 | 1456: 
            camSpeed = 99999;
            defaultCamZoom = 1;
            FlxTween.tween(camGame, { zoom: 1}, 0.1, { ease: FlxEase.quadInOut, type: FlxTween.BACKINOUT });

        case 496 | 1026 | 1556: 
            camSpeed = 0.005;
            defaultCamZoom = 0.65;
            FlxTween.tween(camGame, { zoom: 0.65}, 2, { ease: FlxEase.quadInOut, type: FlxTween.BACKINOUT });

        case 528 | 1576: 
            camSpeed = 0.035;
            defaultCamZoom = 0.7;
            FlxTween.tween(camGame, { zoom: 0.7}, 3, { ease: FlxEase.quadInOut, type: FlxTween.BACKINOUT });

        case 794: 
            if (Options.lowMemoryMode) {
                for (H in [hillstage, boomboxgrass, grass]) {
                    H.visible = false;
                }
                groundStage2.alpha = 1;
                sun.x = 900;
                sun.scale.set(1.2, 1.2);
            } else {
                for (H in [sky, sun, hillsbackground, hillstage, boomboxgrass, grass, tree, bushes, overlay, fog, sunlight]) {
                    H.visible = false;
                }
                for (H in [sky2, sun2, hillsback2, groundStage2, boomboxgrass2, bushFront2, bushBack2, tree2, overlay2, fog2, sunlight2]) {
                    H.alpha = 1;
                }
            }
            defaultCamZoom = 0.5;

        case 1590:
            FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.linear});      
    }
}

function postUpdate() {
    FlxG.camera.followLerp = camSpeed;
}