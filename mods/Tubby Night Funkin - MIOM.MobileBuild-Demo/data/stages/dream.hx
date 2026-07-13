import flixel.tweens.FlxTweenType;

function postCreate() {
    blackBarThingie = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width + 500));
    blackBarThingie.scrollFactor.set(0, 0);
    blackBarThingie.screenCenter();
    blackBarThingie.alpha = 0;
    blackBarThingie.cameras = [camHUD];

    add(blackBarThingie);
}

var shaderBruh = new CustomShader('adjustColor');
shaderBruh.brightness = 0;
shaderBruh.hue = 0;
shaderBruh.saturation = -60;
shaderBruh.contrast = 0;

function stepHit(curStep:Int) {
    switch (curStep) {
        case 890:
            FlxTween.tween(blackBarThingie, {alpha: 1}, 0.5);

        case 912:
            FlxTween.tween(blackBarThingie, {alpha: 0}, 0.5);

            var hideBase = ["blackfog", "treesFar", "treesBackground", "treesFront", "blackfog2", "ground"];
            for (spr in hideBase) {
                if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].alpha = 0;
            }

            if (!Options.lowMemoryMode) {
                var hideHigh = ["redfog", "fog"];
                for (spr in hideHigh) {
                    if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].alpha = 0;
                }
            }

            defaultCamZoom = 0.4;

            var showBase = ["sky2", "moon2", "ground2", "treesfront2"];
            for (spr in showBase) {
                if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].alpha = 1;
            }

            if (!Options.lowMemoryMode) {
                var showHigh = ["fogfront2", "light2"];
                for (spr in showHigh) {
                    if (stage.stageSprites.exists(spr)) stage.stageSprites[spr].alpha = 1;
                }
            }

            boyfriend.y = 600;
            boyfriend.x = 1600;
            boyfriend.scale.set(1.2, 1.2);
            dad.scale.set(0.85, 0.85);

            FlxTween.tween(dad, {y: dad.y - 100}, 2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

            if (!Options.lowMemoryMode) {
                if (Options.gameplayShaders) {
                    dad.shader = shaderBruh;
                    boyfriend.shader = shaderBruh;
                }
            }

            if (Options.lowMemoryMode) {
                dad.shader = null;
                boyfriend.shader = null;
            }
    }
}