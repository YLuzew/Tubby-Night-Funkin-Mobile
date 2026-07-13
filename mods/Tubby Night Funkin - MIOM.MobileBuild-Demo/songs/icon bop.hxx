// edited version of swordcube's vslice icon bop for cne ... now its the psych icon bop
// uses scales instead of graphic sizes ... in turn making the easing more exponential

// edited by bobbyDX

import flixel.util.FlxDestroyUtil;

// var iconScaleP2:FlxPoint = FlxPoint.get(1.0, 1.0);
// var iconScaleP1:FlxPoint = FlxPoint.get(1.0, 1.0);

var defaultIconScale:FlxPoint = FlxPoint.get(1.0, 1.0);

var enabled:Bool = true;

function setIconScale(icon:FlxSprite, scalePoint:FlxPoint, x:Float, y:Float) {
    scalePoint.set(x, y);
    icon.scale.set(scalePoint.x, scalePoint.y);

    icon.updateHitbox();
    icon.offset.y = icon.extraOffsets.y + ((downscroll) ? (icon.frameHeight - icon.height) : 0);
}

function postCreate() {
    if (enabled)
        doIconBop = false;
}

function postUpdate(e) {
    if (enabled) {
        var iconSpeed:Float = e * 60 * 0.15;

        // setIconScale(iconP2, iconScaleP2,
        //     FlxMath.lerp(iconScaleP2.x, 1.0, iconSpeed),
        //     FlxMath.lerp(iconScaleP2.y, 1.0, iconSpeed)
        // );

        // setIconScale(iconP1, iconScaleP1,
        //     FlxMath.lerp(iconScaleP1.x, 1.0, iconSpeed),
        //     FlxMath.lerp(iconScaleP1.y, 1.0, iconSpeed)
        // );

        for (icon in iconArray) {
            
            setIconScale(icon, defaultIconScale,
                FlxMath.lerp(defaultIconScale.x, 1.0, iconSpeed),
                FlxMath.lerp(defaultIconScale.y, 1.0, iconSpeed));
        }
    }
}

function beatHit(beat:Int) {
    if (enabled) {
        for (icon in iconArray) {
            setIconScale(icon, defaultIconScale, 1.2, 1.2);
        }
    }
}

function destroy() {
    iconScaleP2 = FlxDestroyUtil.put(defaultIconScale);
    iconScaleP1 = FlxDestroyUtil.put(defaultIconScale);
}
