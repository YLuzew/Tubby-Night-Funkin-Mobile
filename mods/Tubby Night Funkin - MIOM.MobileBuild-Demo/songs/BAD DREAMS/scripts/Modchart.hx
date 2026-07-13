import modchart.Manager;

var mod:Manager;
var modActive:Bool = false;
var queuedFuncs = [];

function postCreate() {
    activateMod();
}

function activateMod() {
    mod = new Manager(PlayState.instance);
    add(mod);
    mod.addModifier('OpponentSwap');
    mod.addModifier('transform');
    mod.addModifier('drunk');
    mod.addModifier('schmovinDrunk');


    
    mod.ease('colSpacing', 676, 8, 160, FlxEase.cubeInOut);
    mod.ease('spacing', 676, 8, 640, FlxEase.cubeInOut);
    mod.ease('addx', 676, 8, -176, FlxEase.cubeInOut);
    mod.ease('waveamp', 676, 8, 1, FlxEase.cubeInOut);
    mod.ease('alpha', 676, 8, 0.5, FlxEase.cubeInOut, 0);

    mod.ease('colSpacing', 724, 8, 112, FlxEase.cubeInOut);
    mod.ease('spacing', 724, 8, 620, FlxEase.cubeInOut);
    mod.ease('addx', 724, 8, 0, FlxEase.cubeInOut);
    mod.ease('waveamp', 724, 8, 0, FlxEase.cubeInOut);
    mod.ease('schmovinDrunk', 1140, 8, 0.5, FlxEase.cubeInOut);

    for (pn in 0...2) {
        mod.ease('alpha', 881, 5, 1, FlxEase.cubeInOut, pn);
        mod.ease('alpha', 732, 5, 0, FlxEase.cubeInOut, pn);
        mod.ease('alpha', 1277, 8, 0, FlxEase.linear, pn);
    }

    queueFunc(676, 732, function(beat) {
        var vit = 0.4;
        var fVag = 0.04;
        var scpos = (beat - 676) * vit;
        
        var trans = 1.0;
        if (beat < 684) {
            trans = FlxEase.cubeInOut((beat - 676) / 8.0);
        } else if (beat > 724) {
            trans = FlxEase.cubeInOut(1.0 - ((beat - 724) / 8.0));
        }
        
        if (trans < 0) trans = 0;
        if (trans > 1) trans = 1;

        for (pn in 0...2) {
            var cSpac = mod.getPercent('colSpacing', pn); 
            var spac = mod.getPercent('spacing', pn);
            var adX = mod.getPercent('addx', pn);
            var wAmp = mod.getPercent('waveamp', pn);

            for (col in 0...4) {
                var cpos = (pn == 0) ? (col * -112) - 620 : col * -112;
                var npos = (col * cSpac + (-pn) * spac + scpos * 160) % 1280 + adX;
                var c = ((1 - pn) * 4) + col;

                mod.setPercent('x' + col, (cpos + npos) * trans, pn);

                var ang = 2 * Math.PI * (c / 8);
                mod.setPercent('reverse' + col, wAmp * fVag * Math.sin(beat * Math.PI + ang) * trans, pn);
            }
        }
    });

    mod.ease('OpponentSwap', 628, 4, 1, FlxEase.quadOut);

    f_s(732, function() {
        for (pn in 0...2) {
            for (i in 0...4) {
                mod.setPercent('x' + i, 0, pn);
                mod.setPercent('reverse' + i, 0, pn);
            }
        }
    });
    
    f_s(860, function() {
        mod.setPercent('OpponentSwap', 0);
    });

    f_s(1076, function() {
        mod.setPercent('alpha', 0.1, 0);
        mod.setPercent('OpponentSwap', 0.52);
    });

    queueFunc(1139, 1148, function(beat) {
        var vit = 0.4;
        var fVag = 0.04;
        var scpos = (beat - 676) * vit;
        
        var trans = 1.0;
        if (beat < 1145) {
            trans = FlxEase.quadOut((beat - 1139) / 6);
        }
        
        if (trans < 0) trans = 0;
        if (trans > 1) trans = 1;


        mod.setPercent("OpponentSwap", FlxMath.lerp(0.53, 0, trans), -1);
        mod.setPercent("alpha", FlxMath.lerp(0.1, 1, trans), -1);
    });

    
    modActive = true;
}

function queueFunc(beat, end, func) {
    queuedFuncs.push({beat: beat, end: end, callback: func});
}

function f_s(stepBeat:Float, func:Void->Void) {
    if (mod != null) {
        mod.callback(stepBeat, (_) -> { func(); });
    }
}

function update() {
    if (!modActive && curBeatFloat >= 675.9) {
        activateMod();
    }

    if (modActive) {
        for (obj in queuedFuncs) {
            if (curBeatFloat >= obj.beat && curBeatFloat < obj.end) {
                obj.callback(curBeatFloat);
            } else if (curBeatFloat >= obj.end) {
                queuedFuncs.remove(obj);
            }
        }
    }
}